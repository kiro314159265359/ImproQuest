import '../../../../../core/error/failure.dart';

abstract class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginSuccessState extends LoginState {}

final class LoginLoadingState extends LoginState {}

class LoginErrorState extends LoginState {
  Failure failure;

  LoginErrorState(this.failure);
}
