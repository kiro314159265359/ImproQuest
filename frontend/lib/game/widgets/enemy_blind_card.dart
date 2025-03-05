import 'package:flutter/material.dart';
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../constants/game_constants.dart';

class EnemyBlindCard extends StatelessWidget {
  final GameBloc bloc;
  final int blind;
  final int currentAnte;
  final int currentBlind;

  const EnemyBlindCard({
    super.key,
    required this.bloc,
    required this.blind,
    required this.currentAnte,
    required this.currentBlind,
  });

  @override
  Widget build(BuildContext context) {
    final enemyType = _getEnemyType();
    final stats = _calculateStats();

    final bool isCompleted = blind < currentBlind;
    final bool isAvailable = blind == currentBlind;

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
              'Vitality: ${stats.vitality}, Strength: ${stats.strength}, ' 
                  'Endurance: ${stats.endurance}, Agility: ${stats.agility}',
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

  String _getEnemyType() {
    if (blind == GameConstants.bossBlind) return 'Boss';
    if (blind == GameConstants.bigEnemyBlind) return 'Big Enemy';
    return 'Small Enemy';
  }

  _EnemyStats _calculateStats() {
    int baseVitality, baseStrength, baseEndurance, baseAgility;

    if (blind == GameConstants.bossBlind) {
      baseVitality = GameConstants.bossBaseVitality;
      baseStrength = GameConstants.bossBaseStrength;
      baseEndurance = GameConstants.bossBaseEndurance;
      baseAgility = GameConstants.bossBaseAgility;
    } else if (blind == GameConstants.bigEnemyBlind) {
      baseVitality = GameConstants.bigEnemyBaseVitality;
      baseStrength = GameConstants.bigEnemyBaseStrength;
      baseEndurance = GameConstants.bigEnemyBaseEndurance;
      baseAgility = GameConstants.bigEnemyBaseAgility;
    } else {
      baseVitality = GameConstants.smallEnemyBaseVitality;
      baseStrength = GameConstants.smallEnemyBaseStrength;
      baseEndurance = GameConstants.smallEnemyBaseEndurance;
      baseAgility = GameConstants.smallEnemyBaseAgility;
    }

    return _EnemyStats(
      vitality: baseVitality * currentAnte,
      strength: baseStrength * currentAnte,
      endurance: baseEndurance * currentAnte,
      agility: baseAgility * currentAnte,
    );
  }
}

class _EnemyStats {
  final int vitality;
  final int strength;
  final int endurance;
  final int agility;

  _EnemyStats({
    required this.vitality,
    required this.strength,
    required this.endurance,
    required this.agility,
  });
}
