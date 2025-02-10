// lib/game/logic/game_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../models/character.dart';
import 'dart:math';

class GameBloc extends Bloc<GameEvent, GameState> {
  final Random _random = Random();

  GameBloc() : super(GameState.initial()) {
    on<AttackEvent>(_onAttack);
    on<DefendEvent>(_onDefend);
    on<RunEvent>(_onRun);
    on<OpenInventoryEvent>(_onOpenInventory);
    on<EnemyTurnEvent>(_onEnemyTurn);
    on<UseInventoryItemEvent>(_onUseInventoryItem);
  }

  void _onAttack(AttackEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;

    // Calculate damage (adding a small random factor)
    int damage = (state.player.attack - state.enemy.defense + _random.nextInt(5)).clamp(0, 999);
    int newEnemyHp = state.enemy.currentHp - damage;
    String msg = 'You attacked the ${state.enemy.name} for $damage damage!';

    bool enemyDefeated = newEnemyHp <= 0;

    Character updatedEnemy = state.enemy.copyWith(
      currentHp: enemyDefeated ? 0 : newEnemyHp,
    );

    GameState newState = state.copyWith(
      enemy: updatedEnemy,
      message: msg,
    );

    // If enemy is defeated, end the game.
    if (enemyDefeated) {
      newState = newState.copyWith(
        gameOver: true,
        message: '$msg\nEnemy defeated! You win!',
      );
      emit(newState);
    } else {
      // Switch turn to enemy and trigger enemy turn logic.
      newState = newState.copyWith(currentTurn: Turn.enemy);
      emit(newState);
      add(EnemyTurnEvent());
    }
  }

  void _onDefend(DefendEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;

    // Set the player's defending state.
    Character updatedPlayer = state.player.copyWith(isDefending: true);
    String msg = 'You brace for the enemy attack!';
    GameState newState = state.copyWith(
      player: updatedPlayer,
      message: msg,
      currentTurn: Turn.enemy,
    );
    emit(newState);
    add(EnemyTurnEvent());
  }

  void _onRun(RunEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;

    // Forfeit the fight.
    String msg = 'You ran away! Game Over.';
    GameState newState = state.copyWith(
      gameOver: true,
      message: msg,
    );
    emit(newState);
  }

  void _onOpenInventory(OpenInventoryEvent event, Emitter<GameState> emit) {
    // In a complete implementation, you might navigate to an inventory screen.
    String msg = 'Inventory opened. (Inventory logic not implemented)';
    emit(state.copyWith(message: msg));
  }

  void _onEnemyTurn(EnemyTurnEvent event, Emitter<GameState> emit) async {
    if (state.gameOver) return;

    // Pause briefly to simulate enemy “thinking.”
    await Future.delayed(const Duration(seconds: 1));

    // Enemy attacks the player.
    int baseDamage = state.enemy.attack - state.player.defense + _random.nextInt(5);
    int damage = baseDamage.clamp(0, 999);

    // If the player is defending, halve the damage.
    if (state.player.isDefending) {
      damage = (damage / 2).round();
    }

    int newPlayerHp = state.player.currentHp - damage;
    String msg = 'Enemy attacked you for $damage damage!';
    bool playerDefeated = newPlayerHp <= 0;
    Character updatedPlayer = state.player.copyWith(
      currentHp: playerDefeated ? 0 : newPlayerHp,
      isDefending: false, // Reset defending after enemy turn.
    );

    GameState newState = state.copyWith(
      player: updatedPlayer,
      message: msg,
    );

    if (playerDefeated) {
      newState = newState.copyWith(
        gameOver: true,
        message: '$msg\nYou have been defeated. Game Over.',
      );
      emit(newState);
    } else {
      newState = newState.copyWith(
        currentTurn: Turn.player,
        message: '$msg\nYour turn!',
      );
      emit(newState);
    }
  }

  void _onUseInventoryItem(UseInventoryItemEvent event, Emitter<GameState> emit) {
    // For example, use a healing potion.
    if (event.itemName == 'Healing Potion') {
      int healAmount = 20;
      int newHp = (state.player.currentHp + healAmount).clamp(0, state.player.maxHp);
      String msg = 'Used Healing Potion. Recovered ${newHp - state.player.currentHp} HP.';
      Character updatedPlayer = state.player.copyWith(currentHp: newHp);
      emit(state.copyWith(player: updatedPlayer, message: msg));
    }
  }
}
