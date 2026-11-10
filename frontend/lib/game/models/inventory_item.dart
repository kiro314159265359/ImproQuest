import 'shop_item.dart';

class InventoryItem {
  final ShopItem item;
  int quantity;

  InventoryItem({
    required this.item,
    this.quantity = 1,
  });

  String get id => item.id;
  String get name => item.name;
  String get description => item.description;
  ShopTier get tier => item.tier;
  ItemType get type => item.type;
  Map<String, int> get effects => item.effects;

  void incrementQuantity() {
    quantity++;
  }

  bool decrementQuantity() {
    if (quantity > 0) {
      quantity--;
      return true;
    }
    return false;
  }

  // For debugging
  @override
  String toString() {
    return 'InventoryItem{name: $name, quantity: $quantity}';
  }
}
