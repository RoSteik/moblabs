import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/logic/service/tracker/fitness_data_service.dart';
import 'package:moblabs/lab2/pages/home/cubit/main_cubit.dart';
import 'package:moblabs/lab2/pages/home/view/main_page.dart';
import 'package:moblabs/lab2/pages/login/view/login_page.dart';
import 'package:moblabs/lab2/pages/profile/view/user_profile_page.dart';
import 'package:moblabs/lab2/pages/registration/view/registration_page.dart';
import 'package:moblabs/lab2/pages/setup/view/setup_device_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => BlocProvider(
    create: (context) => MainCubit(
      context.read<FitnessDataService>(),
    ),
    child: const MainPage(),
  ),
  '/login': (context) => const LoginPage(),
  '/registration': (context) => RegistrationPage(),
  '/profile': (context) => const UserProfilePage(),
  '/setup_device': (context) => const SetupDevicePage(),
};
