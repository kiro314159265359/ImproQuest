// lib/game/viewmodel/shop_view_model.dart
import '../logic/shop_bloc.dart';
import '../logic/shop_event.dart';
import '../models/shop_item.dart';

class ShopViewModel {
  final ShopBloc shopBloc;

  ShopViewModel(this.shopBloc);

  void fetchPermanentItems() {
    shopBloc.add(FetchPermanentItemsEvent());
  }

  void fetchTemporaryItems() {
    shopBloc.add(FetchTemporaryItemsEvent());
  }

  void buyPermanentItem(ShopItem item) {
    shopBloc.add(BuyPermanentItemEvent(item, item.id, item.price));
  }

  void buyTemporaryItem(ShopItem item) {
    shopBloc.add(BuyTemporaryItemEvent(item));
  }

  // Add backward compatibility method
  void buyItem(ShopItem item) {
    if (item.permanent) {
      buyPermanentItem(item);
    } else {
      buyTemporaryItem(item);
    }
  }

  void rewardTemporaryGold(int amount) {
    shopBloc.add(RewardTemporaryGoldEvent(amount));
  }

  void resetTemporaryGold() {
    shopBloc.add(ResetTemporaryGoldEvent());
  }

  void resetTemporaryItems() {
    shopBloc.add(ResetTemporaryShopItemsEvent());
  }
}
