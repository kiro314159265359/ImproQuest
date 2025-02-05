import '../../../../core/error/failure.dart';
import '../../data/model/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;

  UserLoaded(this.user);
}

class UserError extends UserState {
  Failure failure;

  UserError(this.failure);
}

class UserUpdating extends UserState {}

class UserUpdated extends UserState {
  final UserModel user;
  UserUpdated(this.user);
}

class UpdateError extends UserState {
  Failure failure;
  UpdateError(this.failure);
}
