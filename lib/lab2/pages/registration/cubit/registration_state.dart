import 'package:equatable/equatable.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();
}

class RegistrationLoading extends RegistrationState {
  const RegistrationLoading();
}

class RegistrationSuccess extends RegistrationState {
  const RegistrationSuccess();
}

class RegistrationFailure extends RegistrationState {
  final String error;

  const RegistrationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
