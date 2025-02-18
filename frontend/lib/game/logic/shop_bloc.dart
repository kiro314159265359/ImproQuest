// lib/game/logic/shop_bloc.dart
import 'dart:async';
import 'package:flutter_application_2/features/auth/presentation/views/login.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/data/model/user_model.dart';
import '../models/shop_item.dart';

/// Shop Events
abstract class ShopEvent {}

class FetchShopItemsEvent extends ShopEvent {}

class BuyShopItemEvent extends ShopEvent {
  final ShopItem item;
  BuyShopItemEvent(this.item);
}

/// Shop States
abstract class ShopState {}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<ShopItem> items;
  ShopLoaded(this.items);
}

class ShopPurchaseSuccess extends ShopState {
  final ShopItem item;
  ShopPurchaseSuccess(this.item);
}

class ShopError extends ShopState {
  final String message;
  ShopError(this.message);
}

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  // Two currencies:
  int temporaryCurrency = 100; // run-specific currency (does not persist)
  int permanentCurrency = getIt<UserModel>().gold!; // fetched from API in real scenario

  // Inventories:
  final List<ShopItem> temporaryInventory = [];
  final List<ShopItem> permanentInventory = [];

  ShopBloc() : super(ShopInitial()) {
    on<FetchShopItemsEvent>(_onFetchShopItems);
    on<BuyShopItemEvent>(_onBuyShopItem);
  }

  Future<void> _onFetchShopItems(
      FetchShopItemsEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    await Future.delayed(const Duration(seconds: 1)); // simulate API delay
    // Dummy data based on your tiers:
    final items = [
      // Tier 1 (Basic): Consumables – temporary items (reset each run)
      ShopItem(
        id: '1',
        name: 'Small Healing Potion',
        description: 'Heals 10 HP. Resets after each run.',
        price: 50,
        tier: ShopTier.basic,
        permanent: false,
      ),
      // Tier 2 (Meta): Permanent equipment (requires 7-day streak)
      ShopItem(
        id: '2',
        name: 'Steel Sword',
        description: 'Permanent upgrade. Increases strength.',
        price: 500,
        tier: ShopTier.meta,
        permanent: true,
      ),
      // Tier 3 (Prestige): Cosmetic upgrades (monthly challenges)
      ShopItem(
        id: '3',
        name: 'Golden Armor',
        description: 'Cosmetic upgrade. Show off your prestige!',
        price: 1000,
        tier: ShopTier.prestige,
        permanent: true,
      ),
    ];
    emit(ShopLoaded(items));
  }

  Future<void> _onBuyShopItem(
      BuyShopItemEvent event, Emitter<ShopState> emit) async {
    final ShopItem item = event.item;
    if (item.permanent) {
      // Permanent purchase: use permanent currency.
      if (permanentCurrency < item.price) {
        emit(ShopError("Not enough permanent currency to purchase ${item.name}."));
        return;
      }
      permanentCurrency -= item.price;
      // Simulate an API call to update user inventory.
      await Future.delayed(const Duration(seconds: 1));
      permanentInventory.add(item);
      emit(ShopPurchaseSuccess(item));
      // Optionally re-emit loaded state to refresh the UI.
      if (state is ShopLoaded) {
        final loadedState = state as ShopLoaded;
        emit(ShopLoaded(loadedState.items));
      }
    } else {
      // Temporary purchase: use temporary currency.
      if (temporaryCurrency < item.price) {
        emit(ShopError("Not enough temporary currency to purchase ${item.name}."));
        return;
      }
      temporaryCurrency -= item.price;
      temporaryInventory.add(item);
      emit(ShopPurchaseSuccess(item));
      if (state is ShopLoaded) {
        final loadedState = state as ShopLoaded;
        emit(ShopLoaded(loadedState.items));
      }
    }
  }
}
