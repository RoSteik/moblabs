import 'package:flutter/material.dart';
import 'package:moblabs/lab2/pages/home/cubit/main_state.dart';

class DeviceSettingsView extends StatelessWidget {
  final MainState state;
  final VoidCallback onEditCredentials;
  final VoidCallback onRefresh;
  final VoidCallback onUploadCredentials;

  const DeviceSettingsView({
    required this.state,
    required this.onEditCredentials,
    required this.onRefresh,
    required this.onUploadCredentials,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final temperatureDisplay =
        state.latestTemperature != null
            ? '${state.latestTemperature!.toStringAsFixed(1)} °C'
            : 'No Data';

    return Center(
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
            'Device Status: ${state.deviceStatus}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Device ID: ${state.deviceId ?? "No Data"}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Device Key: ${state.deviceKey ?? "No Data"}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          if (state.isLoadingDeviceInfo)
            const CircularProgressIndicator()
          else
            _buildControlButtons(context),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: onEditCredentials,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Credentials'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: onUploadCredentials,
          icon: const Icon(Icons.upload),
          label: const Text('Upload Credentials to ESP32'),
        ),
      ],
    );
  }
}
