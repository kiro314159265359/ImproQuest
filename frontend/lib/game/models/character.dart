// lib/game/models/character.dart
class Character {
  final String name;
  final int strength; // Used as attack
  final int endurance; // Used as defense
  final int agility; // Speed—affects turn frequency
  final int vitality; // Maximum health
  int currentHp;
  bool isDefending;
  final bool isBoss;

  Character({
    required this.name,
    required this.strength,
    required this.endurance,
    required this.agility,
    required this.vitality,
    required this.currentHp,
    this.isDefending = false,
    this.isBoss = false,
  });

  Character copyWith({
    String? name,
    int? strength,
    int? endurance,
    int? agility,
    int? vitality,
    int? currentHp,
    bool? isDefending,
    bool? isBoss,
  }) {
    return Character(
      name: name ?? this.name,
      strength: strength ?? this.strength,
      endurance: endurance ?? this.endurance,
      agility: agility ?? this.agility,
      vitality: vitality ?? this.vitality,
      currentHp: currentHp ?? this.currentHp,
      isDefending: isDefending ?? this.isDefending,
      isBoss: isBoss ?? this.isBoss,
    );
  }
}
