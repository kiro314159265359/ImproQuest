import 'package:flutter_application_2/game/models/shop_item.dart';

class InventoryModel {
  List<ShopItem>? items;

  InventoryModel({this.items});

  InventoryModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <ShopItem>[];
      json['items'].forEach((v) {
        items!.add(ShopItem.fromJson(v));
      });
    }
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   if (items != null) {
  //     data['items'] = items!.map((v) => v.toJson()).toList();
  //   }
  //   return data;
  // }
}
