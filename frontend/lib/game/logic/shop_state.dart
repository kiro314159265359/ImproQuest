import '../models/shop_item.dart';

abstract class ShopState {}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

// Separate states for permanent and temporary shops
class PermanentShopLoaded extends ShopState {
  final List<ShopItem> items;
  final int permanentCurrency;

  PermanentShopLoaded({
    required this.items,
    required this.permanentCurrency,
  });
}

class TemporaryShopLoaded extends ShopState {
  final List<ShopItem> items;
  final int temporaryCurrency;

  TemporaryShopLoaded({
    required this.items,
    required this.temporaryCurrency,
  });
}

class ShopPurchaseSuccess extends ShopState {
  final ShopItem item;
  ShopPurchaseSuccess(this.item);
}

class ShopError extends ShopState {
  final String message;
  ShopError(this.message);
}

class ShopAlreadyOwned extends ShopState {
  final String message;
  final ShopItem item;

  ShopAlreadyOwned(this.message, this.item);
}
