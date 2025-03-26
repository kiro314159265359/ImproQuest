import 'dart:math';

class CombatResult {
  final int damage;
  final String message;
  final bool targetDefeated;

  CombatResult({
    required this.damage,
    required this.message,
    required this.targetDefeated,
  });
}

class CombatService {
  final Random _random = Random();

  /// Calculates damage based on attacker's strength and defender's endurance
  int calculateDamage(int strength, int endurance, {bool isDefending = false}) {
    int baseDamage = (strength - endurance + _random.nextInt(5)).clamp(0, 999);
    return isDefending ? (baseDamage / 2).round() : baseDamage;
  }

  /// Prepares attack data including damage calculation and messages
  CombatResult prepareAttack({
    required String attackerName,
    required int attackerStrength,
    required int defenderEndurance,
    required int defenderCurrentHp,
    bool isDefending = false,
  }) {
    // Calculate damage
    int damage = calculateDamage(
      attackerStrength,
      defenderEndurance,
      isDefending: isDefending,
    );

    int newHp = defenderCurrentHp - damage;
    String message = '$attackerName attacked for $damage damage!';
    bool targetDefeated = newHp <= 0;

    return CombatResult(
      damage: damage,
      message: message,
      targetDefeated: targetDefeated,
    );
  }
}
