import '../models/shop_item.dart';

abstract class ShopEvent {}

// Separate events for permanent and temporary shops
class FetchPermanentItemsEvent extends ShopEvent {}

class FetchTemporaryItemsEvent extends ShopEvent {}

class BuyPermanentItemEvent extends ShopEvent {
  final ShopItem item;
  final String itemId;
  final int price;

  BuyPermanentItemEvent(this.item, this.itemId, this.price);
}

class BuyTemporaryItemEvent extends ShopEvent {
  final ShopItem item;
  BuyTemporaryItemEvent(this.item);
}

class RewardTemporaryGoldEvent extends ShopEvent {
  final int reward;
  RewardTemporaryGoldEvent(this.reward);
}

class ResetTemporaryGoldEvent extends ShopEvent {}

class ResetTemporaryShopItemsEvent extends ShopEvent {}

class RemoveTemporaryItemFromInventoryEvent extends ShopEvent {
  final ShopItem item;
  RemoveTemporaryItemFromInventoryEvent(this.item);
}
