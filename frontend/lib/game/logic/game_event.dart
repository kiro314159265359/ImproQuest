// lib/game/logic/game_event.dart
abstract class GameEvent {}

class TickEvent extends GameEvent {}

class AttackEvent extends GameEvent {}

class DefendEvent extends GameEvent {}

class RunEvent extends GameEvent {}

class OpenInventoryEvent extends GameEvent {}

class EnemyTurnEvent extends GameEvent {}

class UseInventoryItemEvent extends GameEvent {
  final String itemName;
  UseInventoryItemEvent(this.itemName);
}

class NextFightEvent extends GameEvent {}
