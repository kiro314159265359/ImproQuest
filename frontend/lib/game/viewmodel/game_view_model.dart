// lib/game/viewmodel/game_view_model.dart
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../logic/shop_bloc.dart';
import '../logic/shop_event.dart';
import '../models/shop_item.dart';

class GameViewModel {
  final GameBloc gameBloc;
  final ShopBloc? shopBloc;
  bool _isPerformingAction = false;

  GameViewModel(this.gameBloc, {this.shopBloc});

  void attack() {
    if (_isPerformingAction) return;
    _isPerformingAction = true;

    // Add a small delay before allowing next action
    gameBloc.add(AttackEvent());

    Future.delayed(const Duration(milliseconds: 500), () {
      _isPerformingAction = false;
    });
  }

  void defend() {
    if (_isPerformingAction) return;
    _isPerformingAction = true;

    gameBloc.add(DefendEvent());

    Future.delayed(const Duration(milliseconds: 500), () {
      _isPerformingAction = false;
    });
  }

  void openInventory() {
    if (_isPerformingAction) {
      print('Cannot open inventory - already performing action');
      return;
    }
    _isPerformingAction = true;

    print('Sending OpenInventoryEvent from ViewModel');
    gameBloc.add(OpenInventoryEvent());

    Future.delayed(const Duration(milliseconds: 300), () {
      _isPerformingAction = false;
    });
  }

  void useItem(ShopItem item) {
    if (_isPerformingAction) {
      print('ViewModel: Cannot use item - already performing action');
      return;
    }
    _isPerformingAction = true;

    print('ViewModel: Using item ${item.name} with effects: ${item.effects}');

    // Send event to GameBloc to apply item effect
    gameBloc.add(UseInventoryItemEvent(item));

    // Send event to ShopBloc to decrement item quantity
    if (shopBloc != null) {
      print('ViewModel: Sending event to remove item from inventory');
      shopBloc!.add(RemoveTemporaryItemFromInventoryEvent(item));
    } else {
      print('ViewModel: ShopBloc is null, cannot remove item from inventory');
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _isPerformingAction = false;
    });
  }

  void nextFight() {
    // Prevent multiple actions
    if (_isPerformingAction) return;
    _isPerformingAction = true;

    print('Starting next fight through GameViewModel');
    gameBloc.add(NextFightEvent());

    // Allow next action after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _isPerformingAction = false;
    });
  }
}
