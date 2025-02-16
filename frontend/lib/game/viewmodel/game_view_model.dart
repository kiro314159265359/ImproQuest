// lib/game/viewmodel/game_view_model.dart
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';

class GameViewModel {
  final GameBloc gameBloc;
  GameViewModel(this.gameBloc);

  void attack() {
    gameBloc.add(AttackEvent());
  }

  void defend() {
    gameBloc.add(DefendEvent());
  }

  void openInventory() {
    gameBloc.add(OpenInventoryEvent());
  }

  void useItem(String itemName) {
    gameBloc.add(UseInventoryItemEvent(itemName));
  }

  void nextFight() {
    gameBloc.add(NextFightEvent());
  }
}
