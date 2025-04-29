import 'package:equatable/equatable.dart';

enum SplashScreenStatus {
  loading,
  authenticatedWithInternet,
  authenticatedNoInternet,
  unauthenticated
}

class SplashScreenState extends Equatable {
  final SplashScreenStatus status;

  const SplashScreenState({
    this.status = SplashScreenStatus.loading,
  });

  SplashScreenState copyWith({
    SplashScreenStatus? status,
  }) {
    return SplashScreenState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [status];
}
