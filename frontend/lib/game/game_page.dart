import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import 'turn_based_game.dart';
import 'logic/game_bloc.dart';
import 'logic/game_state.dart';
import 'logic/game_event.dart';
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

  // Helper method to build enemy preview card for a blind.
  Widget buildBlindCard(GameBloc bloc, int blind, int currentAnte, int currentBlind) {
    // Determine enemy type and base stats based on blind.
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

    // Determine if this blind is available to select.
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
            Text('Vitality: $vitality, Strength: $strength, Endurance: $endurance, Agility: $agility',style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),),
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
        Text('Current Ante: ${state.currentAnte}', style: const TextStyle(fontSize: 24)),
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
            Expanded(child: buildBlindCard(bloc, 1, state.currentAnte, state.currentBlind)),
            Expanded(child: buildBlindCard(bloc, 2, state.currentAnte, state.currentBlind)),
            Expanded(child: buildBlindCard(bloc, 3, state.currentAnte, state.currentBlind)),
          ],
        ),
        const SizedBox(height: 24),
        Text(state.message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
      ],
    );
  }

  Widget buildFightUI(GameState state) {
    return Column(
      children: [
        // Flame game canvas.
        Expanded(child: GameWidget(game: flameGame)),
        // Update progress bars based on state.
        BlocListener<GameBloc, GameState>(
          listener: (context, state) {
            flameGame.updateBars(state);
          },
          child: Container(),
        ),
        // Fight controls and status display.
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
                  onPressed: state.currentTurn == Turn.player && !state.gameOver ? viewModel.attack : null,
                  child: const Text('Attack'),
                ),
                ElevatedButton(
                  onPressed: state.currentTurn == Turn.player && !state.gameOver ? viewModel.defend : null,
                  child: const Text('Defend'),
                ),
                ElevatedButton(
                  onPressed: state.currentTurn == Turn.player && !state.gameOver ? viewModel.openInventory : null,
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
    return BlocProvider<GameBloc>(
      create: (_) => GameBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Turn-Based Fight')),
        body: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            viewModel = GameViewModel(BlocProvider.of<GameBloc>(context));
            final bloc = BlocProvider.of<GameBloc>(context);
            return state.inFightMenu
                ? Center(child: buildMenu(state, bloc))
                : buildFightUI(state);
          },
        ),
      ),
    );
  }
}
