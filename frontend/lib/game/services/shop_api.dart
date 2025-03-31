import 'package:dio/dio.dart';
import 'package:flutter_application_2/core/service/api/api_service.dart';
import 'package:flutter_application_2/core/service/api/end_points.dart';
import 'package:flutter_application_2/game/services/shop_repo.dart';
import '../models/shop_item.dart';

// Custom exception for already owned items
class AlreadyOwnedItemException implements Exception {
  final String message;
  AlreadyOwnedItemException(this.message);
}

class ShopApi extends ShopRepo {
  final ApiService apiService;

  ShopApi({required this.apiService});

  // Get permanent items from the backend
  @override
  Future<List<ShopItem>> getPermanentItems() async {
    final response = await apiService.get(EndPoints.permanentShop);

    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> items = data['data'];
      return items.map((item) => ShopItem.fromJson(item)).toList();
    } else {
      print('Error: $response');
      throw Exception('Failed to load permanent items');
    }
  }

  // Purchase an item from the backend
  @override
  Future<bool> purchaseItem(String itemId) async {
    try {
      final response =
          await apiService.post('${EndPoints.purchaseItem}/$itemId');

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = response.data;
        throw Exception(error['error'] ?? 'Failed to purchase item');
      }
    } on DioException catch (e) {
      // Check if this is the "already owned" error
      if (e.response?.statusCode == 400 &&
          e.response?.data is Map &&
          (e.response?.data as Map).containsKey('error') &&
          (e.response?.data as Map)['error'] ==
              'you already own this equipment item') {
        // Throw our custom exception instead
        throw AlreadyOwnedItemException('You already own this item');
      }
      // Rethrow all other exceptions
      rethrow;
    }
  }

  // Get temporary items from the backend
  @override
  Future<List<ShopItem>> getTemporaryItems() async {
    try {
      final response = await apiService.get(EndPoints.temporaryShop);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['data'];
        return items.map((item) => ShopItem.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching temporary items: $e');
      // For development, return some test items if API fails
      return _getTestConsumableItems();
    }
    
    // If all else fails, return test items
    return _getTestConsumableItems();
  }
  
  // Helper method to create test consumable items
  List<ShopItem> _getTestConsumableItems() {
    print('Returning test consumable items');
    return [
      ShopItem(
        id: 'health-potion-basic',
        name: 'Health Potion',
        description: 'Restores 30 health points',
        price: 20,
        tier: ShopTier.basic,
        permanent: false,
        type: ItemType.consumable,
        effects: {'vitality': 30},
      ),
      ShopItem(
        id: 'health-potion-greater',
        name: 'Greater Health Potion',
        description: 'Restores 50 health points',
        price: 40,
        tier: ShopTier.meta,
        permanent: false,
        type: ItemType.consumable,
        effects: {'vitality': 50},
      ),
      ShopItem(
        id: 'strength-potion',
        name: 'Strength Potion',
        description: 'Temporarily increases strength by 10',
        price: 30,
        tier: ShopTier.meta,
        permanent: false,
        type: ItemType.consumable,
        effects: {'strength': 10},
      ),
      ShopItem(
        id: 'endurance-potion',
        name: 'Endurance Potion',
        description: 'Temporarily increases endurance by 8',
        price: 25,
        tier: ShopTier.basic,
        permanent: false,
        type: ItemType.consumable,
        effects: {'endurance': 8},
      ),
      ShopItem(
        id: 'agility-potion',
        name: 'Agility Potion',
        description: 'Temporarily increases agility by 12',
        price: 35,
        tier: ShopTier.meta,
        permanent: false,
        type: ItemType.consumable,
        effects: {'agility': 12},
      ),
    ];
  }
}
