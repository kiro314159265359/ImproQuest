// lib/game/game_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import 'turn_based_game.dart';
import 'logic/game_bloc.dart';
import 'logic/game_state.dart';
import 'viewmodel/game_view_model.dart';

class GamePage extends StatelessWidget {
  final TurnBasedGame flameGame = TurnBasedGame();

  GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      create: (_) => GameBloc(), // Ensure GameBloc is properly instantiated
      child: Scaffold(
        appBar: AppBar(title: const Text('Turn-Based Fight')),
        body: Column(
          children: [
            // The Flame game canvas occupies the top portion of the screen.
            Expanded(
              child: GameWidget(game: flameGame),
            ),
            // The lower area has the game messages, action buttons, and HP displays.
            BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                final viewModel =
                    GameViewModel(BlocProvider.of<GameBloc>(context));
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        state.message,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: state.currentTurn == Turn.player &&
                                  !state.gameOver
                              ? viewModel.attack
                              : null,
                          child: const Text('Attack'),
                        ),
                        ElevatedButton(
                          onPressed: state.currentTurn == Turn.player &&
                                  !state.gameOver
                              ? viewModel.defend
                              : null,
                          child: const Text('Defend'),
                        ),
                        ElevatedButton(
                          onPressed: state.currentTurn == Turn.player &&
                                  !state.gameOver
                              ? viewModel.run
                              : null,
                          child: const Text('Run'),
                        ),
                        ElevatedButton(
                          onPressed: state.currentTurn == Turn.player &&
                                  !state.gameOver
                              ? viewModel.openInventory
                              : null,
                          child: const Text('Inventory'),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Player HP: ${state.player.currentHp}/${state.player.maxHp}  |  Enemy HP: ${state.enemy.currentHp}/${state.enemy.maxHp}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
