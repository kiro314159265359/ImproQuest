import '../../../../../core/error/failure.dart';

abstract class ForgetPasswordState {}

final class ForgetPasswordInitial extends ForgetPasswordState {}

final class EmailSuccessState extends ForgetPasswordState {}

final class EmailSendingState extends ForgetPasswordState {}

class EmailErrorState extends ForgetPasswordState {
  Failure failure;

  EmailErrorState(this.failure);
}

final class OTPSuccessState extends ForgetPasswordState {}

final class OTPSendingState extends ForgetPasswordState {}

class OTPErrorState extends ForgetPasswordState {
  Failure failure;

  OTPErrorState(this.failure);
}

final class ResetPasswordSuccessState extends ForgetPasswordState {}

final class ResetPasswordSendingState extends ForgetPasswordState {}

class ResetPasswordErrorState extends ForgetPasswordState {
  Failure failure;

  ResetPasswordErrorState(this.failure);
}
