// lib/game/game_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import 'turn_based_game.dart';
import 'logic/game_bloc.dart';
import 'logic/game_state.dart';
import 'viewmodel/game_view_model.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final TurnBasedGame flameGame = TurnBasedGame();
  late GameViewModel viewModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      create: (_) => GameBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Turn-Based Fight')),
        body: Column(
          children: [
            // Flame game canvas.
            Expanded(child: GameWidget(game: flameGame)),
            // Listen to state changes to update the progress bars.
            BlocListener<GameBloc, GameState>(
              listener: (context, state) {
                flameGame.updateBars(state);
              },
              child: Container(),
            ),
            // Your usual controls and messages.
            BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                viewModel = GameViewModel(BlocProvider.of<GameBloc>(context));
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
                    if (state.gameOver && state.player.currentHp > 0)
                      ElevatedButton(
                        onPressed: () {
                          viewModel.nextFight();
                        },
                        child: const Text('Next Fight'),
                      ),
                    if (state.gameOver && state.player.currentHp == 0)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const GamePage()),
                          );
                        },
                        child: const Text('Restart'),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Player HP: ${state.player.currentHp}/${state.player.vitality}  |  Enemy HP: ${state.enemy.currentHp}/${state.enemy.vitality}  |  Wins: ${state.winCounter}',
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
