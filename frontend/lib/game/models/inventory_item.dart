// lib/game/models/inventory_item.dart
class InventoryItem {
  final String name;
  final String effect; // e.g., "heal"
  final int value;

  InventoryItem({
    required this.name,
    required this.effect,
    required this.value,
  });
}
