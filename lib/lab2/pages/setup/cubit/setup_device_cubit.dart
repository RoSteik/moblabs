import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:moblabs/lab2/pages/setup/cubit/setup_device_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';

class SetupDeviceCubit extends Cubit<SetupDeviceState> {
  SetupDeviceCubit() : super(const ScanningState());

  bool _scanned = false;
  bool _processing = false;

  void onDetect(BarcodeCapture capture) async {
    if (_scanned || _processing) return;

    _scanned = true;
    _processing = true;
    emit(const ProcessingState());

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      emit(const ErrorState(message: 'No QR code detected'));
      _scanned = false;
      _processing = false;
      emit(const ScanningState());
      return;
    }

    final raw = barcodes.first.rawValue;
    if (raw == null) {
      emit(const ErrorState(message: 'Empty QR code detected'));
      _scanned = false;
      _processing = false;
      emit(const ScanningState());
      return;
    }

    try {
      final creds = jsonDecode(raw) as Map<String, dynamic>;
      final deviceId = creds['deviceId']?.toString();
      final deviceKey = creds['deviceKey']?.toString();

      if (deviceId == null || deviceKey == null) {
        throw const FormatException('Required keys missing');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceId', deviceId);
      await prefs.setString('deviceKey', deviceKey);

      emit(
        const ProcessingState(
          message: 'Credentials saved. Connecting to ESP32...',
        ),
      );

      final response = await _sendToESP32(deviceId, deviceKey);

      emit(CompletedState(message: 'Response from ESP32: $response'));

      await Future<void>.delayed(const Duration(seconds: 2));

      // Navigation will be handled in the UI layer
    } catch (e) {
      emit(ErrorState(message: 'Error: $e'));
      _scanned = false;
      _processing = false;
      emit(const ScanningState());
    }
  }

  Future<String> _sendToESP32(String deviceId, String deviceKey) async {
    try {
      final devices = await UsbSerial.listDevices();
      final esp32Device = devices.firstWhereOrNull(
        (device) => device.vid == 0x10C4 && device.pid == 0xEA60,
      );

      if (esp32Device == null) {
        throw Exception('ESP32 device not found. Please connect it via USB.');
      }

      final port = await esp32Device.create();
      if (port == null) {
        throw Exception('Failed to create serial port');
      }

      final bool openResult = await port.open();
      if (!openResult) {
        throw Exception('Failed to open serial port');
      }

      await port.setDTR(true);
      await port.setRTS(true);
      await port.setPortParameters(
        115200,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      emit(const ConnectingState());

      final data =
          '${jsonEncode({'deviceId': deviceId, 'deviceKey': deviceKey})}\n';
      await port.write(Uint8List.fromList(utf8.encode(data)));

      emit(const WaitingResponseState());

      String response = '';
      final Stream<Uint8List> inputStream = port.inputStream!;

      final completer = Completer<String>();

      Future.delayed(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete('Timeout waiting for ESP32 response');
        }
      });

      final subscription = inputStream.listen((Uint8List data) {
        final chunk = utf8.decode(data);
        response += chunk;

        if (response.contains('SUCCESS')) {
          if (!completer.isCompleted) {
            completer.complete(response);
          }
        }
      });

      final result = await completer.future;

      subscription.cancel();
      await port.close();

      return result;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
