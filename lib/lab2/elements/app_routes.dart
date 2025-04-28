import 'package:flutter/material.dart';
import 'package:moblabs/lab2/pages/login_page.dart';
import 'package:moblabs/lab2/pages/main_page.dart';
import 'package:moblabs/lab2/pages/registration_page.dart';
import 'package:moblabs/lab2/pages/setup_device_page.dart';
import 'package:moblabs/lab2/pages/user_profile_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const MainPage(),
  '/login': (context) => const LoginPage(),
  '/registration': (context) => const RegistrationPage(),
  '/profile': (context) => const UserProfilePage(),
  '/setup_device': (context) => const SetupDevicePage(),
};
