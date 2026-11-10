import '../models/shop_item.dart';

abstract class ShopRepo {
  Future<List<ShopItem>> getPermanentItems();
  Future<List<ShopItem>> getTemporaryItems();
  Future<bool> purchaseItem(String itemId);
}
