// lib/game/logic/game_bloc.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../models/character.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final Random _random = Random();
  Timer? _timer;
  static const double initiativeThreshold = 100.0;
  // tickDelta represents the time factor per tick (adjust as needed)
  static const double tickDelta = 0.1;

  GameBloc() : super(GameState.initial()) {
    // Register event handlers.
    on<TickEvent>(_onTickEvent);
    on<AttackEvent>(_onAttack);
    on<DefendEvent>(_onDefend);
    on<RunEvent>(_onRun);
    on<OpenInventoryEvent>(_onOpenInventory);
    on<EnemyTurnEvent>(_onEnemyTurn);
    on<UseInventoryItemEvent>(_onUseInventoryItem);
    on<NextFightEvent>(_onNextFight);

    // Start a periodic timer to fire TickEvent.
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      add(TickEvent());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  // TickEvent handler: updates initiative bars if no turn is active.
  void _onTickEvent(TickEvent event, Emitter<GameState> emit) {
    // Do not update if the game is over or if a turn is currently active.
    if (state.gameOver || state.currentTurn != Turn.none) return;

    double newPlayerInit =
        state.playerInitiative + state.player.agility * tickDelta;
    double newEnemyInit =
        state.enemyInitiative + state.enemy.agility * tickDelta;
    Turn newTurn = Turn.none;

    // Check if either initiative meter has reached the threshold.
    if (newPlayerInit >= initiativeThreshold ||
        newEnemyInit >= initiativeThreshold) {
      // If both are ready, the one with the higher value gets the turn.
      if (newPlayerInit >= newEnemyInit) {
        newTurn = Turn.player;
        newPlayerInit -= initiativeThreshold;
      } else {
        newTurn = Turn.enemy;
        newEnemyInit -= initiativeThreshold;
      }
    }

    emit(state.copyWith(
      playerInitiative: newPlayerInit,
      enemyInitiative: newEnemyInit,
      currentTurn: newTurn,
    ));

    // If enemy wins the initiative, automatically trigger enemy turn after a short delay.
    if (newTurn == Turn.enemy) {
      Future.delayed(const Duration(milliseconds: 300), () {
        add(EnemyTurnEvent());
      });
    }
  }

  void _onAttack(AttackEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;

    // Calculate damage using Strength vs Endurance.
    int damage =
        (state.player.strength - state.enemy.endurance + _random.nextInt(5))
            .clamp(0, 999);
    int newEnemyHp = state.enemy.currentHp - damage;
    String msg = 'You attacked ${state.enemy.name} for $damage damage!';
    bool enemyDefeated = newEnemyHp <= 0;
    Character updatedEnemy =
        state.enemy.copyWith(currentHp: enemyDefeated ? 0 : newEnemyHp);
    GameState newState = state.copyWith(
      enemy: updatedEnemy,
      message: msg,
    );

    if (enemyDefeated) {
      newState = newState.copyWith(
        gameOver: true,
        message: '$msg\nEnemy defeated! Press Next Fight to continue.',
      );
      emit(newState);
    } else {
      // Reset player's initiative and clear the turn.
      newState = newState.copyWith(
        currentTurn: Turn.none,
        playerInitiative: 0,
      );
      emit(newState);
    }
  }

  void _onDefend(DefendEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;

    Character updatedPlayer = state.player.copyWith(isDefending: true);
    String msg = 'You brace for the enemy attack!';
    // Reset player's initiative and clear the turn.
    GameState newState = state.copyWith(
      player: updatedPlayer,
      message: msg,
      currentTurn: Turn.none,
      playerInitiative: 0,
    );
    emit(newState);
  }

  void _onRun(RunEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;
    String msg = 'You ran away! Game Over.';
    emit(state.copyWith(gameOver: true, message: msg));
  }

  void _onOpenInventory(OpenInventoryEvent event, Emitter<GameState> emit) {
    String msg = 'Inventory opened. (Inventory logic not implemented)';
    emit(state.copyWith(message: msg));
  }

  void _onEnemyTurn(EnemyTurnEvent event, Emitter<GameState> emit) async {
    // Ensure it's enemy's turn.
    if (state.gameOver || state.currentTurn != Turn.enemy) return;
    await Future.delayed(const Duration(milliseconds: 300));

    // Enemy attacks: calculate damage based on enemy's strength vs player's endurance.
    int baseDamage =
        state.enemy.strength - state.player.endurance + _random.nextInt(5);
    int damage = baseDamage.clamp(0, 999);
    // If the player was defending, reduce damage.
    if (state.player.isDefending) {
      damage = (damage / 2).round();
    }
    int newPlayerHp = state.player.currentHp - damage;
    String msg = '${state.enemy.name} attacked you for $damage damage!';
    bool playerDefeated = newPlayerHp <= 0;
    Character updatedPlayer = state.player.copyWith(
        currentHp: playerDefeated ? 0 : newPlayerHp, isDefending: false);
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
      // Reset enemy initiative and clear turn so that tick events resume.
      newState = newState.copyWith(
        currentTurn: Turn.none,
        enemyInitiative: 0,
        message: '$msg\nWaiting for turn...',
      );
      emit(newState);
    }
  }

  void _onUseInventoryItem(
      UseInventoryItemEvent event, Emitter<GameState> emit) {
    if (event.itemName == 'Healing Potion') {
      int healAmount = 20;
      int newHp =
          (state.player.currentHp + healAmount).clamp(0, state.player.vitality);
      String msg =
          'Used Healing Potion. Recovered ${newHp - state.player.currentHp} HP.';
      Character updatedPlayer = state.player.copyWith(currentHp: newHp);
      emit(state.copyWith(player: updatedPlayer, message: msg));
    }
  }

  void _onNextFight(NextFightEvent event, Emitter<GameState> emit) {
    int newWinCounter = state.winCounter + 1;
    // Reset player's HP and initiative.
    final newPlayer = state.player.copyWith(currentHp: state.player.vitality);
    // Generate a new enemy based on the win counter (using your scaling logic).
    final newEnemy = generateEnemy(newWinCounter);
    String msg = 'New Fight! Wins: $newWinCounter\nWaiting for turn...';
    emit(state.copyWith(
      winCounter: newWinCounter,
      player: newPlayer,
      enemy: newEnemy,
      gameOver: false,
      currentTurn: Turn.none,
      message: msg,
      playerInitiative: 0,
      enemyInitiative: 0,
    ));
  }

  /// Generates a new enemy (with scaling and possible boss adjustments).
  Character generateEnemy(int winCounter) {
    bool isBoss = (winCounter > 0 && winCounter % 5 == 0);
    final normalNames = ['Goblin', 'Orc', 'Skeleton', 'Bandit'];
    final bossNames = ['Dragon', 'Demon Lord', 'Giant', 'Lich King'];
    String enemyName = isBoss
        ? bossNames[_random.nextInt(bossNames.length)]
        : normalNames[_random.nextInt(normalNames.length)];

    // Base stats for enemy.
    int baseVitality = 80;
    int baseStrength = 15;
    int baseEndurance = 5;
    int baseAgility = 10;
    // Difficulty factors.
    double normalFactor = 1.1;
    double bossFactor = 1.5;
    double factor = isBoss ? bossFactor : normalFactor;
    int multiplier = winCounter > 0 ? winCounter : 1;
    int vitality = (baseVitality * multiplier * factor).toInt();
    int strength = (baseStrength * multiplier * factor).toInt();
    int endurance = (baseEndurance * multiplier * factor).toInt();
    int agility = (baseAgility * multiplier * factor).toInt();

    return Character(
      name: enemyName,
      strength: strength,
      endurance: endurance,
      agility: agility,
      vitality: vitality,
      currentHp: vitality,
      isBoss: isBoss,
    );
  }
}
