// lib/game/viewmodel/shop_view_model.dart
import 'package:flutter_application_2/game/logic/shop_event.dart';

import '../logic/shop_bloc.dart';
import '../models/shop_item.dart';

class ShopViewModel {
  final ShopBloc shopBloc;
  ShopViewModel(this.shopBloc);

  void fetchItems() {
    shopBloc.add(FetchShopItemsEvent());
  }

  void buyItem(ShopItem item) {
    shopBloc.add(BuyShopItemEvent(item));
  }
}
