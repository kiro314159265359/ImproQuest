enum ShopTier { basic, meta, prestige }

enum ItemType { equipment, consumable }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final ShopTier tier;
  final bool permanent; // if false, resets after each run
  final ItemType type;
  final String? slot; // Only for equipment items
  final Map<String, int> effects; // For temporary stat modifications
  final Map<String, int> statBonuses; // For permanent stat modifications

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tier,
    required this.permanent,
    required this.type,
    this.slot,
    this.effects = const {},
    this.statBonuses = const {},
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    // Parse effects map
    Map<String, int> effectsMap = {};
    if (json['effects'] != null) {
      final effects = json['effects'] as Map<String, dynamic>;
      effects.forEach((key, value) {
        if (value is int) {
          effectsMap[key] = value;
        } else if (value is double) {
          effectsMap[key] = value.toInt();
        } else if (value is String) {
          effectsMap[key] = int.tryParse(value) ?? 0;
        }
      });
    }

    // Parse stat bonuses map
    Map<String, int> statBonusesMap = {};
    if (json['stat_bonuses'] != null) {
      final statBonuses = json['stat_bonuses'] as Map<String, dynamic>;
      statBonuses.forEach((key, value) {
        if (value is int) {
          statBonusesMap[key] = value;
        } else if (value is double) {
          statBonusesMap[key] = value.toInt();
        } else if (value is String) {
          statBonusesMap[key] = int.tryParse(value) ?? 0;
        }
      });
    }

    return ShopItem(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      tier: _parseTier(json['tier']),
      permanent: json['is_permanent'],
      type: json['type'] == 'equipment'
          ? ItemType.equipment
          : ItemType.consumable,
      slot: json['slot'],
      effects: effectsMap,
      statBonuses: statBonusesMap,
    );
  }

  static ShopTier _parseTier(String? tierStr) {
    switch (tierStr) {
      case 'basic':
        return ShopTier.basic;
      case 'meta':
        return ShopTier.meta;
      case 'prestige':
        return ShopTier.prestige;
      default:
        return ShopTier.basic;
    }
  }
}
