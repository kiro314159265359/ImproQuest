// lib/game/models/character.dart
class Character {
  final String name;
  final int maxHp;
  int currentHp;
  final int attack;
  final int defense;
  bool isDefending;

  Character({
    required this.name,
    required this.maxHp,
    required this.currentHp,
    required this.attack,
    required this.defense,
    this.isDefending = false,
  });

  Character copyWith({
    String? name,
    int? maxHp,
    int? currentHp,
    int? attack,
    int? defense,
    bool? isDefending,
  }) {
    return Character(
      name: name ?? this.name,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      isDefending: isDefending ?? this.isDefending,
    );
  }
}
