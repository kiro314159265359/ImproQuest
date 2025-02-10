// lib/game/logic/game_event.dart
abstract class GameEvent {}

class AttackEvent extends GameEvent {}

class DefendEvent extends GameEvent {}

class RunEvent extends GameEvent {}

class OpenInventoryEvent extends GameEvent {}

// This event is triggered after a player action to let the enemy take its turn.
class EnemyTurnEvent extends GameEvent {}

// Optional: Using an item from inventory.
class UseInventoryItemEvent extends GameEvent {
  final String itemName;

  UseInventoryItemEvent(this.itemName);
}
