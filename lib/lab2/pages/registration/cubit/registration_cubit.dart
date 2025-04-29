import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/logic/service/auth/auth_service.dart';
import 'package:moblabs/lab2/pages/registration/cubit/registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final AuthService authService;

  RegistrationCubit({required this.authService})
      : super(const RegistrationInitial());

  Future<void> register(String name, String email, String password) async {
    emit(const RegistrationLoading());

    try {
      final result = await authService.register(name, email, password);

      if (result == null) {
        emit(const RegistrationSuccess());
      } else {
        emit(RegistrationFailure(result));
      }
    } catch (e) {
      emit(RegistrationFailure(e.toString()));
    }
  }
}
