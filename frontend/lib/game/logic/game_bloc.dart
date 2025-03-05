import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/get_it_constants.dart';
import '../../features/home/data/model/user_model.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../models/character.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final Random _random = Random();
  Timer? _timer;
  static const double initiativeThreshold = 100.0;
  static const double tickDelta = 0.1;

  GameBloc() : super(GameState.initial(getIt<UserModel>())) {
    on<TickEvent>(_onTickEvent);
    on<AttackEvent>(_onAttack);
    on<DefendEvent>(_onDefend);
    on<OpenInventoryEvent>(_onOpenInventory);
    on<EnemyTurnEvent>(_onEnemyTurn);
    on<UseInventoryItemEvent>(_onUseInventoryItem);
    on<NextFightEvent>(_onNextFight);
    on<SelectBlindEvent>(_onSelectBlind);
    on<ClearAttackEvent>(_onClearAttack);

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      add(TickEvent());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _onTickEvent(TickEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.none || state.inFightMenu)
      return;

    double newPlayerInit =
        state.playerInitiative + state.player.agility * tickDelta;
    double newEnemyInit =
        state.enemyInitiative + state.enemy.agility * tickDelta;
    Turn newTurn = Turn.none;

    if (newPlayerInit >= initiativeThreshold ||
        newEnemyInit >= initiativeThreshold) {
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

    if (newTurn == Turn.enemy) {
      Future.delayed(const Duration(milliseconds: 300), () {
        add(EnemyTurnEvent());
      });
    }
  }

  void _onAttack(AttackEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;

    int damage =
        (state.player.strength - state.enemy.endurance + _random.nextInt(5))
            .clamp(0, 999);
    int newEnemyHp = state.enemy.currentHp - damage;
    String msg = 'You attacked ${state.enemy.name} for $damage damage!';
    bool enemyDefeated = newEnemyHp <= 0;
    Character updatedEnemy =
        state.enemy.copyWith(currentHp: enemyDefeated ? 0 : newEnemyHp);

    // Set lastAttackActor to "player"
    GameState newState = state.copyWith(
      enemy: updatedEnemy,
      message: msg,
      lastAttackActor: "player",
    );

    if (enemyDefeated) {
      newState = newState.copyWith(
        gameOver: true,
        message: '$msg\nEnemy defeated! Press Next Fight to continue.',
      );
      emit(newState);
    } else {
      // Preserve lastAttackActor when updating other properties
      newState = newState.copyWith(
        currentTurn: Turn.none,
        playerInitiative: 0,
        lastAttackActor: newState.lastAttackActor,
      );
      emit(newState);
    }
  }

  void _onDefend(DefendEvent event, Emitter<GameState> emit) {
    if (state.gameOver || state.currentTurn != Turn.player) return;
    Character updatedPlayer = state.player.copyWith(isDefending: true);
    String msg = 'You brace for the enemy attack!';
    GameState newState = state.copyWith(
      player: updatedPlayer,
      message: msg,
      currentTurn: Turn.none,
      playerInitiative: 0,
    );
    emit(newState);
  }

  void _onOpenInventory(OpenInventoryEvent event, Emitter<GameState> emit) {
    String msg = 'Inventory opened. (Inventory logic not implemented)';
    emit(state.copyWith(message: msg));
  }

  void _onEnemyTurn(EnemyTurnEvent event, Emitter<GameState> emit) async {
    if (state.gameOver || state.currentTurn != Turn.enemy) return;
    await Future.delayed(const Duration(milliseconds: 300));

    int baseDamage =
        state.enemy.strength - state.player.endurance + _random.nextInt(5);
    int damage = baseDamage.clamp(0, 999);
    if (state.player.isDefending) {
      damage = (damage / 2).round();
    }
    int newPlayerHp = state.player.currentHp - damage;
    String msg = '${state.enemy.name} attacked you for $damage damage!';
    bool playerDefeated = newPlayerHp <= 0;
    Character updatedPlayer = state.player.copyWith(
      currentHp: playerDefeated ? 0 : newPlayerHp,
      isDefending: false,
    );
    GameState newState = state.copyWith(
      player: updatedPlayer,
      message: msg,
      lastAttackActor: "enemy",
    );

    if (playerDefeated) {
      newState = newState.copyWith(
        gameOver: true,
        message: '$msg\nYou have been defeated. Game Over.',
      );
      emit(newState);
    } else {
      // Preserve lastAttackActor for the animation to trigger
      newState = newState.copyWith(
        currentTurn: Turn.none,
        enemyInitiative: 0,
        message: '$msg\nWaiting for turn...',
        lastAttackActor: newState.lastAttackActor,
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

  void _onSelectBlind(SelectBlindEvent event, Emitter<GameState> emit) {
    if (!state.inFightMenu) return;
    final newEnemy = generateEnemy(state.currentAnte, event.blind);
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
    int newAnte = state.currentAnte;
    int newBlind = state.currentBlind;
    bool endlessMode = state.endlessMode;

    if (state.enemy.currentHp <= 0) {
      if (state.currentBlind < 3) {
        newBlind = state.currentBlind + 1;
      } else {
        if (!state.endlessMode) {
          if (state.currentAnte < 8) {
            newAnte = state.currentAnte + 1;
            newBlind = 1;
          } else if (state.currentAnte == 8) {
            endlessMode = true;
            newAnte = state.currentAnte + 1;
            newBlind = 1;
          }
        } else {
          newAnte = state.currentAnte + 1;
          newBlind = 1;
        }
      }
    }

    final newPlayer = state.player.copyWith(currentHp: state.player.vitality);
    String msg = 'Ante $newAnte, completed blinds: ';
    for (int i = 1; i < newBlind; i++) {
      msg += 'Blind $i, ';
    }
    msg += 'Select next blind to fight.';

    emit(state.copyWith(
      currentAnte: newAnte,
      currentBlind: newBlind,
      endlessMode: endlessMode,
      player: newPlayer,
      gameOver: false,
      currentTurn: Turn.none,
      message: msg,
      inFightMenu: true,
      playerInitiative: 0,
      enemyInitiative: 0,
    ));
  }

  Character generateEnemy(int currentAnte, int currentBlind) {
    bool isBoss = currentBlind == 3;
    bool isBig = currentBlind == 2;
    List<String> smallNames = ['Goblin', 'Skeleton', 'Bandit'];
    List<String> bigNames = ['Orc', 'Troll', 'Warrior'];
    List<String> bossNames = ['Dragon', 'Demon Lord', 'Giant', 'Lich King'];
    String enemyName;
    if (isBoss) {
      enemyName = bossNames[_random.nextInt(bossNames.length)];
    } else if (isBig) {
      enemyName = bigNames[_random.nextInt(bigNames.length)];
    } else {
      enemyName = smallNames[_random.nextInt(smallNames.length)];
    }

    int baseVitality, baseStrength, baseEndurance, baseAgility, level;
    if (isBoss) {
      baseVitality = 100;
      baseStrength = 25;
      baseEndurance = 10;
      baseAgility = 10;
      level = 5;
    } else if (isBig) {
      baseVitality = 80;
      baseStrength = 20;
      baseEndurance = 8;
      baseAgility = 12;
      level = 3;
    } else {
      baseVitality = 60;
      baseStrength = 1;
      baseEndurance = 5;
      baseAgility = 100;
      level = 2;
    }

    int vitality = baseVitality * currentAnte;
    int strength = baseStrength * currentAnte;
    int endurance = baseEndurance * currentAnte;
    int agility = baseAgility * currentAnte;
    int lvl = level * currentAnte;

    return Character(
      name: enemyName,
      level: lvl,
      strength: strength,
      endurance: endurance,
      agility: agility,
      vitality: vitality,
      currentHp: vitality,
      isBoss: isBoss,
    );
  }

  void _onClearAttack(ClearAttackEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(lastAttackActor: null));
  }
}
