import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/pages/login/cubit/splash_screen_cubit.dart';
import 'package:moblabs/lab2/pages/login/cubit/splash_screen_state.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashScreenCubit()..checkAuthAndConnectivity(),
      child: const SplashScreenView(),
    );
  }
}

class SplashScreenView extends StatelessWidget {
  const SplashScreenView({super.key});

  void _showConnectivityDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('You are logged in but not connected to the internet.'),
                Text('Please connect.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashScreenCubit, SplashScreenState>(
        listener: (context, state) {
          switch (state.status) {
            case SplashScreenStatus.authenticatedWithInternet:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case SplashScreenStatus.authenticatedNoInternet:
              _showConnectivityDialog(context);
              break;
            case SplashScreenStatus.unauthenticated:
              Navigator.of(context).pushReplacementNamed('/login');
              break;
            case SplashScreenStatus.loading:
            // Do nothing while loading
              break;
          }
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
