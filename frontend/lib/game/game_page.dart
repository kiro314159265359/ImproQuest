import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/app_icons.dart';
import 'package:flutter_application_2/core/widget/dialogs.dart';
import 'package:flutter_application_2/game/logic/game_event.dart';
import 'package:flutter_application_2/game/logic/shop_event.dart';
import 'package:flutter_application_2/game/widgets/menu_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/color_manger.dart';
import '../core/theme/text_style.dart';
import '../core/utils/get_it_constants.dart';
import '../features/home/data/model/user_model.dart';
import 'logic/shop_bloc.dart';
import 'turn_based_game.dart';
import 'logic/game_bloc.dart';
import 'logic/game_state.dart';
import 'viewmodel/game_view_model.dart';
import '../../game/components/temp_shop_widget.dart';
import 'widgets/game_battle_ui.dart';
import 'widgets/game_menu_ui.dart';
import 'constants/game_constants.dart';
import 'services/audio_manager.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> with WidgetsBindingObserver {
  final TurnBasedGame flameGame = TurnBasedGame();
  late GameViewModel viewModel;
  late ShopBloc temporaryShopBloc;
  // Add a reference to store the GameBloc
  late GameBloc gameBloc;
  bool _temporaryShopOpened = false;
  final AudioManager _audioManager = AudioManager();
  bool _pendingTransition = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    temporaryShopBloc = ShopBloc(user: getIt<UserModel>());
    // Initialize the GameBloc here
    gameBloc = GameBloc();
    // Connect the GameBloc to the Flame game
    flameGame.setGameBloc(gameBloc);
    _audioManager.initialize();

    // Set up death animation completion handler
    flameGame.onDeathAnimationComplete = _handleDeathAnimationComplete;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioManager.stopBackgroundMusic();
    temporaryShopBloc.close();
    // Close the GameBloc when disposing
    gameBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle to properly manage audio
    if (state == AppLifecycleState.paused) {
      _audioManager.pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      _audioManager.resumeBackgroundMusic();
    }
  }

  // New method to handle when death animations complete
  void _handleDeathAnimationComplete() {
    print(
        'Death animation completion handler called, pending transition: $_pendingTransition');
    if (_pendingTransition) {
      setState(() {
        _pendingTransition = false;
      });
      print('Showing shop screen after death animation');
      // Add a small delay to ensure the state updates properly before transition
      Future.delayed(const Duration(milliseconds: 300), () {
        _showShopScreen();
      });
    }
  }

  // Extracted method to show shop screen
  void _showShopScreen() {
    print('Navigating to shop screen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<ShopBloc>.value(
          value: temporaryShopBloc,
          child: const TemporaryShopPage(),
        ),
      ),
    ).then((_) {
      print('Returned from shop, transitioning directly to menu');

      // Make sure we properly clean up old enemy state
      if (flameGame.enemy != null) {
        print('Cleaning up enemy from previous stage');
        if (flameGame.enemy!.statusContainer != null) {
          flameGame.enemy!.statusContainer!.removeFromParent();
        }
        flameGame.enemy!.removeFromParent();
        flameGame.enemy = null;
      }

      // Reset the cached game state to force UI updates
      flameGame.resetGameState();

      // Use the stored gameBloc reference instead of context.read
      gameBloc.add(ShowFightMenuEvent());

      // After a delay, then trigger the next fight setup
      Future.delayed(const Duration(milliseconds: 300), () {
        print('Setting up next fight data');
        viewModel.nextFight();
      });
    });
  }

  void _handleBattleReward(GameState state) {
    if (state.gameOver && state.player.currentHp > 0 && !_temporaryShopOpened) {
      print(
          'Battle ended, player won. Current animation playing: ${flameGame.isDeathAnimationPlaying}');

      // Mark shop as opened to prevent multiple transitions
      _temporaryShopOpened = true;

      Dialogs.noticeDialog(
        context: context,
        title: 'Victory!',
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You earned ',
              style: TextStyles.styleBold(context,
                  fontSize: 16, color: ColorManager.whiteColor),
            ),
            Image.asset(AppIcons.coinsIcon, width: 20, height: 20),
            Text(
              ' ${GameConstants.battleRewardGold}',
              style: TextStyles.styleBold(context,
                  fontSize: 16, color: ColorManager.whiteColor),
            ),
          ],
        ),
        onPressed: () {
          Navigator.of(context).pop();

          // Add reward after dialog is closed
          temporaryShopBloc
              .add(RewardTemporaryGoldEvent(GameConstants.battleRewardGold));

          // Ensure the reward is processed before showing shop
          Future.delayed(const Duration(milliseconds: 200), () {
            // Stop background music before navigating to shop
            _audioManager.stopBackgroundMusic();

            if (flameGame.isDeathAnimationPlaying) {
              print('Death animation in progress, setting pending transition');
              _pendingTransition = true;
            } else {
              print(
                  'No death animation in progress, proceeding to shop immediately');
              _showShopScreen();
            }
          });
        },
      );
    } else if (!state.gameOver) {
      _temporaryShopOpened = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        temporaryShopBloc.add(ResetTemporaryGoldEvent());
        return true;
      },
      child: MultiBlocProvider(
        providers: [
          // Ensure GameBloc is provided first
          BlocProvider<GameBloc>.value(value: gameBloc),
          BlocProvider<ShopBloc>.value(value: temporaryShopBloc),
        ],
        child: Scaffold(
          body: Stack(
            children: [
              IconButton(
                icon: const ImageIcon(
                  AssetImage('assets/icons/ExitIcon.png'),
                  color: ColorManager.whiteColor,
                  size: 35,
                ),
                onPressed: () {
                  Flame.device.restoreFullscreen();
                  Flame.device.setPortrait();
                  Navigator.of(context).pop();
                },
              ),
              BlocBuilder<GameBloc, GameState>(
                builder: (context, state) {
                  // Pass the ShopBloc to the GameViewModel
                  viewModel =
                      GameViewModel(gameBloc, shopBloc: temporaryShopBloc);

                  // Control music based on game state
                  if (!state.inFightMenu && !state.gameOver) {
                    // In battle - make sure music is playing
                    _audioManager.playBackgroundMusic();
                  } else if (state.inFightMenu || state.gameOver) {
                    // In menu or game over - stop music
                    _audioManager.stopBackgroundMusic();
                  }

                  return state.inFightMenu
                      ? GameMenuUI(
                          state: state,
                          bloc: gameBloc,
                        )
                      : GameBattleUI(
                          state: state,
                          flameGame: flameGame,
                          viewModel: viewModel,
                          onBattleEnd: _handleBattleReward,
                          onRestart: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const GamePage()),
                            );
                          },
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
