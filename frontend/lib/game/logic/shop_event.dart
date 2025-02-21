import '../models/shop_item.dart';

// shop_event.dart
abstract class ShopEvent {}

class FetchShopItemsEvent extends ShopEvent {}

class BuyShopItemEvent extends ShopEvent {
  final ShopItem item;
  BuyShopItemEvent(this.item);
}

// New event to reward temporary gold
class RewardTemporaryGoldEvent extends ShopEvent {
  final int reward;
  RewardTemporaryGoldEvent(this.reward);
}

class ResetTemporaryGoldEvent extends ShopEvent {}

class ResetTemporaryShopItemsEvent extends ShopEvent {}