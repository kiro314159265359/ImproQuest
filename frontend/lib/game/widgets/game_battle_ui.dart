import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/game_button.dart';
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../logic/game_state.dart';
import '../turn_based_game.dart';
import '../viewmodel/game_view_model.dart';
import 'inventory_ui.dart'; // Ensure this import is present

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

        // Show message about current action
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Show action buttons when inventory is closed
        if (!state.inventoryOpen) _buildActionButtons(),

        // Show inventory UI when inventory is open
        if (state.inventoryOpen) InventoryUI(viewModel: viewModel),

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
          previous.lastAttackActor != current.lastAttackActor ||
          // Add this condition to detect enemy changes between stages
          previous.enemy.name != current.enemy.name ||
          previous.currentAnte != current.currentAnte ||
          previous.currentBlind != current.currentBlind,
      listener: (context, state) {
        // Update the enemy sprite when state changes (especially between stages)
        if (!state.inFightMenu && !state.gameOver) {
          print(
              'Battle UI detected new enemy: ${state.enemy.name}, Ante: ${state.currentAnte}, Blind: ${state.currentBlind}');
          flameGame.updateEnemy(state.enemy);
        }

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
