import 'package:flutter_application_2/game/models/shop_item.dart';
import '../../../../core/error/failure.dart';

abstract class CharacterState {}

class CharacterInitial extends CharacterState {}

class InventoryLoading extends CharacterState {}

class InventoryLoaded extends CharacterState {
  final List<ShopItem> itemsList;
  InventoryLoaded(this.itemsList);
}

class InventoryUpdating extends CharacterState {}

class InventorySuccess extends CharacterState {}

class InventoryError extends CharacterState {
  final Failure failure;
  InventoryError(this.failure);
}

class SkillPointUpdating extends CharacterState {}

class SkillPointSuccess extends CharacterState {}

class SkillPointError extends CharacterState {
  final Failure failure;
  SkillPointError(this.failure);
}
