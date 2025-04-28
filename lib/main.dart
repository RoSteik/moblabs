import 'package:flutter/material.dart';
import 'package:moblabs/lab2/elements/app_routes.dart';
import 'package:moblabs/lab2/logic/service/auth/auth_service.dart';
import 'package:moblabs/lab2/logic/service/auth/user_storage_service.dart';
import 'package:moblabs/lab2/logic/service/tracker/fitness_data_service.dart';
import 'package:moblabs/lab2/pages/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SharedPrefsHolder.init();
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FitnessDataService>(
          create: (_) => FitnessDataService(),
        ),
      ],
      child: MaterialApp(
        title: 'Fitness App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
        routes: appRoutes,
      ),
    );
  }
}
