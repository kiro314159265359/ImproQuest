import 'package:flutter/material.dart';
import 'package:flutter_application_2/game/logic/shop_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/color_manger.dart';
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../logic/shop_bloc.dart';
import '../models/inventory_item.dart';
import '../models/shop_item.dart';
import '../viewmodel/game_view_model.dart';

class InventoryUI extends StatelessWidget {
  final GameViewModel viewModel;

  const InventoryUI({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: ColorManager.containerBackGround,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorManager.primaryColor, width: 2),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildConsumableList(context),
              ),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorManager.primaryColor, width: 1),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 8),
          Text(
            'Temporary Consumables',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumableList(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        // Access temporary inventory from ShopBloc
        final List<InventoryItem> inventoryItems = context.read<ShopBloc>().temporaryInventory;
        
        print('Inventory UI found ${inventoryItems.length} items in inventory');
        for (var item in inventoryItems) {
          print('Inventory item: ${item.name}, Quantity: ${item.quantity}, Type: ${item.type}, Effects: ${item.effects}');
        }
        
        if (inventoryItems.isEmpty) {
          return const Center(
            child: Text(
              'No consumable items in inventory',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        
        // Filter for consumable items only
        final consumables = inventoryItems
            .where((item) => item.type == ItemType.consumable)
            .toList();
            
        if (consumables.isEmpty) {
          return const Center(
            child: Text(
              'No consumable items in inventory',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: consumables.length,
          itemBuilder: (context, index) {
            final inventoryItem = consumables[index];
            final item = inventoryItem.item;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.grey.shade800,
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
                      child: const Icon(
                        Icons.medication,
                        color: Colors.white,
                      ),
                    ),
                    if (inventoryItem.quantity > 1)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'x${inventoryItem.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    color: _getTierColor(item.tier),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    if (item.effects.isNotEmpty)
                      ...item.effects.entries.map((e) => Text(
                            '• ${_formatEffectName(e.key)}: +${e.value}',
                            style: const TextStyle(color: Colors.amber),
                          )),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Use the item
                    viewModel.useItem(item);
                    // Close inventory after using item
                    context.read<GameBloc>().add(CloseInventoryEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
                  ),
                  child: const Text('Use'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          context.read<GameBloc>().add(CloseInventoryEvent());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.secondaryColor,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Close Inventory'),
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

  // Helper to format effect names for display
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
        return effect.split('_').map((word) => 
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
    }
  }
}
