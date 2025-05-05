import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/utils/app_images.dart';
import 'package:flutter_application_2/game/models/shop_item.dart';
import 'package:flutter_application_2/game/widgets/inventory_item_card.dart';
import 'package:flutter_application_2/core/widget/custom_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../home/presentation/manager/user_cubit.dart';
import '../../../../home/presentation/manager/user_state.dart';

class InventoryUI extends StatefulWidget {
  final String? title;

  const InventoryUI({
    super.key,
    required this.title,
  });
  @override
  State<InventoryUI> createState() => _InventoryUIState();
}

class _InventoryUIState extends State<InventoryUI> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().getUserItems(widget.title?.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is InventoryLoaded) {
          return _buildUIContent(state.itemsList);
        }
        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildUIContent(List<ShopItem>? itemsList) {
    final userCubit = context.read<UserCubit>();
    final currentUser = userCubit.currentUser;
    final equippedItems = currentUser?.equippedItems;

    String? equippedItemId;
    String? equippedItemIcon;
    if (equippedItems != null) {
      switch (widget.title!.toLowerCase()) {
        case 'helmet':
          equippedItemId = equippedItems.helmet;
          equippedItemIcon = AppImages.helmetPhoto;
          break;
        case 'armor':
          equippedItemId = equippedItems.armor;
          equippedItemIcon = AppImages.armorPhoto;
          break;
        case 'gloves':
          equippedItemId = equippedItems.gloves;
          equippedItemIcon = AppImages.glovesPhoto;
          break;
        case 'boots':
          equippedItemId = equippedItems.boots;
          equippedItemIcon = AppImages.bootsPhoto;
          break;
        case 'weapon':
          equippedItemId = equippedItems.weapon;
          equippedItemIcon = AppImages.armorPhoto;
          break;
      }
    }

    return Stack(
      children: [
        Container(
          color: ColorManager.blackColor.withOpacity(0.8),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: ColorManager.gunmetal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorManager.neonBlue, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: ColorManager.neonBlue, width: 2),
                      ),
                    ),
                    child: Text(
                      widget.title!,
                      style: TextStyles.regular18White,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: itemsList!.isEmpty
                        ? Center(
                            child: Text('No items',
                                style: TextStyles.regular16White))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: itemsList.length,
                            itemBuilder: (c, i) {
                              final item = itemsList[i];
                              final bool isEquipped = item.id == equippedItemId;

                              return InventoryItemCard(
                                item: item,
                                quantity: 1,
                                showQuantity: false,
                                buttonText: isEquipped ? 'Unequip' : 'Equip',
                                isEquipped: isEquipped,
                                itemPhoto: equippedItemIcon,
                                onButtonPressed: () async {
                                  isEquipped
                                      ? await context
                                          .read<UserCubit>()
                                          .unequipItem(item.id, item.slot)
                                      : await context
                                          .read<UserCubit>()
                                          .equipItem(item.id, item.slot);

                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomButton(
                      fillColor: ColorManager.primaryColor,
                      buttonText: "Close Inventory",
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
