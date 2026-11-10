import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/get_it_constants.dart';
import '../../features/home/data/model/user_model.dart';
import '../models/inventory_item.dart';
import '../models/shop_item.dart';
import '../services/shop_api.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopApi apiService = getIt<ShopApi>();
  int temporaryCurrency = 100; // Starting temporary gold
  UserModel user;
  late int permanentCurrency;

  List<ShopItem> permanentItemsCache = [];
  List<ShopItem> temporaryItemsCache = [];

  // Change: Store InventoryItem objects instead of ShopItems
  final List<InventoryItem> temporaryInventory = [];
  final List<InventoryItem> permanentInventory = [];

  ShopBloc({
    required this.user,
  }) : super(ShopInitial()) {
    permanentCurrency = user.gold ?? 0;
    on<FetchPermanentItemsEvent>(_onFetchPermanentItems);
    on<FetchTemporaryItemsEvent>(_onFetchTemporaryItems);
    on<BuyPermanentItemEvent>(_onBuyPermanentItem);
    on<BuyTemporaryItemEvent>(_onBuyTemporaryItem);
    on<RewardTemporaryGoldEvent>(_onRewardTemporaryGold);
    on<ResetTemporaryGoldEvent>(_onResetTemporaryGold);
    on<ResetTemporaryShopItemsEvent>(_onResetTemporaryShopItems);
    on<RemoveTemporaryItemFromInventoryEvent>(_onRemoveTemporaryItem);
  }

  Future<void> _onFetchPermanentItems(
      FetchPermanentItemsEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      permanentItemsCache = await apiService.getPermanentItems();
      // Update permanent currency from user model
      permanentCurrency = user.gold ?? 0;

      emit(PermanentShopLoaded(
        items: permanentItemsCache,
        permanentCurrency: permanentCurrency,
      ));
    } catch (e) {
      emit(ShopError("Failed to load permanent items: ${e.toString()}"));
    }
  }

  Future<void> _onFetchTemporaryItems(
      FetchTemporaryItemsEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      // Save the current currency value before loading items
      int currentGold = temporaryCurrency;

      // Fetch temporary items from the API instead of using predefined list
      temporaryItemsCache = await apiService.getTemporaryItems();

      // Use the saved currency value, not a hardcoded one
      emit(TemporaryShopLoaded(
        items: temporaryItemsCache,
        temporaryCurrency: currentGold, // Use current value, not a default
      ));
    } catch (e) {
      emit(ShopError("Failed to load temporary items: ${e.toString()}"));
      // Fall back to empty list if API fails, but still preserve currency
      emit(TemporaryShopLoaded(
        items: [],
        temporaryCurrency: temporaryCurrency, // Use current value
      ));
    }
  }

  Future<void> _onBuyPermanentItem(
      BuyPermanentItemEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final success = await apiService.purchaseItem(event.itemId);

      if (success) {
        // Update user model by fetching latest data (handled elsewhere)
        // For now, just update the local cache
        permanentCurrency -= event.price;

        // Check if item already exists in inventory
        final existingIndex = permanentInventory
            .indexWhere((inventoryItem) => inventoryItem.id == event.item.id);

        if (existingIndex != -1) {
          // If item exists, increment quantity
          permanentInventory[existingIndex].incrementQuantity();
        } else {
          // Otherwise, add new item with quantity 1
          permanentInventory.add(InventoryItem(item: event.item));
        }

        emit(ShopPurchaseSuccess(event.item));
        emit(PermanentShopLoaded(
          items: permanentItemsCache,
          permanentCurrency: permanentCurrency,
        ));
      }
    } on AlreadyOwnedItemException catch (e) {
      // Handle the "already owned" case with a friendly message
      emit(ShopAlreadyOwned(e.message, event.item));
      emit(PermanentShopLoaded(
        items: permanentItemsCache,
        permanentCurrency: permanentCurrency,
      ));
    } catch (e) {
      emit(ShopError(e.toString()));
      emit(PermanentShopLoaded(
        items: permanentItemsCache,
        permanentCurrency: permanentCurrency,
      ));
    }
  }

  Future<void> _onBuyTemporaryItem(
      BuyTemporaryItemEvent event, Emitter<ShopState> emit) async {
    if (temporaryCurrency < event.item.price) {
      emit(ShopError(
          "Not enough temporary gold to purchase ${event.item.name}"));
      emit(TemporaryShopLoaded(
        items: temporaryItemsCache,
        temporaryCurrency: temporaryCurrency,
      ));
      return;
    }

    // Process temporary item purchase locally
    temporaryCurrency -= event.item.price;

    // Check if item already exists in inventory
    final existingIndex = temporaryInventory
        .indexWhere((inventoryItem) => inventoryItem.id == event.item.id);

    print('Buying item ${event.item.name}, existing index: $existingIndex');

    if (existingIndex != -1) {
      // If item exists, increment quantity
      temporaryInventory[existingIndex].incrementQuantity();
      print(
          'Incremented quantity of ${event.item.name} to ${temporaryInventory[existingIndex].quantity}');
    } else {
      // Otherwise, add new item with quantity 1
      temporaryInventory.add(InventoryItem(item: event.item));
      print('Added new item ${event.item.name} to inventory');
    }

    emit(ShopPurchaseSuccess(event.item));
    emit(TemporaryShopLoaded(
      items: temporaryItemsCache,
      temporaryCurrency: temporaryCurrency,
    ));
  }

  Future<void> _onRewardTemporaryGold(
      RewardTemporaryGoldEvent event, Emitter<ShopState> emit) async {
    print(
        'Rewarding player with ${event.reward} gold. Before: $temporaryCurrency');
    temporaryCurrency += event.reward;
    print('New gold balance: $temporaryCurrency');

    emit(TemporaryShopLoaded(
      items: temporaryItemsCache,
      temporaryCurrency: temporaryCurrency,
    ));
  }

  Future<void> _onResetTemporaryGold(
      ResetTemporaryGoldEvent event, Emitter<ShopState> emit) async {
    temporaryCurrency = 100; // Reset to starting value
    emit(TemporaryShopLoaded(
      items: temporaryItemsCache,
      temporaryCurrency: temporaryCurrency,
    ));
  }

  Future<void> _onResetTemporaryShopItems(
      ResetTemporaryShopItemsEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      // Re-fetch temporary items from the API
      temporaryItemsCache = await apiService.getTemporaryItems();
      temporaryInventory.clear(); // Clear temporary inventory on reset

      emit(TemporaryShopLoaded(
        items: temporaryItemsCache,
        temporaryCurrency: temporaryCurrency,
      ));
    } catch (e) {
      emit(ShopError("Failed to refresh temporary items: ${e.toString()}"));
      // Keep current items if refresh fails
      emit(TemporaryShopLoaded(
        items: temporaryItemsCache,
        temporaryCurrency: temporaryCurrency,
      ));
    }
  }

  Future<void> _onRemoveTemporaryItem(
      RemoveTemporaryItemFromInventoryEvent event,
      Emitter<ShopState> emit) async {
    print('ShopBloc: Using item ${event.item.name} from inventory');

    // Find the item in inventory
    final existingIndex = temporaryInventory
        .indexWhere((inventoryItem) => inventoryItem.id == event.item.id);

    if (existingIndex != -1) {
      print(
          'ShopBloc: Found item at index $existingIndex with quantity ${temporaryInventory[existingIndex].quantity}');

      // Decrement quantity
      final decremented = temporaryInventory[existingIndex].decrementQuantity();

      if (decremented) {
        print(
            'ShopBloc: Decremented quantity to ${temporaryInventory[existingIndex].quantity}');

        // If quantity is zero, remove the item from inventory
        if (temporaryInventory[existingIndex].quantity <= 0) {
          print('ShopBloc: Removing item from inventory as quantity is zero');
          temporaryInventory.removeAt(existingIndex);
        }

        // Re-emit current state to refresh UI
        if (state is TemporaryShopLoaded) {
          emit(TemporaryShopLoaded(
            items: temporaryItemsCache,
            temporaryCurrency: temporaryCurrency,
          ));
        }
      }
    } else {
      print('ShopBloc: Item not found in inventory!');
    }
  }
}
