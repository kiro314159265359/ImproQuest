// lib/game/ui/shop_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/auth/presentation/views/login.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/logic/shop_bloc.dart';
import '../../game/models/shop_item.dart';
import '../../game/viewmodel/shop_view_model.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  Widget _buildItemTile(
      BuildContext context, ShopItem item, ShopViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(
          '${item.description}\nPrice: ${item.price}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            viewModel.buyItem(item);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Purchased ${item.name}')),
            );
          },
          child: const Text('Buy'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = getIt<UserModel>();

    if (user.streak!.current! <= 7) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shop')),
        body: const Center(
          child: Text('Permanent shop locked until streak > 7'),
        ),
      );
    }

    return BlocProvider<ShopBloc>(
      create: (_) => ShopBloc()..add(FetchShopItemsEvent()),
      child: Builder(builder: (context) {
        final shopBloc = context.read<ShopBloc>();
        final shopViewModel = ShopViewModel(shopBloc);

        return Scaffold(
          appBar: AppBar(title: const Text('Shop')),
          body: BlocListener<ShopBloc, ShopState>(
            listener: (context, state) {
              if (state is ShopPurchaseSuccess) {
                // Here you could update global user inventory or persistent storage.
                // For example:
                // UserInventory.instance.addItem(state.item);
              }
            },
            child: BlocBuilder<ShopBloc, ShopState>(
              builder: (context, state) {
                if (state is ShopLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ShopLoaded) {
                  return ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _buildItemTile(context, item, shopViewModel);
                    },
                  );
                } else if (state is ShopError) {
                  return Center(child: Text(state.message));
                }
                return Container();
              },
            ),
          ),
        );
      }),
    );
  }
}
