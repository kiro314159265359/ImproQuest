import 'package:flutter/material.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/color_manger.dart';
import '../../core/theme/text_style.dart';
import '../../core/utils/app_icons.dart';
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../logic/game_state.dart';
import 'enemy_blind_card.dart';
import 'menu_button.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Ante: ${state.currentAnte}',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            _buildPlayerStats(context),
            const SizedBox(height: 24),
            _buildBlindSelectionRow(),
            const SizedBox(height: 24),
            MenuButton(
                fillColor: ColorManager.primaryColor,
                buttonText: "Start Fight",
                onPressed: () {
                  bloc.add(SelectBlindEvent(state.currentBlind));
                },
                buttonIcon: AppIcons.fightIcon),
            const SizedBox(height: 14),
            MenuButton(
                borderColor: ColorManager.lightGrey,
                buttonText: "Permanent Shop",
                onPressed: () {
                  Navigator.pushNamed(context, Routes.shopScreen);
                },
                buttonIcon: AppIcons.fightIcon),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStats(context) {
    return Text(
      'Player Stats:\nHP: ${state.player.currentHp}/${state.player.vitality}\n'
      'Strength: ${state.player.strength}  Endurance: ${state.player.endurance}  '
      'Agility: ${state.player.agility}',
      textAlign: TextAlign.center,
      style: TextStyles.styleSemiBold(context,
          fontSize: 16, color: ColorManager.whiteColor),
    );
  }

  Widget _buildBlindSelectionRow() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        EnemyBlindCard(
            blind: 1,
            currentAnte: state.currentAnte,
            currentBlind: state.currentBlind),
        const SizedBox(height: 16),
        EnemyBlindCard(
            blind: 2,
            currentAnte: state.currentAnte,
            currentBlind: state.currentBlind),
        const SizedBox(height: 16),
        EnemyBlindCard(
            blind: 3,
            currentAnte: state.currentAnte,
            currentBlind: state.currentBlind),
      ],
    );
  }
}
