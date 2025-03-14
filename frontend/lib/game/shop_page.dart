import 'package:flutter/material.dart';
import 'package:flutter_application_2/game/logic/shop_bloc.dart';
import 'package:flutter_application_2/game/logic/shop_event.dart';
import 'package:flutter_application_2/game/logic/shop_state.dart';
import 'package:flutter_application_2/game/viewmodel/shop_view_model.dart';
import 'package:flutter_application_2/game/widgets/item_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/color_manger.dart';
import '../core/theme/text_style.dart';
import '../core/utils/app_icons.dart';
import '../core/utils/get_it_constants.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the ShopBloc instance from getIt and dispatch the fetch event.
    final shopBloc = getIt<ShopBloc>()..add(FetchShopItemsEvent());

    return BlocProvider<ShopBloc>.value(
      value: shopBloc,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: BlocBuilder<ShopBloc, ShopState>(
            builder: (context, state) {
              int gold = 0;
              if (state is ShopLoaded) {
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
                    return ItemCard(item: item, viewModel: shopViewModel);
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
}
