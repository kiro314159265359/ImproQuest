import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/widget/custom_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/color_manger.dart';
import '../../core/utils/app_icons.dart';
import '../../core/widget/snackabars.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return MultiBlocListener(
      listeners: [
        BlocListener<ShopBloc, ShopState>(
          listenWhen: (previous, current) => current is ShopPurchaseSuccess,
          listener: (context, state) {
            if (state is ShopPurchaseSuccess) {
              Snackbars.showSuccessSnackbar(
                  context, "Purchased ${state.item.name}");
            }
          },
        ),
        BlocListener<ShopBloc, ShopState>(
          listenWhen: (previous, current) => current is ShopError,
          listener: (context, state) {
            if (state is ShopError) {
              Snackbars.showErrorSnackbar(context, state.message);
            }
          },
        ),
        BlocListener<ShopBloc, ShopState>(
          listenWhen: (previous, current) => current is ShopAlreadyOwned,
          listener: (context, state) {
            if (state is ShopAlreadyOwned) {
              Snackbars.showNoticeSnackbar(context, state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
                      color: ColorManager.lightGoldColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorManager.goldColor),
                    ),
                    child: Row(
                      children: [
                        Image.asset(AppIcons.coinsIcon, width: 24, height: 24),
                        SizedBox(width: screenWidth * 0.01),
                        Text('$gold', style: TextStyles.bold16Gold),
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
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Text("These items will be reset after your run ends",
                  style: TextStyles.regularItalic12darkGold),
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
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.05),
              child: CustomButton(
                borderColor: ColorManager.lightGrey,
                fillColor: Colors.transparent,
                buttonText: "Refresh Items",
                onPressed: () {
                  context.read<ShopBloc>().add(ResetTemporaryShopItemsEvent());
                },
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: TextStyles.styleBold(context,
                      fontSize: 18, color: _getTierColor(item.tier)),
                ),
                if (ownedQuantity > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenWidth * 0.01),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorManager.greenColor),
                    ),
                    child: Text('Owned: $ownedQuantity',
                        style: TextStyles.bold12Green),
                  ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(item.description),

            // Show temporary effects
            if (item.effects.isNotEmpty) ...[
              SizedBox(height: screenWidth * 0.02),
              Text("Temporary Effects:", style: TextStyles.bold12White),
              ...item.effects.entries.map((entry) =>
                  Text("• ${_formatStatName(entry.key)}: +${entry.value}")),
            ],

            SizedBox(height: screenWidth * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(AppIcons.coinsIcon, width: 20, height: 20),
                    SizedBox(width: screenWidth * 0.01),
                    Text("${item.price}", style: TextStyles.bold16White),
                  ],
                ),
                CustomButton(
                    width: null,
                    height: null,
                    fillColor: ColorManager.primaryColor,
                    buttonText: "Buy",
                    onPressed: () => viewModel.buyTemporaryItem(item)),
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
        return ColorManager.whiteColor;
      case ShopTier.meta:
        return ColorManager.blueColor;
      case ShopTier.prestige:
        return ColorManager.prupleColor;
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
