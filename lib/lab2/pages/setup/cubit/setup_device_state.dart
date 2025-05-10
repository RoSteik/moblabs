import 'package:equatable/equatable.dart';

abstract class SetupDeviceState extends Equatable {
  const SetupDeviceState();

  @override
  List<Object?> get props => [];
}

class InitialState extends SetupDeviceState {
  const InitialState();
}

class ScanningState extends SetupDeviceState {
  final String message;

  const ScanningState({this.message = 'Scan QR code to setup device'});

  @override
  List<Object?> get props => [message];
}

class ProcessingState extends SetupDeviceState {
  final String message;

  const ProcessingState({this.message = 'Processing QR code...'});

  @override
  List<Object?> get props => [message];
}

class ConnectingState extends SetupDeviceState {
  final String message;

  const ConnectingState({
    this.message = 'Connected to ESP32. Sending credentials...',
  });

  @override
  List<Object?> get props => [message];
}

class WaitingResponseState extends SetupDeviceState {
  final String message;

  const WaitingResponseState({
    this.message = 'Credentials sent. Waiting for response...',
  });

  @override
  List<Object?> get props => [message];
}

class CompletedState extends SetupDeviceState {
  final String message;

  const CompletedState({this.message = 'Setup completed successfully'});

  @override
  List<Object?> get props => [message];
}

class ErrorState extends SetupDeviceState {
  final String message;

  const ErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
