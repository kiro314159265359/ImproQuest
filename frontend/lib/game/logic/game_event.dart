abstract class GameEvent {}

// Remove TickEvent class

class AttackEvent extends GameEvent {}

class DefendEvent extends GameEvent {}

class OpenInventoryEvent extends GameEvent {}

class EnemyTurnEvent extends GameEvent {}

class UseInventoryItemEvent extends GameEvent {
  final String itemName;
  UseInventoryItemEvent(this.itemName);
}

class NextFightEvent extends GameEvent {}

// New event for selecting a blind from the pre-fight menu.
class SelectBlindEvent extends GameEvent {
  final int blind;
  SelectBlindEvent(this.blind);
}

// New event for clearing the attack flag.
class ClearAttackEvent extends GameEvent {}

// New event for finalizing attack after animation completes
class FinalizeAttackEvent extends GameEvent {
  final bool isPlayerAttack;
  FinalizeAttackEvent(this.isPlayerAttack);
}
