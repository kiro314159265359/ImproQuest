import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/color_manger.dart';
import '../core/theme/text_style.dart';
import '../core/utils/app_icons.dart';
import '../core/utils/get_it_constants.dart';
import 'logic/shop_bloc.dart';
import 'logic/shop_event.dart';
import 'logic/shop_state.dart';
import 'models/shop_item.dart';
import 'viewmodel/shop_view_model.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the ShopBloc with the PermanentItemsEvent
    final shopBloc = getIt<ShopBloc>()..add(FetchPermanentItemsEvent());

    return BlocProvider<ShopBloc>.value(
      value: shopBloc,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: BlocBuilder<ShopBloc, ShopState>(
            builder: (context, state) {
              int gold = 0;
              if (state is PermanentShopLoaded) {
                gold = state.permanentCurrency;
              }

              return Container(
                decoration: const BoxDecoration(
                    color: ColorManager.containerBackGround,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(AppIcons.coinsIcon,
                          width: 25, fit: BoxFit.contain),
                      Text("$gold",
                          style: TextStyles.styleMedium(context,
                              fontSize: 16, color: ColorManager.whiteColor),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocListener<ShopBloc, ShopState>(
                listener: (context, state) {
                  if (state is ShopPurchaseSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Purchased ${state.item.name}")),
                    );
                  } else if (state is ShopAlreadyOwned) {
                    // Show a more friendly message for already owned items
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else if (state is ShopError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, state) {
                    final shopViewModel =
                        ShopViewModel(context.read<ShopBloc>());

                    if (state is ShopLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PermanentShopLoaded) {
                      final equipmentItems = state.items
                          .where((item) => item.type == ItemType.equipment)
                          .toList();

                      if (equipmentItems.isEmpty) {
                        return const Center(
                          child: Text("No permanent equipment items available"),
                        );
                      }

                      return ListView.builder(
                        itemCount: equipmentItems.length,
                        itemBuilder: (context, index) {
                          final item = equipmentItems[index];
                          return PermanentItemCard(
                            item: item,
                            viewModel: shopViewModel,
                          );
                        },
                      );
                    } else if (state is ShopError) {
                      return Center(child: Text(state.message));
                    }
                    return const Center(child: Text("Loading shop items..."));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermanentItemCard extends StatelessWidget {
  final ShopItem item;
  final ShopViewModel viewModel;

  const PermanentItemCard({
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
                Text(
                  "Slot: ${item.slot ?? 'None'}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description),

            // Show permanent stat bonuses
            if (item.statBonuses.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text("Permanent Bonuses:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...item.statBonuses.entries.map((entry) =>
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
                  onPressed: () => viewModel.buyPermanentItem(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primaryColor,
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
    return stat
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
}
