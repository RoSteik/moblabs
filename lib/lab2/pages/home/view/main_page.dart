import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/elements/pages_list.dart';
import 'package:moblabs/lab2/logic/model/fitness_data.dart';
import 'package:moblabs/lab2/pages/home/cubit/main_cubit.dart';
import 'package:moblabs/lab2/pages/home/cubit/main_state.dart';
import 'package:moblabs/lab2/widgets/custom_bottom_nav_bar.dart';
import 'package:moblabs/lab2/widgets/custom_drawer.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }

        if (state.connectionStatus.contains(ConnectivityResult.none)) {
          _showNoInternetDialog(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Fitness Tracker'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'setup') {
                    Navigator.pushNamed(context, '/setup_device').then((_) {
                      // Credentials will be refreshed when returning
                    });
                  }
                },
                itemBuilder:
                    (_) => const [
                      PopupMenuItem(
                        value: 'setup',
                        child: Text('Setup Device'),
                      ),
                    ],
              ),
            ],
          ),
          drawer: const CustomDrawer(),
          body: _buildBody(context, state),
          floatingActionButton:
              state.selectedIndex == 1
                  ? FloatingActionButton(
                    onPressed: () => _showAddDataDialog(context),
                    tooltip: 'Add Data',
                    child: const Icon(Icons.add),
                  )
                  : null,
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: state.selectedIndex,
            onItemTapped: (index) => _onItemTapped(context, index),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MainState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (state.selectedIndex) {
      case 0:
        return _buildTemperatureWidget(context, state);
      case 1:
        return _buildFitnessDataList(context, state);
      default:
        return state.selectedIndex < pagesList(context).length
            ? pagesList(context).elementAt(state.selectedIndex)
            : Container();
    }
  }

  Widget _buildTemperatureWidget(BuildContext context, MainState state) {
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
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showEditCredentialsDialog(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Credentials'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed:
                          () =>
                              context.read<MainCubit>().checkESP32Connection(),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    if (state.deviceId != null && state.deviceKey != null) {
                      context.read<MainCubit>().uploadCredentialsToESP32(
                        state.deviceId!,
                        state.deviceKey!,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No credentials to upload'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Credentials to ESP32'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFitnessDataList(BuildContext context, MainState state) {
    return ListView.builder(
      itemCount: state.fitnessDataList.length,
      itemBuilder: (context, index) {
        final item = state.fitnessDataList[index];
        return ListTile(
          title: Text(
            'Date: ${item.date.toIso8601String()}, '
            'Steps: ${item.steps}, '
            'Calories Burned: ${item.caloriesBurned}',
          ),
          trailing: Wrap(
            spacing: 12,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed:
                    () => context.read<MainCubit>().deleteFitnessData(index),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    final cubit = context.read<MainCubit>();

    if (index < pagesList(context).length) {
      cubit.updateSelectedIndex(index);
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile').then((_) {
        cubit.updateSelectedIndex(0);
      });
    }
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'You have lost connection to the internet. '
            'Some features may not be available.',
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

  Future<void> _showAddDataDialog(BuildContext context) async {
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
              onPressed: () {
                final date = DateTime.tryParse(dateController.text);
                final steps = int.tryParse(stepsController.text);
                final calories = int.tryParse(caloriesController.text);

                if (date != null && steps != null && calories != null) {
                  final newData = FitnessData(
                    date: date,
                    steps: steps,
                    caloriesBurned: calories,
                  );
                  context.read<MainCubit>().addFitnessData(newData);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid data')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditCredentialsDialog(BuildContext context) async {
    final deviceIdController = TextEditingController(
      text: context.read<MainCubit>().state.deviceId ?? '',
    );
    final deviceKeyController = TextEditingController(
      text: context.read<MainCubit>().state.deviceKey ?? '',
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Device Credentials'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: deviceIdController,
                  decoration: const InputDecoration(labelText: 'Device ID'),
                ),
                TextField(
                  controller: deviceKeyController,
                  decoration: const InputDecoration(labelText: 'Device Key'),
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
              child: const Text('Save'),
              onPressed: () {
                context.read<MainCubit>().saveDeviceCredentials(
                  deviceIdController.text,
                  deviceKeyController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
