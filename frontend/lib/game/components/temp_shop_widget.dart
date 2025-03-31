import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/color_manger.dart';
import '../../core/utils/app_icons.dart';
import '../logic/shop_bloc.dart';
import '../logic/shop_state.dart';
import '../models/shop_item.dart';
import '../viewmodel/shop_view_model.dart';
import '../logic/shop_event.dart';

class TemporaryShopPage extends StatefulWidget {
  const TemporaryShopPage({super.key});

  @override
  State<TemporaryShopPage> createState() => _TemporaryShopPageState();
}

class _TemporaryShopPageState extends State<TemporaryShopPage> {
  late ShopBloc shopBloc;

  @override
  void initState() {
    super.initState();
    // Get the ShopBloc from the context instead of from GetIt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shopBloc = context.read<ShopBloc>();
      shopBloc.add(FetchTemporaryItemsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ShopBloc, ShopState>(
          listenWhen: (previous, current) => current is ShopPurchaseSuccess,
          listener: (context, state) {
            if (state is ShopPurchaseSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Purchased ${state.item.name}')),
              );
            }
          },
        ),
        BlocListener<ShopBloc, ShopState>(
          listenWhen: (previous, current) => current is ShopError,
          listener: (context, state) {
            if (state is ShopError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        BlocListener<ShopBloc, ShopState>(
          listenWhen: (previous, current) => current is ShopAlreadyOwned,
          listener: (context, state) {
            if (state is ShopAlreadyOwned) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Temporary Shop"),
          actions: [
            BlocBuilder<ShopBloc, ShopState>(
              builder: (context, state) {
                int gold = 0;
                if (state is TemporaryShopLoaded) {
                  gold = state.temporaryCurrency;
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: [
                        Image.asset(AppIcons.coinsIcon, width: 24, height: 24),
                        const SizedBox(width: 4),
                        Text(
                          '$gold',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "These items will be reset after your run ends",
                style: TextStyle(
                  color: Colors.amber[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ShopBloc, ShopState>(
                builder: (context, state) {
                  if (state is ShopLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TemporaryShopLoaded) {
                    final tempItems = state.items;

                    if (tempItems.isEmpty) {
                      return const Center(
                        child: Text("No temporary items available"),
                      );
                    }

                    return ListView.builder(
                      itemCount: tempItems.length,
                      itemBuilder: (context, index) {
                        final item = tempItems[index];
                        final shopViewModel =
                            ShopViewModel(context.read<ShopBloc>());
                        return TemporaryItemCard(
                            item: item, viewModel: shopViewModel);
                      },
                    );
                  } else if (state is ShopError) {
                    return Center(child: Text(state.message));
                  }
                  // Show loading indicator by default
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ShopBloc>()
                          .add(ResetTemporaryShopItemsEvent());
                    },
                    child: const Text("Refresh Items"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ShopBloc>()
                          .add(RewardTemporaryGoldEvent(50));
                    },
                    child: const Text("+ 50 Gold (Test)"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TemporaryItemCard extends StatelessWidget {
  final ShopItem item;
  final ShopViewModel viewModel;

  const TemporaryItemCard({
    super.key,
    required this.item,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the item exists in inventory and get its quantity
    final shopBloc = context.read<ShopBloc>();
    final inventoryItem = shopBloc.temporaryInventory
        .where((invItem) => invItem.id == item.id)
        .firstOrNull;
    final int ownedQuantity = inventoryItem?.quantity ?? 0;

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
                if (ownedQuantity > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'Owned: $ownedQuantity',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.description),

            // Show temporary effects
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
                  onPressed: () => viewModel.buyTemporaryItem(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.secondaryColor,
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
