import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_2/game/logic/shop_event.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/color_manger.dart';
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

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final TurnBasedGame flameGame = TurnBasedGame();
  late GameViewModel viewModel;
  late ShopBloc temporaryShopBloc;
  bool _temporaryShopOpened = false;

  @override
  void initState() {
    super.initState();
    temporaryShopBloc = ShopBloc(user: getIt<UserModel>());
  }

  @override
  void dispose() {
    temporaryShopBloc.close();
    super.dispose();
  }

  void _handleBattleReward(GameState state) {
    if (state.gameOver && state.player.currentHp > 0 && !_temporaryShopOpened) {
      _temporaryShopOpened = true;
      temporaryShopBloc
          .add(RewardTemporaryGoldEvent(GameConstants.battleRewardGold));

      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<ShopBloc>.value(
              value: temporaryShopBloc,
              child: const TemporaryShopPage(),
            ),
          ),
        ).then((_) {
          viewModel.nextFight();
        });
      });
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
          BlocProvider<GameBloc>(create: (_) {
            final bloc = GameBloc();
            // Connect the GameBloc to the Flame game
            flameGame.setGameBloc(bloc);
            return bloc;
          }),
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
                  viewModel = GameViewModel(context.read<GameBloc>());
                  return state.inFightMenu
                      ? GameMenuUI(
                          state: state,
                          bloc: context.read<GameBloc>(),
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
