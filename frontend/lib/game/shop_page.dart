import 'package:flutter/material.dart';
import 'package:flutter_application_2/game/logic/shop_bloc.dart';
import 'package:flutter_application_2/game/logic/shop_event.dart';
import 'package:flutter_application_2/game/logic/shop_state.dart';
import 'package:flutter_application_2/game/viewmodel/shop_view_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';


final getIt = GetIt.instance;

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the ShopBloc instance from getIt and dispatch the event.
    final shopBloc = getIt<ShopBloc>()..add(FetchShopItemsEvent());

    return BlocProvider<ShopBloc>.value(
      value: shopBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Shop')),
        body: BlocListener<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopPurchaseSuccess) {
              // For example, update global user inventory here.
              // UserInventory.instance.addItem(state.item);
            }
          },
          child: BlocBuilder<ShopBloc, ShopState>(
            builder: (context, state) {
              final shopViewModel = ShopViewModel(context.read<ShopBloc>());
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
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, dynamic item, ShopViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('${item.description}\nPrice: ${item.price}'),
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
}
