import 'dart:math';
import '../models/character.dart';

class EnemyService {
  final Random _random = Random();

  /// Generate enemy based on current ante and blind level
  Character generateEnemy(int currentAnte, int currentBlind) {
    bool isBoss = currentBlind == 3;
    bool isBig = currentBlind == 2;

    String enemyName = _selectEnemyName(isBoss, isBig);
    Map<String, int> stats = _calculateEnemyStats(isBoss, isBig, currentAnte);

    return Character(
      name: enemyName,
      level: stats['level']!,
      strength: stats['strength']!,
      endurance: stats['endurance']!,
      agility: stats['agility']!,
      vitality: stats['vitality']!,
      currentHp: stats['vitality']!,
      isBoss: isBoss,
    );
  }

  /// Select an enemy name based on its type
  String _selectEnemyName(bool isBoss, bool isBig) {
    List<String> smallNames = ['Goblin', 'Skeleton', 'Bandit'];
    List<String> bigNames = ['Orc', 'Troll', 'Warrior'];
    List<String> bossNames = ['Dragon', 'Demon Lord', 'Giant', 'Lich King'];

    if (isBoss) {
      return bossNames[_random.nextInt(bossNames.length)];
    } else if (isBig) {
      return bigNames[_random.nextInt(bigNames.length)];
    } else {
      return smallNames[_random.nextInt(smallNames.length)];
    }
  }

  /// Calculate enemy stats based on type and ante
  Map<String, int> _calculateEnemyStats(
      bool isBoss, bool isBig, int currentAnte) {
    int baseVitality, baseStrength, baseEndurance, baseAgility, level;

    if (isBoss) {
      baseVitality = 100;
      baseStrength = 25;
      baseEndurance = 10;
      baseAgility = 10;
      level = 5;
    } else if (isBig) {
      baseVitality = 80;
      baseStrength = 20;
      baseEndurance = 8;
      baseAgility = 12;
      level = 3;
    } else {
      baseVitality = 60;
      baseStrength = 50;
      baseEndurance = 5;
      baseAgility = 50;
      level = 2;
    }

    return {
      'vitality': baseVitality * currentAnte,
      'strength': baseStrength * currentAnte,
      'endurance': baseEndurance * currentAnte,
      'agility': baseAgility * currentAnte,
      'level': level * currentAnte,
    };
  }
}
