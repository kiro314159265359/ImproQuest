import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/get_it_constants.dart';
import '../../features/home/data/model/user_model.dart';
import '../services/combat_service.dart';
import '../services/enemy_service.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../models/character.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final CombatService _combatService = CombatService();
  final EnemyService _enemyService = EnemyService();
  static const double initiativeThreshold = 100.0;

  // Store calculated combat results for later use after animation
  CombatResult? _pendingCombatResult;

  GameBloc() : super(GameState.initial(getIt<UserModel>())) {
    // Remove TickEvent handler
    on<AttackEvent>(_onAttack);
    on<DefendEvent>(_onDefend);
    on<OpenInventoryEvent>(_onOpenInventory);
    on<EnemyTurnEvent>(_onEnemyTurn);
    on<UseInventoryItemEvent>(_onUseInventoryItem);
    on<NextFightEvent>(_onNextFight);
    on<SelectBlindEvent>(_onSelectBlind);
    on<ClearAttackEvent>(_onClearAttack);
    on<FinalizeAttackEvent>(_onFinalizeAttack);
  }

  // New method to be called from Flame's update loop
  void updateInitiative(double dt) {
    if (state.gameOver || state.currentTurn != Turn.none || state.inFightMenu) {
      return;
    }

    double newPlayerInit = state.playerInitiative + state.player.agility * dt;
    double newEnemyInit = state.enemyInitiative + state.enemy.agility * dt;
    Turn newTurn = _determineNextTurn(newPlayerInit, newEnemyInit);

    if (newTurn != Turn.none) {
      if (newTurn == Turn.player) {
        newPlayerInit -= initiativeThreshold;
      } else {
        newEnemyInit -= initiativeThreshold;
      }
    }

    emit(state.copyWith(
      playerInitiative: newPlayerInit,
      enemyInitiative: newEnemyInit,
      currentTurn: newTurn,
    ));

    if (newTurn == Turn.enemy) {
      _scheduleEnemyAction();
    }
  }

  Turn _determineNextTurn(double playerInit, double enemyInit) {
    if (playerInit >= initiativeThreshold || enemyInit >= initiativeThreshold) {
      return playerInit >= enemyInit ? Turn.player : Turn.enemy;
    }
    return Turn.none;
  }

  void _scheduleEnemyAction() {
    Future.delayed(const Duration(milliseconds: 300), () {
      add(EnemyTurnEvent());
    });
  }

  void _onAttack(AttackEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;

    _pendingCombatResult = _combatService.prepareAttack(
      attackerName: state.player.name,
      attackerStrength: state.player.strength,
      defenderEndurance: state.enemy.endurance,
      defenderCurrentHp: state.enemy.currentHp,
    );

    // Trigger animation
    emit(state.copyWith(lastAttackActor: "player"));
  }

  void _onDefend(DefendEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;

    Character updatedPlayer = state.player.copyWith(isDefending: true);
    String msg = 'You brace for the enemy attack!';

    emit(state.copyWith(
      player: updatedPlayer,
      message: msg,
      currentTurn: Turn.none,
      playerInitiative: 0,
    ));
  }

  void _onOpenInventory(OpenInventoryEvent event, Emitter<GameState> emit) {
    String msg = 'Inventory opened. (Inventory logic not implemented)';
    emit(state.copyWith(message: msg));
  }

  void _onEnemyTurn(EnemyTurnEvent event, Emitter<GameState> emit) async {
    if (state.gameOver || state.currentTurn != Turn.enemy) return;
    await Future.delayed(const Duration(milliseconds: 300));

    _pendingCombatResult = _combatService.prepareAttack(
      attackerName: state.enemy.name,
      attackerStrength: state.enemy.strength,
      defenderEndurance: state.player.endurance,
      defenderCurrentHp: state.player.currentHp,
      isDefending: state.player.isDefending,
    );

    // Trigger animation
    emit(state.copyWith(lastAttackActor: "enemy"));
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

  void _onSelectBlind(SelectBlindEvent event, Emitter<GameState> emit) {
    if (!state.inFightMenu) return;

    final newEnemy =
        _enemyService.generateEnemy(state.currentAnte, event.blind);
    emit(state.copyWith(
      enemy: newEnemy,
      inFightMenu: false,
      message: 'Fight started: Ante ${state.currentAnte}, Blind ${event.blind}',
      playerInitiative: 0,
      enemyInitiative: 0,
      currentTurn: Turn.none,
    ));
  }

  void _onNextFight(NextFightEvent event, Emitter<GameState> emit) {
    final nextFightState = _calculateNextFightState();

    final newPlayer = state.player.copyWith(currentHp: state.player.vitality);
    String msg = _generateNextFightMessage(
        nextFightState['ante']!, nextFightState['blind']!);

    emit(state.copyWith(
      currentAnte: nextFightState['ante']!,
      currentBlind: nextFightState['blind']!,
      endlessMode: nextFightState['endlessMode'] as bool, // Fix: cast to bool
      player: newPlayer,
      gameOver: false,
      currentTurn: Turn.none,
      message: msg,
      inFightMenu: true,
      playerInitiative: 0,
      enemyInitiative: 0,
    ));
  }

  Map<String, dynamic> _calculateNextFightState() {
    // Changed return type to Map<String, dynamic>
    int newAnte = state.currentAnte;
    int newBlind = state.currentBlind;
    bool newEndlessMode = state.endlessMode;

    if (state.enemy.currentHp <= 0) {
      if (state.currentBlind < 3) {
        newBlind++;
      } else {
        if (!state.endlessMode) {
          if (state.currentAnte < 8) {
            newAnte++;
            newBlind = 1;
          } else if (state.currentAnte == 8) {
            newEndlessMode = true;
            newAnte++;
            newBlind = 1;
          }
        } else {
          newAnte++;
          newBlind = 1;
        }
      }
    }

    return {
      'ante': newAnte,
      'blind': newBlind,
      'endlessMode': newEndlessMode, // Return boolean directly
    };
  }

  String _generateNextFightMessage(int ante, int blind) {
    String msg = 'Ante $ante, completed blinds: ';
    for (int i = 1; i < blind; i++) {
      msg += 'Blind $i, ';
    }
    msg += 'Select next blind to fight.';
    return msg;
  }

  void _onClearAttack(ClearAttackEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(lastAttackActor: null));
  }

  void _onFinalizeAttack(FinalizeAttackEvent event, Emitter<GameState> emit) {
    if (_pendingCombatResult == null) return;

    if (event.isPlayerAttack) {
      _finalizePlayerAttack(emit);
    } else {
      _finalizeEnemyAttack(emit);
    }

    // Clear pending result after processing
    _pendingCombatResult = null;
  }

  void _finalizePlayerAttack(Emitter<GameState> emit) {
    int newEnemyHp = _pendingCombatResult!.targetDefeated
        ? 0
        : state.enemy.currentHp - _pendingCombatResult!.damage;

    Character updatedEnemy = state.enemy.copyWith(currentHp: newEnemyHp);
    String message = _pendingCombatResult!.message;

    if (_pendingCombatResult!.targetDefeated) {
      message = '$message\nEnemy defeated! Press Next Fight to continue.';
    }

    emit(state.copyWith(
      enemy: updatedEnemy,
      message: message,
      gameOver: _pendingCombatResult!.targetDefeated,
      currentTurn:
          _pendingCombatResult!.targetDefeated ? state.currentTurn : Turn.none,
      playerInitiative:
          _pendingCombatResult!.targetDefeated ? state.playerInitiative : 0,
      lastAttackActor: null,
    ));
  }

  void _finalizeEnemyAttack(Emitter<GameState> emit) {
    int newPlayerHp = _pendingCombatResult!.targetDefeated
        ? 0
        : state.player.currentHp - _pendingCombatResult!.damage;

    Character updatedPlayer = state.player.copyWith(
      currentHp: newPlayerHp,
      isDefending: false,
    );

    String message = _pendingCombatResult!.message;
    if (_pendingCombatResult!.targetDefeated) {
      message = '$message\nYou have been defeated. Game Over.';
    } else {
      message = '$message\nWaiting for turn...';
    }

    emit(state.copyWith(
      player: updatedPlayer,
      message: message,
      gameOver: _pendingCombatResult!.targetDefeated,
      currentTurn:
          _pendingCombatResult!.targetDefeated ? state.currentTurn : Turn.none,
      enemyInitiative:
          _pendingCombatResult!.targetDefeated ? state.enemyInitiative : 0,
      lastAttackActor: null,
    ));
  }
}
