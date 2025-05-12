import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/dialogs/add_fitness_data_dialog.dart';
import 'package:moblabs/lab2/dialogs/edit_credentials_dialog.dart';
import 'package:moblabs/lab2/elements/pages_list.dart';
import 'package:moblabs/lab2/pages/home/cubit/main_cubit.dart';
import 'package:moblabs/lab2/pages/home/cubit/main_state.dart';
import 'package:moblabs/lab2/widgets/custom_bottom_nav_bar.dart';
import 'package:moblabs/lab2/widgets/custom_drawer.dart';
import 'package:moblabs/lab2/widgets/device_settings_view.dart';
import 'package:moblabs/lab2/widgets/fitness_data_list.dart';

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
          appBar: const MainAppBar(),
          drawer: const CustomDrawer(),
          body: MainBodyContent(state: state),
          floatingActionButton:
              state.selectedIndex == 1 ? const AddDataFloatingButton() : null,
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: state.selectedIndex,
            onItemTapped: (index) => _onItemTapped(context, index),
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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
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
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MainBodyContent extends StatelessWidget {
  final MainState state;
  const MainBodyContent({required this.state, super.key});
  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (state.selectedIndex) {
      case 0:
        return DeviceSettingsView(
          state: state,
          onEditCredentials: () => _showEditCredentialsDialog(context),
          onRefresh: () => context.read<MainCubit>().checkESP32Connection(),
          onUploadCredentials: () {
            if (state.deviceId != null && state.deviceKey != null) {
              context.read<MainCubit>().uploadCredentialsToESP32(
                state.deviceId!,
                state.deviceKey!,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No credentials to upload')),
              );
            }
          },
        );
      case 1:
        return FitnessDataList(
          fitnessDataList: state.fitnessDataList,
          onDelete:
              (index) => context.read<MainCubit>().deleteFitnessData(index),
        );
      default:
        return state.selectedIndex < pagesList(context).length
            ? pagesList(context).elementAt(state.selectedIndex)
            : Container();
    }
  }
  void _showEditCredentialsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => EditCredentialsDialog(
            initialDeviceId: context.read<MainCubit>().state.deviceId ?? '',
            initialDeviceKey: context.read<MainCubit>().state.deviceKey ?? '',
            onSave:
                (deviceId, deviceKey) => context
                    .read<MainCubit>()
                    .saveDeviceCredentials(deviceId, deviceKey),
          ),
    );
  }
}

class AddDataFloatingButton extends StatelessWidget {
  const AddDataFloatingButton({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed:
          () => showDialog<void>(
            context: context,
            builder:
                (context) => AddFitnessDataDialog(
                  onAdd:
                      (data) => context.read<MainCubit>().addFitnessData(data),
                ),
          ),
      tooltip: 'Add Data',
      child: const Icon(Icons.add),
    );
  }
}
