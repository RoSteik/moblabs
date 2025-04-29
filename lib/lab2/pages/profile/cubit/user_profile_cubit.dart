import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/logic/model/user.dart';
import 'package:moblabs/lab2/logic/service/auth/auth_service.dart';
import 'package:moblabs/lab2/logic/service/auth/user_storage_service.dart';
import 'package:moblabs/lab2/pages/profile/cubit/user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final AuthService authService;

  UserProfileCubit({required this.authService})
      : super(const UserProfileInitial()) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    emit(const UserProfileLoading());

    try {
      final lastLoggedInUserEmail = SharedPrefsHolder.instance
          .getString('lastLoggedInUser');

      if (lastLoggedInUserEmail != null) {
        final userString = SharedPrefsHolder.instance
            .getString(lastLoggedInUserEmail);

        if (userString != null) {
          final Map<String, dynamic> userMap =
          jsonDecode(userString) as Map<String, dynamic>;

          final user = User.fromJson(userMap);
          emit(UserProfileLoaded(user));
        } else {
          emit(const UserProfileError('User data not found'));
        }
      } else {
        emit(const UserProfileError('No logged in user'));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await authService.logout();
      emit(const UserProfileInitial());
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
