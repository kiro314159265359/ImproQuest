import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/data/model/user_model.dart';
import '../models/shop_item.dart';
import 'shop_event.dart';
import 'shop_state.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

List<ShopItem> getNewTemporaryItems() {
  // For example, generate a new list of temporary items.
  return [
    ShopItem(
      id: '1',
      name: 'Small Healing Potion',
      description: 'Heals 10 HP. Resets after each run.',
      price: 50,
      tier: ShopTier.basic,
      permanent: false,
    ),
    // You can add more items or randomize as needed.
  ];
}

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  int temporaryCurrency = 100;
  int permanentCurrency = getIt<UserModel>().gold!;
  // Store permanent items separately.
  List<ShopItem> permanentItemsCache = [
    ShopItem(
      id: '2',
      name: 'Steel Sword',
      description: 'Permanent upgrade. Increases strength.',
      price: 500,
      tier: ShopTier.meta,
      permanent: true,
    ),
    ShopItem(
      id: '3',
      name: 'Golden Armor',
      description: 'Cosmetic upgrade. Show off your prestige!',
      price: 1000,
      tier: ShopTier.prestige,
      permanent: true,
    ),
  ];
  // Temporary items will be regenerated each fight.
  List<ShopItem> temporaryItemsCache = getNewTemporaryItems();

  // Combined list (for display) is permanent items + temporary items.
  List<ShopItem> get allItems => [...permanentItemsCache, ...temporaryItemsCache];

  // Optionally, maintain inventories.
  final List<ShopItem> temporaryInventory = [];
  final List<ShopItem> permanentInventory = [];

  ShopBloc() : super(ShopInitial()) {
    on<FetchShopItemsEvent>(_onFetchShopItems);
    on<BuyShopItemEvent>(_onBuyShopItem);
    on<RewardTemporaryGoldEvent>(_onRewardTemporaryGold);
    on<ResetTemporaryGoldEvent>(_onResetTemporaryGold);
    on<ResetTemporaryShopItemsEvent>(_onResetTemporaryShopItems);
  }

  Future<void> _onFetchShopItems(FetchShopItemsEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    await Future.delayed(const Duration(seconds: 1)); // simulate API delay
    // Combine permanent and temporary items.
    emit(ShopLoaded(
      items: allItems,
      temporaryCurrency: temporaryCurrency,
      permanentCurrency: permanentCurrency,
    ));
  }

  Future<void> _onBuyShopItem(BuyShopItemEvent event, Emitter<ShopState> emit) async {
    final ShopItem item = event.item;

    if (item.permanent) {
      if (permanentCurrency < item.price) {
        emit(ShopError("Not enough permanent currency to purchase ${item.name}."));
        // Immediately re-emit the current shop state to reset the UI.

        return;
      }
      permanentCurrency -= item.price;
      await Future.delayed(const Duration(seconds: 1));
      permanentInventory.add(item);
    } else {
      if (temporaryCurrency < item.price) {
        emit(ShopError("Not enough temporary currency to purchase ${item.name}."));
        emit(ShopLoaded(
          items: allItems,
          temporaryCurrency: temporaryCurrency,
          permanentCurrency: permanentCurrency,
        ));
        return;
      }
      temporaryCurrency -= item.price;
      temporaryInventory.add(item);
    }

    emit(ShopLoaded(
      items: allItems,
      temporaryCurrency: temporaryCurrency,
      permanentCurrency: permanentCurrency,
    ));
  }



  Future<void> _onRewardTemporaryGold(RewardTemporaryGoldEvent event, Emitter<ShopState> emit) async {
    temporaryCurrency += event.reward;
    if (state is ShopLoaded) {
      emit(ShopLoaded(
        items: allItems,
        temporaryCurrency: temporaryCurrency,
        permanentCurrency: permanentCurrency,
      ));
    }
  }

  Future<void> _onResetTemporaryGold(ResetTemporaryGoldEvent event, Emitter<ShopState> emit) async {
    temporaryCurrency = 100;
    if (state is ShopLoaded) {
      emit(ShopLoaded(
        items: allItems,
        temporaryCurrency: temporaryCurrency,
        permanentCurrency: permanentCurrency,
      ));
    }
  }

  Future<void> _onResetTemporaryShopItems(ResetTemporaryShopItemsEvent event, Emitter<ShopState> emit) async {
    // Regenerate temporary items for the new fight.
    temporaryItemsCache = getNewTemporaryItems();
    // Emit updated state.
    if (state is ShopLoaded) {
      emit(ShopLoaded(
        items: allItems,
        temporaryCurrency: temporaryCurrency,
        permanentCurrency: permanentCurrency,
      ));
    }
  }
}
