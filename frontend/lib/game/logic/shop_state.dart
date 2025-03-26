import '../models/shop_item.dart';

// shop_state.dart
abstract class ShopState {}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<ShopItem> items;
  final int temporaryCurrency;
  final int permanentCurrency;

  ShopLoaded({
    required this.items,
    required this.temporaryCurrency,
    required this.permanentCurrency,
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
