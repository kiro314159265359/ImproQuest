// lib/game/logic/game_state.dart
import '../models/character.dart';

enum Turn { player, enemy }

class GameState {
  final Character player;
  final Character enemy;
  final Turn currentTurn;
  final bool gameOver;
  final String message;

  GameState({
    required this.player,
    required this.enemy,
    required this.currentTurn,
    this.gameOver = false,
    this.message = '',
  });

  GameState copyWith({
    Character? player,
    Character? enemy,
    Turn? currentTurn,
    bool? gameOver,
    String? message,
  }) {
    return GameState(
      player: player ?? this.player,
      enemy: enemy ?? this.enemy,
      currentTurn: currentTurn ?? this.currentTurn,
      gameOver: gameOver ?? this.gameOver,
      message: message ?? this.message,
    );
  }

  factory GameState.initial() {
    return GameState(
      player: Character(name: 'Hero', maxHp: 100, currentHp: 100, attack: 20, defense: 10),
      enemy: Character(name: 'Goblin', maxHp: 80, currentHp: 80, attack: 15, defense: 5),
      currentTurn: Turn.player,
      gameOver: false,
      message: 'Your turn!',
    );
  }
}
