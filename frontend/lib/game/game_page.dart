import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/game/components/game_button.dart';
import 'package:flutter_application_2/game/logic/shop_event.dart';
import 'package:flutter_application_2/game/shop_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import '../core/theme/color_manger.dart';
import '../core/utils/get_it_constants.dart';
import '../features/home/data/model/user_model.dart';
import 'logic/shop_bloc.dart';
import 'turn_based_game.dart';
import 'logic/game_bloc.dart';
import 'logic/game_state.dart';
import 'logic/game_event.dart';
import 'viewmodel/game_view_model.dart';
import '../../game/components/temp_shop_widget.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final TurnBasedGame flameGame = TurnBasedGame();
  late GameViewModel viewModel;
  late ShopBloc temporaryShopBloc;
  bool _temporaryShopOpened =
      false; // Ensure reward is dispatched only once per battle

  @override
  void initState() {
    super.initState();
    temporaryShopBloc = ShopBloc(user: getIt<UserModel>());
  }

  @override
  void dispose() {
    // Dispose the ShopBloc when the game ends.
    temporaryShopBloc.close();
    super.dispose();
  }

  // Helper method to build enemy preview card for a blind.
  Widget buildBlindCard(
      GameBloc bloc, int blind, int currentAnte, int currentBlind) {
    bool isBoss = blind == 3;
    bool isBig = blind == 2;
    String enemyType;
    int baseVitality, baseStrength, baseEndurance, baseAgility;
    if (isBoss) {
      enemyType = 'Boss';
      baseVitality = 100;
      baseStrength = 25;
      baseEndurance = 10;
      baseAgility = 10;
    } else if (isBig) {
      enemyType = 'Big Enemy';
      baseVitality = 80;
      baseStrength = 20;
      baseEndurance = 8;
      baseAgility = 12;
    } else {
      enemyType = 'Small Enemy';
      baseVitality = 60;
      baseStrength = 15;
      baseEndurance = 5;
      baseAgility = 10;
    }
    int vitality = baseVitality * currentAnte;
    int strength = baseStrength * currentAnte;
    int endurance = baseEndurance * currentAnte;
    int agility = baseAgility * currentAnte;

    bool isCompleted = blind < currentBlind;
    bool isAvailable = blind == currentBlind;

    return Card(
      color: isCompleted ? Colors.grey[300] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Blind $blind: $enemyType',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.grey : Colors.black,
                )),
            Text(
              'Vitality: $vitality, Strength: $strength, Endurance: $endurance, Agility: $agility',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: isAvailable
                  ? () {
                      bloc.add(SelectBlindEvent(blind));
                    }
                  : null,
              child: const Text('Fight'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenu(GameState state, GameBloc bloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Current Ante: ${state.currentAnte}',
            style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        Text(
          'Player Stats:\nHP: ${state.player.currentHp}/${state.player.vitality}\nStrength: ${state.player.strength}  Endurance: ${state.player.endurance}  Agility: ${state.player.agility}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        const Text('Select a Blind to Fight:', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: buildBlindCard(
                    bloc, 1, state.currentAnte, state.currentBlind)),
            Expanded(
                child: buildBlindCard(
                    bloc, 2, state.currentAnte, state.currentBlind)),
            Expanded(
                child: buildBlindCard(
                    bloc, 3, state.currentAnte, state.currentBlind)),
          ],
        ),
        const SizedBox(height: 24),
        Text(state.message,
            style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ShopPage()),
            );
          },
          child: const Text('Permanent Shop'),
        ),
      ],
    );
  }

  Widget buildFightUI(GameState state) {
    return Stack(
      children: [
        Positioned.fill(
          child: GameWidget(game: flameGame),
        ),
        BlocListener<GameBloc, GameState>(
          listenWhen: (previous, current) =>
              previous.gameOver != current.gameOver ||
              previous.player.currentHp != current.player.currentHp ||
              previous.enemy.currentHp != current.enemy.currentHp ||
              previous.playerInitiative != current.playerInitiative ||
              previous.enemyInitiative != current.enemyInitiative ||
              previous.lastAttackActor !=
                  current.lastAttackActor, // added condition
          listener: (context, state) {
            flameGame.updateBars(state);
            // Trigger attack animation if needed.
            if (state.lastAttackActor == "player") {
              flameGame.playAttackAnimationForHero();
              print("Animation player played");
              context.read<GameBloc>().add(ClearAttackEvent());
            } else if (state.lastAttackActor == "enemy") {
              flameGame.playAttackAnimationForEnemy();
              print("Animation player played");
              context.read<GameBloc>().add(ClearAttackEvent());
            }
            // When battle ends and player is alive, dispatch reward and open shop.
            if (state.gameOver &&
                state.player.currentHp > 0 &&
                !_temporaryShopOpened) {
              _temporaryShopOpened = true;
              // Reward the battle.
              temporaryShopBloc.add(RewardTemporaryGoldEvent(50));
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
                  // Continue to the next fight without resetting the gold.
                  viewModel.nextFight();
                });
              });
            } else if (!state.gameOver) {
              _temporaryShopOpened = false;
            }
          },
          child: Container(),
        ),
        Positioned(
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
                        onPressed:
                            state.currentTurn == Turn.player && !state.gameOver
                                ? viewModel.attack
                                : null,
                        width: 140,
                        height: 50),
                    GameButton(
                        text: "Defend",
                        onPressed:
                            state.currentTurn == Turn.player && !state.gameOver
                                ? viewModel.defend
                                : null,
                        width: 140,
                        height: 50),
                  ],
                ),
                const SizedBox(height: 25),
                GameButton(
                    text: "Inventory",
                    onPressed:
                        state.currentTurn == Turn.player && !state.gameOver
                            ? viewModel.openInventory
                            : null,
                    width: 320,
                    height: 50),
              ],
            ),
          ),
        ),
        if (state.gameOver && state.player.currentHp == 0)
          GameButton(
              text: "Restart",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GamePage()),
                );
              },
              width: 320,
              height: 50),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Optionally, reset temporary shop state here if needed.
        temporaryShopBloc.add(ResetTemporaryGoldEvent());
        return true;
      },
      child: MultiBlocProvider(
        providers: [
          // Provide the game bloc as usual.
          BlocProvider<GameBloc>(
            create: (_) => GameBloc(),
          ),
          // The temporary shop bloc is provided for this game session.
          BlocProvider<ShopBloc>.value(value: temporaryShopBloc),
        ],
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
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
            title: const Text('Turn-Based Fight'),
            centerTitle: true,
          ),
          body: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              viewModel = GameViewModel(context.read<GameBloc>());
              final bloc = context.read<GameBloc>();
              // Choose between the fight UI and the menu based on state.
              return state.inFightMenu
                  ? Center(child: buildMenu(state, bloc))
                  : buildFightUI(state);
            },
          ),
        ),
      ),
    );
  }
}
