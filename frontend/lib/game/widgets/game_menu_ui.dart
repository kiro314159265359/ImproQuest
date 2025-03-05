import 'package:flutter/material.dart';
import '../logic/game_bloc.dart';
import '../logic/game_state.dart';
import '../shop_page.dart';
import 'enemy_blind_card.dart';

class GameMenuUI extends StatelessWidget {
  final GameState state;
  final GameBloc bloc;

  const GameMenuUI({
    super.key,
    required this.state,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Current Ante: ${state.currentAnte}',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          _buildPlayerStats(),
          const SizedBox(height: 24),
          const Text('Select a Blind to Fight:',
              style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          _buildBlindSelectionRow(),
          const SizedBox(height: 24),
          Text(state.message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopPage()),
              );
            },
            child: const Text('Permanent Shop'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStats() {
    return Text(
      'Player Stats:\nHP: ${state.player.currentHp}/${state.player.vitality}\n'
      'Strength: ${state.player.strength}  Endurance: ${state.player.endurance}  '
      'Agility: ${state.player.agility}',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildBlindSelectionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: EnemyBlindCard(
              bloc: bloc,
              blind: 1,
              currentAnte: state.currentAnte,
              currentBlind: state.currentBlind),
        ),
        Expanded(
          child: EnemyBlindCard(
              bloc: bloc,
              blind: 2,
              currentAnte: state.currentAnte,
              currentBlind: state.currentBlind),
        ),
        Expanded(
          child: EnemyBlindCard(
              bloc: bloc,
              blind: 3,
              currentAnte: state.currentAnte,
              currentBlind: state.currentBlind),
        ),
      ],
    );
  }
}
