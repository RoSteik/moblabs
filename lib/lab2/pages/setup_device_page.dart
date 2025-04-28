import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';

class SetupDevicePage extends StatefulWidget {
  const SetupDevicePage({super.key});

  @override
  State<SetupDevicePage> createState() => _SetupDevicePageState();
}

class _SetupDevicePageState extends State<SetupDevicePage> {
  bool _scanned = false;
  bool _processing = false;
  String _statusMessage = 'Scan QR code to setup device';
  final MobileScannerController _cameraController = MobileScannerController();

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || _processing) return;
    setState(() {
      _scanned = true;
      _processing = true;
      _statusMessage = 'Processing QR code...';
    });

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      _showSnack('No QR code detected');
      setState(() {
        _scanned = false;
        _processing = false;
        _statusMessage = 'Scan QR code to setup device';
      });
      return;
    }

    final raw = barcodes.first.rawValue;
    if (raw == null) {
      _showSnack('Empty QR code detected');
      setState(() {
        _scanned = false;
        _processing = false;
        _statusMessage = 'Scan QR code to setup device';
      });
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

      setState(() {
        _statusMessage = 'Credentials saved. Connecting to ESP32...';
      });

      final response = await _sendToESP32(deviceId, deviceKey);

      setState(() {
        _statusMessage = 'Response from ESP32: $response';
      });

      await Future<void>.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      _showSnack('Error: $e');
      setState(() {
        _scanned = false;
        _processing = false;
        _statusMessage = 'Scan QR code to setup device';
      });
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

      setState(() {
        _statusMessage = 'Connected to ESP32. Sending credentials...';
      });

      final data =
          '${jsonEncode({'deviceId': deviceId, 'deviceKey': deviceKey})}\n';
      await port.write(Uint8List.fromList(utf8.encode(data)));

      setState(() {
        _statusMessage = 'Credentials sent. Waiting for response...';
      });

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

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Device')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _cameraController,
              onDetect: _onDetect,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                if (_processing)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
