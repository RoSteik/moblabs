import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/logic/service/auth/user_storage_service.dart';
import 'package:moblabs/lab2/pages/login/cubit/splash_screen_state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  final Connectivity _connectivity;

  SplashScreenCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(const SplashScreenState());

  Future<void> checkAuthAndConnectivity() async {
    final isLoggedIn =
        SharedPrefsHolder.instance.getString('lastLoggedInUser') != null;
    final connectivityResult = await _connectivity.checkConnectivity();

    if (isLoggedIn) {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        emit(
          state.copyWith(status: SplashScreenStatus.authenticatedNoInternet),
        );
      } else {
        emit(
          state.copyWith(status: SplashScreenStatus.authenticatedWithInternet),
        );
      }
    } else {
      emit(state.copyWith(status: SplashScreenStatus.unauthenticated));
    }
  }
}
