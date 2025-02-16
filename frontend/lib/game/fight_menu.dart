import 'package:flutter/material.dart';
import 'logic/game_state.dart';
import 'logic/game_event.dart';
import 'logic/game_bloc.dart';

class FightMenu extends StatelessWidget {
  final GameState state;
  final GameBloc bloc;

  const FightMenu({super.key, required this.state, required this.bloc});

  Widget buildBlindCard(int blind) {
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
    int vitality = baseVitality * state.currentAnte;
    int strength = baseStrength * state.currentAnte;
    int endurance = baseEndurance * state.currentAnte;
    int agility = baseAgility * state.currentAnte;

    // Determine availability: completed blinds are greyed, only the next available is selectable.
    bool isCompleted = blind < state.currentBlind;
    bool isAvailable = blind == state.currentBlind;

    return Card(
      color: isCompleted ? Colors.grey[300] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Blind $blind: $enemyType',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.grey : Colors.black,
              ),
            ),
            Text(
                'Vitality: $vitality, Strength: $strength, Endurance: $endurance, Agility: $agility'),
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

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: buildBlindCard(1)),
            Expanded(child: buildBlindCard(2)),
            Expanded(child: buildBlindCard(3)),
          ],
        ),
        const SizedBox(height: 24),
        Text(state.message,
            style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
      ],
    );
  }
}
