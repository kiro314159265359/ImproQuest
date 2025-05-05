import 'package:flutter_application_2/game/models/shop_item.dart';
import '../../../../core/error/failure.dart';
import '../../data/model/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  double totalDistance;

  UserLoaded(this.user, {this.totalDistance = 0.0});
}

class UserError extends UserState {
  Failure failure;
  UserError(this.failure);
}

class UserDeleted extends UserState {}

class UserUpdating extends UserState {}

class UserUpdated extends UserState {
  final UserModel user;
  UserUpdated(this.user);
}

class UpdateError extends UserState {
  Failure failure;
  UpdateError(this.failure);
}

class InventoryLoading extends UserState {}

class InventoryLoaded extends UserState {
  final List<ShopItem> itemsList;
  InventoryLoaded(this.itemsList);
}
