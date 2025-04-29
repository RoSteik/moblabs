import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/logic/model/fitness_data.dart';
import 'package:moblabs/lab2/logic/service/tracker/fitness_data_service.dart';
import 'package:moblabs/lab2/pages/home/cubit/main_state.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';

class MainCubit extends Cubit<MainState> {
  final FitnessDataService _fitnessDataService;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  MqttServerClient? _mqttClient;

  MainCubit(this._fitnessDataService) : super(MainState.initial()) {
    _loadFitnessDataList();
    _loadDeviceCredentials();
    _initConnectivity();
    _connectToMQTT();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription.cancel();
    _mqttClient?.disconnect();
    super.close();
  }

  void updateSelectedIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> _loadFitnessDataList() async {
    emit(state.copyWith(isLoading: true));
    try {
      final data = await _fitnessDataService.loadFitnessDataList();
      emit(state.copyWith(fitnessDataList: data, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> addFitnessData(FitnessData data) async {
    try {
      await _fitnessDataService.addFitnessData(data);
      await _loadFitnessDataList();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteFitnessData(int index) async {
    try {
      await _fitnessDataService.deleteFitnessData(index);
      await _loadFitnessDataList();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _loadDeviceCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('deviceId');
    final deviceKey = prefs.getString('deviceKey');

    emit(state.copyWith(
      deviceId: deviceId,
      deviceKey: deviceKey,
    ),);
  }

  Future<void> saveDeviceCredentials(String deviceId, String deviceKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceId', deviceId);
    await prefs.setString('deviceKey', deviceKey);

    emit(state.copyWith(
      deviceId: deviceId,
      deviceKey: deviceKey,
    ),);
  }

  Future<void> checkESP32Connection() async {
    emit(state.copyWith(
      isLoadingDeviceInfo: true,
      deviceStatus: 'Checking device connection...',
    ),);

    final port = await _openESP32Connection();
    if (port == null) return;

    try {
      const command = '{"action":"getCredentials"}\n';
      await port.write(Uint8List.fromList(utf8.encode(command)));

      String response = '';
      bool responseReceived = false;

      final subscription = port.inputStream!.listen((Uint8List data) {
        final chunk = utf8.decode(data);
        response += chunk;
        developer.log('ESP32 response: $response');
        responseReceived = true;
      });

      for (int i = 0; i < 10; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (responseReceived) break;
      }

      final idMatch = RegExp(r'ID:(.+?)(?=\s|$)').firstMatch(response);
      final keyMatch = RegExp(r'KEY:(.+?)(?=\s|$)').firstMatch(response);

      final String? deviceId = idMatch?.group(1)?.trim();
      final String? deviceKey = keyMatch?.group(1)?.trim();

      subscription.cancel();
      await port.close();

      if (deviceId != null &&
          deviceId.isNotEmpty &&
          deviceKey != null &&
          deviceKey.isNotEmpty) {
        await saveDeviceCredentials(deviceId, deviceKey);

        emit(state.copyWith(
          isLoadingDeviceInfo: false,
          deviceStatus: 'Device connected and verified',
        ),);
      } else {
        emit(state.copyWith(
          isLoadingDeviceInfo: false,
          deviceStatus: 'No stored credentials on ESP32',
        ),);
      }
    } catch (e) {
      await port.close();
      emit(state.copyWith(
        isLoadingDeviceInfo: false,
        deviceStatus: 'Error: $e',
      ),);
    }
  }

  Future<void> uploadCredentialsToESP32(String deviceId,
      String deviceKey,) async {
    if (deviceId.isEmpty || deviceKey.isEmpty) {
      emit(state.copyWith(error: 'Please enter both Device ID and Key'));
      return;
    }

    emit(state.copyWith(
      isLoadingDeviceInfo: true,
      deviceStatus: 'Uploading credentials to ESP32...',
    ),);

    final port = await _openESP32Connection();
    if (port == null) return;

    try {
      await saveDeviceCredentials(deviceId, deviceKey);

      final command =
          '{"action":"setCredentials","deviceId":"$deviceId",'
          '"deviceKey":"$deviceKey"}\n';
      developer.log('Sending command: $command');
      await port.write(Uint8List.fromList(utf8.encode(command)));

      String response = '';
      bool responseReceived = false;

      final subscription = port.inputStream!.listen((Uint8List data) {
        final chunk = utf8.decode(data);
        response += chunk;
        developer.log('ESP32 upload response: $response');
        responseReceived = true;
      });

      for (int i = 0; i < 10; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (responseReceived) break;
      }

      subscription.cancel();
      await port.close();

      if (response.contains('SUCCESS') || response.contains('OK')) {
        emit(state.copyWith(
          isLoadingDeviceInfo: false,
          deviceStatus: 'Credentials uploaded successfully',
        ),);
      } else {
        emit(state.copyWith(
          isLoadingDeviceInfo: false,
          deviceStatus: 'Uploaded but no confirmation from ESP32',
        ),);
      }
    } catch (e) {
      await port.close();
      emit(state.copyWith(
        isLoadingDeviceInfo: false,
        deviceStatus: 'Error during upload: $e',
      ),);
    }
  }

  Future<UsbPort?> _openESP32Connection() async {
    try {
      final devices = await UsbSerial.listDevices();
      final esp32Device = devices.firstWhereOrNull(
            (device) => device.vid == 0x10C4 && device.pid == 0xEA60,
      );

      if (esp32Device == null) {
        emit(state.copyWith(
          isLoadingDeviceInfo: false,
          deviceStatus: 'ESP32 not connected',
        ),);
        return null;
      }

      final port = await esp32Device.create();
      if (port == null) {
        emit(state.copyWith(
          isLoadingDeviceInfo: false,
          deviceStatus: 'Failed to create serial port',
        ),);
        return null;
      }

      final bool openResult = await port.open();
      if (!openResult) {
        emit(state.copyWith(
          isLoadingDeviceInfo: false,
          deviceStatus: 'Failed to open serial port',
        ),);
        return null;
      }

      await port.setDTR(true);
      await port.setRTS(true);
      await port.setPortParameters(
        115200,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      return port;
    } catch (e) {
      emit(state.copyWith(
        isLoadingDeviceInfo: false,
        deviceStatus: 'Error connecting to ESP32: $e',
      ),);
      return null;
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    emit(state.copyWith(connectionStatus: result));
    developer.log('Connectivity changed: $result');
  }

  Future<void> _connectToMQTT() async {
    const broker = 'test.mosquitto.org';
    const port = 1883;
    final clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    final client = MqttServerClient(broker, clientId);
    client.port = port;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
    try {
      await client.connect();
    } catch (e) {
      developer.log('MQTT client exception: $e');
      client.disconnect();
      return;
    }
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      developer.log('MQTT connected');
      client.subscribe('sensor/temperature', MqttQos.atLeastOnce);
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
        if (c != null && c.isNotEmpty) {
          final recMess = c[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
          developer.log('MQTT message received: $payload');
          final temperature = double.tryParse(payload);
          if (temperature != null) {
            emit(state.copyWith(latestTemperature: temperature));
          }
        }
      });
    } else {
      developer.log(
        'MQTT connection failed - status is ${client.connectionStatus}',
      );
      client.disconnect();
    }
    _mqttClient = client;
  }

  void _onDisconnected() {
    developer.log('MQTT disconnected');
  }
}
