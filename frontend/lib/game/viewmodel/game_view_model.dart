// lib/game/viewmodel/game_view_model.dart
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';

class GameViewModel {
  final GameBloc gameBloc;
  bool _isPerformingAction = false;

  GameViewModel(this.gameBloc);

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
    if (_isPerformingAction) return;
    _isPerformingAction = true;

    gameBloc.add(OpenInventoryEvent());

    Future.delayed(const Duration(milliseconds: 300), () {
      _isPerformingAction = false;
    });
  }

  void useItem(String itemName) {
    if (_isPerformingAction) return;
    _isPerformingAction = true;

    gameBloc.add(UseInventoryItemEvent(itemName));

    Future.delayed(const Duration(milliseconds: 300), () {
      _isPerformingAction = false;
    });
  }

  void nextFight() {
    gameBloc.add(NextFightEvent());
  }
}
