import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/logic/shop_bloc.dart';
import '../../game/logic/shop_state.dart';
import '../../game/viewmodel/shop_view_model.dart';
import '../logic/shop_event.dart';
import '../widgets/item_card.dart';

class TemporaryShopPage extends StatelessWidget {
  const TemporaryShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen for successful purchases.
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
        // Listen for errors.
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
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            BlocBuilder<ShopBloc, ShopState>(
              builder: (context, state) {
                int gold = 0;
                if (state is ShopLoaded) {
                  gold = state.temporaryCurrency;
                } else if (state is ShopPurchaseSuccess) {
                  // Since ShopPurchaseSuccess doesn’t carry currency data,
                  // we trigger a fetch for the updated data (handled elsewhere),
                  // and display a placeholder.
                  gold = 0;
                } else if (state is ShopError) {
                  gold = -1;
                } else if (state is ShopInitial) {
                  // Dispatch fetch if we’re in the initial state.
                  context.read<ShopBloc>().add(FetchShopItemsEvent());
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Gold: $gold',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ShopBloc, ShopState>(
          builder: (context, state) {
            if (state is ShopInitial) {
              context.read<ShopBloc>().add(FetchShopItemsEvent());
              return const Center(child: CircularProgressIndicator());
            } else if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ShopLoaded) {
              final tempItems =
                  state.items.where((item) => !item.permanent).toList();
              return ListView.builder(
                itemCount: tempItems.length,
                itemBuilder: (context, index) {
                  final item = tempItems[index];
                  final shopViewModel = ShopViewModel(context.read<ShopBloc>());
                  return ItemCard(item: item, viewModel: shopViewModel);
                },
              );
            } else if (state is ShopPurchaseSuccess) {
              // After a purchase, fetch updated shop data.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<ShopBloc>().add(FetchShopItemsEvent());
              });
              return const Center(child: CircularProgressIndicator());
            } else if (state is ShopError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text("Unexpected state"));
          },
        ),
      ),
    );
  }
}
