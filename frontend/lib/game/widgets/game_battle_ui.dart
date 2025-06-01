import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/game/widgets/temporary_inventory_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/core/utils/app_icons.dart';
import 'package:flutter_application_2/core/widget/dialogs.dart';
import 'package:flame/flame.dart';
import '../components/game_button.dart';
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../logic/game_state.dart';
import '../services/audio_manager.dart';
import '../turn_based_game.dart';
import '../viewmodel/game_view_model.dart';
import '../logic/shop_bloc.dart';
import '../logic/shop_event.dart';

class GameBattleUI extends StatelessWidget {
  final GameState state;
  final TurnBasedGame flameGame;
  final GameViewModel viewModel;
  final Function(GameState) onBattleEnd;
  final VoidCallback onRestart;
  final AudioManager audioManager;

  const GameBattleUI({
    super.key,
    required this.state,
    required this.flameGame,
    required this.viewModel,
    required this.onBattleEnd,
    required this.onRestart,
    required this.audioManager,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Positioned.fill(
          child: GameWidget(game: flameGame),
        ),
        _buildBattleListener(context),

        Positioned(
          top: 1,
          left: 1,
          child: IconButton(
            icon: const ImageIcon(
              AssetImage(AppIcons.exitIcon),
              color: ColorManager.whiteColor,
              size: 32,
            ),
            onPressed: () {
              Dialogs.confirmDialog(
                context: context,
                title: 'Exit Game',
                content: 'Are you sure you want to exit the game?',
                onPressed: () {
                  audioManager.stopBackgroundMusic();
                  context.read<ShopBloc>().add(ResetTemporaryGoldEvent());
                  Flame.device.restoreFullscreen();
                  Flame.device.setPortrait();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),

        // Show message about current action
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              color: ColorManager.blackColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.message,
              style: TextStyles.regular16White,
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Show action buttons when inventory is closed
        if (!state.inventoryOpen) _buildActionButtons(context),

        // Show inventory UI when inventory is open
        if (state.inventoryOpen) TemporaryInventoryUi(viewModel: viewModel),

        if (state.gameOver && state.player.currentHp == 0)
          Center(
            child: GameButton(
              text: "Restart",
              onPressed: onRestart,
              width: screenWidth * 0.7,
              height: screenHeight * 0.065,
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
          previous.enemy.name != current.enemy.name ||
          previous.currentAnte != current.currentAnte ||
          previous.currentBlind != current.currentBlind,
      listener: (context, state) {
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

        onBattleEnd(state);
      },
      child: Container(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool canAct = state.currentTurn == Turn.player && !state.gameOver;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      bottom: screenHeight * 0.03,
      left: screenWidth * 0.05,
      right: screenWidth * 0.05,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(bottom: screenHeight * 0.015),
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
                  width: screenWidth * 0.38,
                  height: screenHeight * 0.065,
                ),
                GameButton(
                  text: "Defend",
                  onPressed: canAct
                      ? () {
                          viewModel.defend();
                        }
                      : null,
                  width: screenWidth * 0.38,
                  height: screenHeight * 0.065,
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            GameButton(
              text: "Inventory",
              onPressed: canAct
                  ? () {
                      viewModel.openInventory();
                    }
                  : null,
              width: screenWidth * 0.8,
              height: screenHeight * 0.065,
            ),
          ],
        ),
      ),
    );
  }
}
