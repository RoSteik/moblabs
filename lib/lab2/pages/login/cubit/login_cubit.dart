import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/logic/service/auth/auth_service.dart';
import 'package:moblabs/lab2/pages/login/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;
  final Connectivity _connectivity;

  LoginCubit({
    required AuthService authService,
    Connectivity? connectivity,
  })  : _authService = authService,
        _connectivity = connectivity ?? Connectivity(),
        super(const LoginState());

  void emailChanged(String value) {
    emit(state.copyWith(email: value));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value));
  }

  Future<void> login() async {
    emit(state.copyWith(status: LoginStatus.loading));

    // Check internet connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(state.copyWith(status: LoginStatus.noInternet));
      return;
    }

    try {
      final loggedIn = await _authService.login(state.email, state.password);

      if (loggedIn) {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Invalid email or password',
        ),);
      }
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ),);
    }
  }
}
