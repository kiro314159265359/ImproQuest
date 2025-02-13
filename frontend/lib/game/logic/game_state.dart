// lib/game/logic/game_state.dart
import '../models/character.dart';

enum Turn { none, player, enemy }

class GameState {
  final Character player;
  final Character enemy;
  final Turn currentTurn;
  final bool gameOver;
  final String message;
  final int winCounter;
  final double playerInitiative;
  final double enemyInitiative;

  GameState({
    required this.player,
    required this.enemy,
    required this.currentTurn,
    this.gameOver = false,
    this.message = '',
    this.winCounter = 0,
    this.playerInitiative = 0,
    this.enemyInitiative = 0,
  });

  GameState copyWith({
    Character? player,
    Character? enemy,
    Turn? currentTurn,
    bool? gameOver,
    String? message,
    int? winCounter,
    double? playerInitiative,
    double? enemyInitiative,
  }) {
    return GameState(
      player: player ?? this.player,
      enemy: enemy ?? this.enemy,
      currentTurn: currentTurn ?? this.currentTurn,
      gameOver: gameOver ?? this.gameOver,
      message: message ?? this.message,
      winCounter: winCounter ?? this.winCounter,
      playerInitiative: playerInitiative ?? this.playerInitiative,
      enemyInitiative: enemyInitiative ?? this.enemyInitiative,
    );
  }

  factory GameState.initial() {
    return GameState(
      player: Character(
        name: 'Hero',
        strength: 20,
        endurance: 10,
        agility: 15, // Higher agility means faster filling
        vitality: 100,
        currentHp: 100,
      ),
      enemy: Character(
        name: 'Goblin',
        strength: 15,
        endurance: 5,
        agility: 10,
        vitality: 80,
        currentHp: 80,
      ),
      currentTurn: Turn.none,
      gameOver: false,
      message: 'Waiting for turn...',
      winCounter: 0,
      playerInitiative: 0,
      enemyInitiative: 0,
    );
  }
}
