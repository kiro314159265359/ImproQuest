import '../../../../../core/error/failure.dart';

abstract class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterSuccessState extends RegisterState {}

final class RegisterLoadingState extends RegisterState {}

class RegisterErrorState extends RegisterState {
  Failure failure;

  RegisterErrorState(this.failure);
}
