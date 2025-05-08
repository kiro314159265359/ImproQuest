import '../../../../../core/error/failure.dart';

abstract class ForgetPasswordState {}

final class ForgetPasswordInitial extends ForgetPasswordState {}

final class EmailSuccessState extends ForgetPasswordState {}

final class EmailSendingState extends ForgetPasswordState {}

class EmailErrorState extends ForgetPasswordState {
  Failure failure;

  EmailErrorState(this.failure);
}
