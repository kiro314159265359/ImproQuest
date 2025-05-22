import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/game/logic/shop_state.dart';
import 'package:flutter_application_2/core/widget/custom_button.dart';
import 'package:flutter_application_2/game/widgets/inventory_item_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/color_manger.dart';
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../logic/shop_bloc.dart';
import '../models/inventory_item.dart';
import '../models/shop_item.dart';
import '../viewmodel/game_view_model.dart';

class TemporaryInventoryUi extends StatelessWidget {
  final GameViewModel viewModel;

  const TemporaryInventoryUi({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: ColorManager.blackColor.withOpacity(0.8),
      child: Center(
        child: Container(
          width: screenWidth * 0.8,
          height: screenHeight * 0.6,
          decoration: BoxDecoration(
            color: ColorManager.gunmetal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorManager.neonBlue, width: 2),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildConsumableList(context),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: CustomButton(
                  fillColor: ColorManager.primaryColor,
                  buttonText: "Close Inventory",
                  onPressed: () {
                    context.read<GameBloc>().add(CloseInventoryEvent());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorManager.neonBlue, width: 2),
        ),
      ),
      child: Text(
        'Temporary Consumables',
        style: TextStyles.bold18White,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildConsumableList(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        // Access temporary inventory from ShopBloc
        final List<InventoryItem> inventoryItems =
            context.read<ShopBloc>().temporaryInventory;

        print('Inventory UI found ${inventoryItems.length} items in inventory');
        for (var item in inventoryItems) {
          print(
              'Inventory item: ${item.name}, Quantity: ${item.quantity}, Type: ${item.type}, Effects: ${item.effects}');
        }

        if (inventoryItems.isEmpty) {
          return Center(
            child: Text('No consumable items in inventory',
                style: TextStyles.regular12White),
          );
        }

        // Filter for consumable items only
        final consumables = inventoryItems
            .where((item) => item.type == ItemType.consumable)
            .toList();

        if (consumables.isEmpty) {
          return Center(
            child: Text('No consumable items in inventory',
                style: TextStyles.regular12White),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          itemCount: consumables.length,
          itemBuilder: (context, index) {
            final inventoryItem = consumables[index];

            return InventoryItemCard.fromInventoryItem(
              inventoryItem: inventoryItem,
              buttonText: "Use",
              onButtonPressed: () {
                //Use the item
                viewModel.useItem(inventoryItem.item);
                // Close inventory after using item
                context.read<GameBloc>().add(CloseInventoryEvent());
              },
            );
          },
        );
      },
    );
  }
}
