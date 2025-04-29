import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/elements/responsive_config.dart';
import 'package:moblabs/lab2/logic/service/auth/auth_service.dart';
import 'package:moblabs/lab2/pages/profile/cubit/user_profile_cubit.dart';
import 'package:moblabs/lab2/pages/profile/cubit/user_profile_state.dart';


class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  void _showLogoutConfirmationDialog(BuildContext context,
      UserProfileCubit cubit,) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () async {
                await cubit.logout();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileCubit(
        authService: context.read<AuthService>(),
      ),
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          final cubit = context.read<UserProfileCubit>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('User Profile'),
              actions: [
                TextButton(
                  onPressed: () => _showLogoutConfirmationDialog(context,
                      cubit,),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildBody(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileState state) {
    if (state is UserProfileLoading) {
      return const CircularProgressIndicator();
    } else if (state is UserProfileLoaded) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: ResponsiveConfig.avatarRadius(context),
            backgroundImage: const AssetImage('assets/place_holder.jpg'),
          ),
          SizedBox(height: ResponsiveConfig.spacing(context)),
          Text(
            'Name: ${state.user.name}',
            style: TextStyle(
              fontSize: ResponsiveConfig.fontSizeName(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveConfig.spacing(context) / 2),
          Text(
            'Email: ${state.user.email}',
            style: TextStyle(
              fontSize: ResponsiveConfig.fontSizeEmail(context),
            ),
          ),
          SizedBox(height: ResponsiveConfig.spacing(context)),
        ],
      );
    } else if (state is UserProfileError) {
      return Text('Error: ${state.message}');
    } else {
      return const Column();
    }
  }
}
