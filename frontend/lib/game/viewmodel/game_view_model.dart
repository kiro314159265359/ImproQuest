// lib/game/viewmodel/game_view_model.dart
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void run() {
    gameBloc.add(RunEvent());
  }

  void openInventory() {
    gameBloc.add(OpenInventoryEvent());
    // In a more complete implementation, you might navigate to a dedicated inventory screen.
  }

  void useItem(String itemName) {
    gameBloc.add(UseInventoryItemEvent(itemName));
  }
}
