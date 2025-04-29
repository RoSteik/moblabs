import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:moblabs/lab2/logic/model/fitness_data.dart';

class MainState extends Equatable {
  final int selectedIndex;
  final List<FitnessData> fitnessDataList;
  final List<ConnectivityResult> connectionStatus;
  final double? latestTemperature;
  final String? deviceId;
  final String? deviceKey;
  final bool isLoadingDeviceInfo;
  final String deviceStatus;
  final String? error;
  final bool isLoading;

  const MainState({
    required this.selectedIndex,
    required this.fitnessDataList,
    required this.connectionStatus,
    required this.isLoadingDeviceInfo, required this.deviceStatus,
    required this.isLoading, this.latestTemperature,
    this.deviceId,
    this.deviceKey,
    this.error,
  });

  factory MainState.initial() {
    return const MainState(
      selectedIndex: 0,
      fitnessDataList: [],
      connectionStatus: [ConnectivityResult.none],
      isLoadingDeviceInfo: false,
      deviceStatus: 'No device connected',
      isLoading: false,
    );
  }

  MainState copyWith({
    int? selectedIndex,
    List<FitnessData>? fitnessDataList,
    List<ConnectivityResult>? connectionStatus,
    double? latestTemperature,
    String? deviceId,
    String? deviceKey,
    bool? isLoadingDeviceInfo,
    String? deviceStatus,
    String? error,
    bool? isLoading,
  }) {
    return MainState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      fitnessDataList: fitnessDataList ?? this.fitnessDataList,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      latestTemperature: latestTemperature ?? this.latestTemperature,
      deviceId: deviceId ?? this.deviceId,
      deviceKey: deviceKey ?? this.deviceKey,
      isLoadingDeviceInfo: isLoadingDeviceInfo ?? this.isLoadingDeviceInfo,
      deviceStatus: deviceStatus ?? this.deviceStatus,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    selectedIndex,
    fitnessDataList,
    connectionStatus,
    latestTemperature,
    deviceId,
    deviceKey,
    isLoadingDeviceInfo,
    deviceStatus,
    error,
    isLoading,
  ];
}
