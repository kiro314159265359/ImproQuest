import '../../features/home/data/model/user_model.dart';
import '../models/character.dart';

enum Turn { none, player, enemy }

class GameState {
  final Character player;
  final Character enemy;
  final Turn currentTurn;
  final bool gameOver;
  final String message;
  final int currentAnte;
  final int currentBlind;
  final bool endlessMode;
  final bool inFightMenu;
  final double playerInitiative;
  final double enemyInitiative;

  GameState({
    required this.player,
    required this.enemy,
    required this.currentTurn,
    this.gameOver = false,
    this.message = '',
    required this.currentAnte,
    required this.currentBlind,
    this.endlessMode = false,
    this.inFightMenu = true,
    this.playerInitiative = 0,
    this.enemyInitiative = 0,
  });

  GameState copyWith({
    Character? player,
    Character? enemy,
    Turn? currentTurn,
    bool? gameOver,
    String? message,
    int? currentAnte,
    int? currentBlind,
    bool? endlessMode,
    bool? inFightMenu,
    double? playerInitiative,
    double? enemyInitiative,
  }) {
    return GameState(
      player: player ?? this.player,
      enemy: enemy ?? this.enemy,
      currentTurn: currentTurn ?? this.currentTurn,
      gameOver: gameOver ?? this.gameOver,
      message: message ?? this.message,
      currentAnte: currentAnte ?? this.currentAnte,
      currentBlind: currentBlind ?? this.currentBlind,
      endlessMode: endlessMode ?? this.endlessMode,
      inFightMenu: inFightMenu ?? this.inFightMenu,
      playerInitiative: playerInitiative ?? this.playerInitiative,
      enemyInitiative: enemyInitiative ?? this.enemyInitiative,
    );
  }

  factory GameState.initial(UserModel user) {
    return GameState(
      player: Character(
        name: user.username ?? 'Hero',
        strength: user.stats?.strength ?? 20,
        endurance: user.stats?.endurance ?? 10,
        agility: user.stats?.agility ?? 15,
        vitality: user.stats?.vitality ?? 100,
        currentHp: 100,
      ),
      // player: Character(
      //   name: 'Hero',
      //   strength: 99999,
      //   endurance: 9999,
      //   agility: 9999,
      //   vitality: 9999,
      //   currentHp: 9999,
      // ),
      enemy: Character(
        name: 'Goblin',
        strength: 15,
        endurance: 5,
        agility: 10,
        vitality: 60,
        currentHp: 60,
      ),
      currentTurn: Turn.none,
      gameOver: false,
      message: 'Select a blind to begin the fight.',
      currentAnte: 1,
      currentBlind: 1,
      endlessMode: false,
      inFightMenu: true,
      playerInitiative: 0,
      enemyInitiative: 0,
    );
  }
}
