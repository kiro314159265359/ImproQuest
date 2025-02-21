import 'package:flutter/material.dart';
import 'package:flutter_application_2/game/logic/shop_event.dart';
import 'package:flutter_application_2/game/shop_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import 'logic/shop_bloc.dart';
import 'turn_based_game.dart';
import 'logic/game_bloc.dart';
import 'logic/game_state.dart';
import 'logic/game_event.dart';
import 'viewmodel/game_view_model.dart';
import '../../game/components/temp_shop_widget.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final TurnBasedGame flameGame = TurnBasedGame();
  late GameViewModel viewModel;
  bool _temporaryShopOpened =
      false; // Ensure reward is dispatched only once per battle

  @override
  void initState() {
    super.initState();
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
    return Column(
      children: [
        Expanded(child: GameWidget(game: flameGame)),
        BlocListener<GameBloc, GameState>(
          listenWhen: (previous, current) =>
              previous.gameOver != current.gameOver ||
              previous.player.currentHp != current.player.currentHp ||
              previous.enemy.currentHp != current.enemy.currentHp ||
              previous.playerInitiative != current.playerInitiative ||
              previous.enemyInitiative != current.enemyInitiative,
          listener: (context, state) {

            flameGame.updateBars(state);
            // When battle ends and player is alive, dispatch reward and open shop.
            if (state.gameOver && state.player.currentHp > 0 && !_temporaryShopOpened) {
              _temporaryShopOpened = true;
              final shopBloc = getIt<ShopBloc>();
              // Reward the battle.
              shopBloc.add(RewardTemporaryGoldEvent(50));
              Future.delayed(const Duration(milliseconds: 300), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<ShopBloc>.value(
                      value: shopBloc,
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
        Column(
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
                  onPressed: state.currentTurn == Turn.player && !state.gameOver
                      ? viewModel.attack
                      : null,
                  child: const Text('Attack'),
                ),
                ElevatedButton(
                  onPressed: state.currentTurn == Turn.player && !state.gameOver
                      ? viewModel.defend
                      : null,
                  child: const Text('Defend'),
                ),
                ElevatedButton(
                  onPressed: state.currentTurn == Turn.player && !state.gameOver
                      ? viewModel.openInventory
                      : null,
                  child: const Text('Inventory'),
                ),
              ],
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
                'Player HP: ${state.player.currentHp}/${state.player.vitality}  |  Enemy HP: ${state.enemy.currentHp}/${state.enemy.vitality}  |  Ante: ${state.currentAnte}, Blind: ${state.currentBlind}${state.endlessMode ? " (Endless)" : ""}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shopBloc = getIt<ShopBloc>();
        shopBloc.add(ResetTemporaryGoldEvent());
        return true; // allow pop after resetting
      },
      child: BlocProvider<GameBloc>(
        create: (_) => GameBloc(),
        child: Scaffold(
          appBar: AppBar(title: const Text('Turn-Based Fight')),
          body: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              viewModel = GameViewModel(context.read<GameBloc>());
              final bloc = context.read<GameBloc>();
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
