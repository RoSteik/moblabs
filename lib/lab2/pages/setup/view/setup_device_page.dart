import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:moblabs/lab2/pages/setup/cubit/setup_device_cubit.dart';
import 'package:moblabs/lab2/pages/setup/cubit/setup_device_state.dart';

class SetupDevicePage extends StatefulWidget {
  const SetupDevicePage({super.key});

  @override
  State<SetupDevicePage> createState() => _SetupDevicePageState();
}

class _SetupDevicePageState extends State<SetupDevicePage> {
  final MobileScannerController _cameraController = MobileScannerController();

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SetupDeviceCubit(),
      child: BlocConsumer<SetupDeviceCubit, SetupDeviceState>(
        listener: (context, state) {
          if (state is ErrorState) {
            _showSnack(state.message);
          } else if (state is CompletedState) {
            final navigator = Navigator.of(context);
            Future.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
              navigator.pop();
            });
          }
        },
        builder: (context, state) {
          final cubit = context.read<SetupDeviceCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text('Setup Device')),
            body: Column(
              children: [
                Expanded(
                  child: MobileScanner(
                    controller: _cameraController,
                    onDetect: cubit.onDetect,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        _getStatusMessage(state),
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      if (_isProcessing(state))
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
        },
      ),
    );
  }

  String _getStatusMessage(SetupDeviceState state) {
    if (state is ScanningState) return state.message;
    if (state is ProcessingState) return state.message;
    if (state is ConnectingState) return state.message;
    if (state is WaitingResponseState) return state.message;
    if (state is CompletedState) return state.message;
    if (state is ErrorState) return state.message;
    return 'Scan QR code to setup device';
  }

  bool _isProcessing(SetupDeviceState state) {
    return state is ProcessingState ||
        state is ConnectingState ||
        state is WaitingResponseState;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
