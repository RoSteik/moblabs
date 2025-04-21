import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moblabs/lab2/elements/pages_list.dart';
import 'package:moblabs/lab2/logic/model/fitness_data.dart';
import 'package:moblabs/lab2/logic/service/tracker/fitness_data_service.dart';
import 'package:moblabs/lab2/widgets/custom_bottom_nav_bar.dart';
import 'package:moblabs/lab2/widgets/custom_drawer.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<FitnessData> _fitnessDataList = [];
  int _selectedIndex = 0;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  MqttServerClient? _mqttClient;
  double? _latestTemperature;

  String? _deviceId;
  String? _deviceKey;



  @override
  void initState() {
    super.initState();
    _loadFitnessDataList();

    _loadDeviceCredentials();

    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _connectToMQTT();
  }

  Future<void> _loadDeviceCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _deviceId = prefs.getString('deviceId');
      _deviceKey = prefs.getString('deviceKey');
    });
  }

  void _showNoInternetDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'You have lost connection to the internet.'
            ' Some features may not be available.',
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _mqttClient?.disconnect();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    if (!mounted) {
      return Future.value();
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
    developer.log('Connectivity changed: $_connectionStatus');
    if (_connectionStatus.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
    }
  }

  void onItemTapped(
    BuildContext context,
    int index,
    void Function(int) updateIndex,
  ) {
    if (index < pagesList(context).length) {
      updateIndex(index);
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile').then((_) {
        updateIndex(0);
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      onItemTapped(context, index, updateIndex);
    });
  }

  void updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadFitnessDataList() async {
    final fitnessDataService = Provider.of<FitnessDataService>(
      context,
      listen: false,
    );
    final data = await fitnessDataService.loadFitnessDataList();
    setState(() => _fitnessDataList = data);
  }

  Future<void> _addFitnessData() async {
    await _showAddDataDialog();
  }

  Future<void> _deleteFitnessData(int index) async {
    final fitnessDataService = Provider.of<FitnessDataService>(
      context,
      listen: false,
    );
    await fitnessDataService.deleteFitnessData(index);
    _loadFitnessDataList();
  }

  Future<void> _showAddDataDialog() async {
    final dateController = TextEditingController();
    final stepsController = TextEditingController();
    final caloriesController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Fitness Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    hintText: 'Enter date (YYYY-MM-DD)',
                  ),
                ),
                TextField(
                  controller: stepsController,
                  decoration: const InputDecoration(hintText: 'Enter steps'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: caloriesController,
                  decoration: const InputDecoration(
                    hintText: 'Enter calories burned',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                final date = DateTime.tryParse(dateController.text);
                final steps = int.tryParse(stepsController.text);
                final calories = int.tryParse(caloriesController.text);
                if (date != null && steps != null && calories != null) {
                  final newData = FitnessData(
                    date: date,
                    steps: steps,
                    caloriesBurned: calories,
                  );
                  final fitnessDataService = Provider.of<FitnessDataService>(
                    context,
                    listen: false,
                  );
                  await fitnessDataService.addFitnessData(newData);
                  _loadFitnessDataList();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
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
          setState(() {
            _latestTemperature = double.tryParse(payload) ?? _latestTemperature;
          });
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

  @override
  Widget build(BuildContext context) {
    final latestTemperature = _latestTemperature;
    final temperatureDisplay =
        latestTemperature != null
            ? '${latestTemperature.toStringAsFixed(1)} °C'
            : 'No Data';

    final temperatureWidget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Latest Temperature:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            temperatureDisplay,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Device ID: ${_deviceId ?? "No Data"}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Device Key: ${_deviceKey ?? "No Data"}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'setup') {
                Navigator.pushNamed(context, '/setup_device');
              }
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'setup', child: Text('Setup Device')),
                ],
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body:
          _selectedIndex == 1
              ? ListView.builder(
                itemCount: _fitnessDataList.length,
                itemBuilder: (context, index) {
                  final item = _fitnessDataList[index];
                  return ListTile(
                    title: Text(
                      'Date: ${item.date.toIso8601String()}, Steps: ${item.steps}, '
                      'Calories Burned: ${item.caloriesBurned}',
                    ),
                    trailing: Wrap(
                      spacing: 12,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteFitnessData(index),
                        ),
                      ],
                    ),
                  );
                },
              )
              : _selectedIndex == 0
              ? temperatureWidget
              : Center(
                child:
                    _selectedIndex < pagesList(context).length
                        ? pagesList(context).elementAt(_selectedIndex)
                        : Container(),
              ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
                onPressed: _addFitnessData,
                tooltip: 'Add Data',
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
