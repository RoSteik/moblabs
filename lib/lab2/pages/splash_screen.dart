import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:moblabs/lab2/logic/service/auth/user_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }


  void _showConnectivityDialog() {
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


  Future<void> _navigateToNextPage() async {
    final isLoggedIn = SharedPrefsHolder.instance
        .getString('lastLoggedInUser') != null;
    final connectivityResult = await Connectivity().checkConnectivity();

    if (isLoggedIn) {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _showConnectivityDialog();
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
