// lib/game/ui/temporary_shop_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/logic/shop_bloc.dart';
import '../../game/viewmodel/shop_view_model.dart';

class TemporaryShopPage extends StatelessWidget {
  const TemporaryShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temporary Shop')),
      body: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, state) {
          if (state is ShopLoaded) {
            // Filter to show only temporary items.
            final tempItems = state.items.where((item) => !item.permanent).toList();
            return ListView.builder(
              itemCount: tempItems.length,
              itemBuilder: (context, index) {
                final item = tempItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.description}\nPrice: ${item.price}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      final shopBloc = context.read<ShopBloc>();
                      final shopViewModel = ShopViewModel(shopBloc);
                      shopViewModel.buyItem(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Purchased ${item.name}')),
                      );
                    },
                    child: const Text('Buy'),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
