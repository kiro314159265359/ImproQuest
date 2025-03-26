import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/game_button.dart';
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../logic/game_state.dart';
import '../turn_based_game.dart';
import '../viewmodel/game_view_model.dart';

class GameBattleUI extends StatelessWidget {
  final GameState state;
  final TurnBasedGame flameGame;
  final GameViewModel viewModel;
  final Function(GameState) onBattleEnd;
  final VoidCallback onRestart;

  const GameBattleUI({
    super.key,
    required this.state,
    required this.flameGame,
    required this.viewModel,
    required this.onBattleEnd,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GameWidget(game: flameGame),
        ),
        _buildBattleListener(context),
        _buildActionButtons(),
        if (state.gameOver && state.player.currentHp == 0)
          Center(
            child: GameButton(
              text: "Restart",
              onPressed: onRestart,
              width: 320,
              height: 50,
            ),
          ),
      ],
    );
  }

  Widget _buildBattleListener(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listenWhen: (previous, current) =>
          previous.gameOver != current.gameOver ||
          previous.player.currentHp != current.player.currentHp ||
          previous.enemy.currentHp != current.enemy.currentHp ||
          previous.playerInitiative != current.playerInitiative ||
          previous.enemyInitiative != current.enemyInitiative ||
          previous.lastAttackActor != current.lastAttackActor,
      listener: (context, state) {
        flameGame.updateBars(state);

        if (state.lastAttackActor == "player") {
          flameGame.playAttackAnimationForHero(onComplete: () {
            context.read<GameBloc>().add(FinalizeAttackEvent(true));
          });
        } else if (state.lastAttackActor == "enemy") {
          flameGame.playAttackAnimationForEnemy(onComplete: () {
            context.read<GameBloc>().add(FinalizeAttackEvent(false));
          });
        }

        // Always call onBattleEnd to set up pending transitions
        // (the GamePage will handle whether to show UI immediately or wait)
        onBattleEnd(state);
      },
      child: Container(),
    );
  }

  Widget _buildActionButtons() {
    final bool canAct = state.currentTurn == Turn.player && !state.gameOver;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GameButton(
                  text: "Attack",
                  onPressed: canAct
                      ? () {
                          viewModel.attack();
                        }
                      : null,
                  width: 140,
                  height: 50,
                ),
                GameButton(
                  text: "Defend",
                  onPressed: canAct
                      ? () {
                          viewModel.defend();
                        }
                      : null,
                  width: 140,
                  height: 50,
                ),
              ],
            ),
            const SizedBox(height: 25),
            GameButton(
              text: "Inventory",
              onPressed: canAct
                  ? () {
                      viewModel.openInventory();
                    }
                  : null,
              width: 320,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
