import 'package:flutter/material.dart';
import '../../core/theme/color_manger.dart';
import '../../core/utils/app_icons.dart';
import '../models/shop_item.dart';
import '../viewmodel/shop_view_model.dart';

class ItemCard extends StatelessWidget {
  final ShopItem item;
  final ShopViewModel viewModel;

  const ItemCard({
    super.key,
    required this.item,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTierColor(item.tier),
                  ),
                ),
                if (item.type == ItemType.equipment && item.slot != null)
                  Text(
                    "Slot: ${item.slot}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description),

            // Display stat bonuses if they exist
            if (item.statBonuses.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text("Permanent Bonuses:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...item.statBonuses.entries.map((entry) =>
                  Text("• ${_formatStatName(entry.key)}: +${entry.value}")),
            ],

            // Display effects if they exist
            if (item.effects.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text("Temporary Effects:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...item.effects.entries.map((entry) =>
                  Text("• ${_formatStatName(entry.key)}: +${entry.value}")),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(AppIcons.coinsIcon, width: 20, height: 20),
                    const SizedBox(width: 4),
                    Text(
                      "${item.price}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  // Replace buyItem with the correct method based on whether the item is permanent
                  onPressed: () => item.permanent
                      ? viewModel.buyPermanentItem(item)
                      : viewModel.buyTemporaryItem(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.permanent
                        ? ColorManager.primaryColor
                        : ColorManager.secondaryColor,
                  ),
                  child: const Text("Buy"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(ShopTier tier) {
    switch (tier) {
      case ShopTier.basic:
        return Colors.white;
      case ShopTier.meta:
        return Colors.blue;
      case ShopTier.prestige:
        return Colors.purple;
    }
  }

  // Helper method to format stat names for display
  String _formatStatName(String stat) {
    // Capitalize first letter and replace underscores with spaces
    return stat
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
}
