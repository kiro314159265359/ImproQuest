import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/game/models/inventory_item.dart';
import 'package:flutter_application_2/game/models/shop_item.dart';
import 'package:flutter_application_2/core/widget/custom_button.dart';
import '../../core/theme/color_manger.dart';

class InventoryItemCard extends StatelessWidget {
  final ShopItem item;
  final int quantity;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool isEquipped;
  final bool showQuantity;
  final String? itemPhoto;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.quantity = 1,
    required this.buttonText,
    required this.onButtonPressed,
    this.isEquipped = false,
    this.showQuantity = true,
    this.itemPhoto,
  });

  factory InventoryItemCard.fromInventoryItem({
    required InventoryItem inventoryItem,
    required String buttonText,
    required VoidCallback onButtonPressed,
    bool isEquipped = false,
    String? itemPhoto,
  }) {
    return InventoryItemCard(
      item: inventoryItem.item,
      quantity: inventoryItem.quantity,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
      isEquipped: isEquipped,
      itemPhoto: itemPhoto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: ColorManager.navyColor,
      child: ListTile(
        leading: Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTierColor(item.tier).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getTierColor(item.tier)),
              ),
              child: itemPhoto != null
                  ? Image.asset(itemPhoto!, width: 40, height: 40)
                  : Icon(
                      item.type == ItemType.consumable
                          ? Icons.medication
                          : Icons.shield,
                      color: ColorManager.whiteColor,
                    ),
            ),
            if (showQuantity && quantity > 1)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: ColorManager.blackColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('x$quantity', style: TextStyles.bold10White),
                ),
              ),
          ],
        ),
        title: Text(
          item.name,
          style: TextStyles.styleBold(context,
              fontSize: 12, color: _getTierColor(item.tier)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description, style: TextStyles.regular12LightGrey),
            const SizedBox(height: 4),
            if (item.effects.isNotEmpty)
              ...item.effects.entries.where((e) => e.value > 0).map((e) => Text(
                  '• ${_formatEffectName(e.key)}: +${e.value}',
                  style: TextStyles.regular12Gold)),
            if (item.statBonuses.isNotEmpty)
              ...item.statBonuses.entries.where((e) => e.value > 0).map((e) =>
                  Text('• ${_formatEffectName(e.key)}: +${e.value}',
                      style: TextStyles.regular12LightBlue)),
          ],
        ),
        trailing: CustomButton(
          fontSize: 12,
          width: null,
          height: null,
          fillColor:
              isEquipped ? ColorManager.redColor : ColorManager.primaryColor,
          buttonText: buttonText,
          onPressed: onButtonPressed,
        ),
      ),
    );
  }

  Color _getTierColor(ShopTier tier) {
    switch (tier) {
      case ShopTier.basic:
        return ColorManager.whiteColor;
      case ShopTier.meta:
        return ColorManager.blueColor;
      case ShopTier.prestige:
        return ColorManager.prupleColor;
    }
  }

  String _formatEffectName(String effect) {
    final String effectLower = effect.toLowerCase();

    switch (effectLower) {
      case 'vitality':
        return 'Health';
      case 'health_restore':
        return 'Health';
      case 'health':
        return 'Health';
      case 'strength':
        return 'Strength';
      case 'endurance':
        return 'Endurance';
      case 'agility':
        return 'Agility';
      default:
        return effect
            .split('_')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '')
            .join(' ');
    }
  }
}
