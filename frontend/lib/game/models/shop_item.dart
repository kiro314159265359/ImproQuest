enum ShopTier { basic, meta, prestige }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final ShopTier tier;
  final bool permanent; // if false, resets after each run

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tier,
    required this.permanent,
  });

// You might later add methods to serialize/deserialize for API calls.
}