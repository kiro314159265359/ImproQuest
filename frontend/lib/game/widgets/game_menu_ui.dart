import 'package:flutter/material.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/color_manger.dart';
import '../../core/theme/text_style.dart';
import '../../core/utils/app_icons.dart';
import '../logic/game_bloc.dart';
import '../logic/game_event.dart';
import '../logic/game_state.dart';
import 'enemy_blind_card.dart';
import '../../core/widget/custom_button.dart';

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
    // var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Ante: ${state.currentAnte}',
                style: TextStyles.regular24White),
            SizedBox(height: h * 0.016),
            _buildPlayerStats(context),
            SizedBox(height: h * 0.024),
            _buildBlindSelectionRow(h),
            SizedBox(height: h * 0.024),
            CustomButton(
                fillColor: ColorManager.primaryColor,
                buttonText: "Start Fight",
                onPressed: () {
                  bloc.add(SelectBlindEvent(state.currentBlind));
                },
                buttonIcon: AppIcons.fightIcon),
            SizedBox(height: h * 0.014),
            CustomButton(
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
        style: TextStyles.semiBold16White);
  }

  Widget _buildBlindSelectionRow(double h) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        EnemyBlindCard(
            blind: 1,
            currentAnte: state.currentAnte,
            currentBlind: state.currentBlind),
        SizedBox(height: h * 0.016),
        EnemyBlindCard(
            blind: 2,
            currentAnte: state.currentAnte,
            currentBlind: state.currentBlind),
        SizedBox(height: h * 0.016),
        EnemyBlindCard(
            blind: 3,
            currentAnte: state.currentAnte,
            currentBlind: state.currentBlind),
      ],
    );
  }
}
