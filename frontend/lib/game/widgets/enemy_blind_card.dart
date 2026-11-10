import 'package:flutter/material.dart';
import '../../core/theme/color_manger.dart';
import '../../core/theme/text_style.dart';
import '../../core/utils/app_icons.dart';
import '../constants/game_constants.dart';

class EnemyBlindCard extends StatelessWidget {
  final int blind;
  final int currentAnte;
  final int currentBlind;

  const EnemyBlindCard({
    super.key,
    required this.blind,
    required this.currentAnte,
    required this.currentBlind,
  });

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    final enemyType = _getEnemyType();
    final stats = _calculateStats();

    final bool isAvailable = blind == currentBlind;

    return Card(
      color: isAvailable ? ColorManager.primaryColor : ColorManager.gunmetal,
      child: Padding(
        padding: EdgeInsets.all(w * 0.02),
        child: Column(
          children: [
            Text('Blind $blind: $enemyType', style: TextStyles.semiBold16White),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ImageIcon(
                            AssetImage(AppIcons.strengthIcon),
                            color: ColorManager.whiteColor,
                            size: 24,
                          ),
                          SizedBox(width: w * 0.01),
                          Text('Strength: ${stats.strength}',
                              style: TextStyles.medium16White),
                        ],
                      ),
                      SizedBox(height: h * 0.02),
                      Row(
                        children: [
                          const ImageIcon(
                            AssetImage(AppIcons.enduranceIcon),
                            color: ColorManager.whiteColor,
                            size: 24,
                          ),
                          SizedBox(width: w * 0.01),
                          Text('Endurance: ${stats.endurance}',
                              style: TextStyles.medium16White),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(w * 0.02),
                    child: const VerticalDivider(
                      width: 2,
                      color: ColorManager.lightGrey,
                      thickness: 2,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ImageIcon(
                            AssetImage(AppIcons.vitalityIcon),
                            color: ColorManager.whiteColor,
                            size: 24,
                          ),
                          SizedBox(width: w * 0.01),
                          Text('Vitality: ${stats.vitality}',
                              style: TextStyles.medium16White),
                        ],
                      ),
                      SizedBox(height: h * 0.02),
                      Row(
                        children: [
                          const ImageIcon(
                            AssetImage(AppIcons.agilityIcon),
                            color: ColorManager.whiteColor,
                            size: 24,
                          ),
                          SizedBox(width: w * 0.01),
                          Text('Agility: ${stats.agility}',
                              style: TextStyles.medium16White),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEnemyType() {
    if (blind == GameConstants.bossBlind) return 'Boss';
    if (blind == GameConstants.bigEnemyBlind) return 'Big Enemy';
    return 'Small Enemy';
  }

  _EnemyStats _calculateStats() {
    int baseVitality, baseStrength, baseEndurance, baseAgility;

    if (blind == GameConstants.bossBlind) {
      baseVitality = GameConstants.bossBaseVitality;
      baseStrength = GameConstants.bossBaseStrength;
      baseEndurance = GameConstants.bossBaseEndurance;
      baseAgility = GameConstants.bossBaseAgility;
    } else if (blind == GameConstants.bigEnemyBlind) {
      baseVitality = GameConstants.bigEnemyBaseVitality;
      baseStrength = GameConstants.bigEnemyBaseStrength;
      baseEndurance = GameConstants.bigEnemyBaseEndurance;
      baseAgility = GameConstants.bigEnemyBaseAgility;
    } else {
      baseVitality = GameConstants.smallEnemyBaseVitality;
      baseStrength = GameConstants.smallEnemyBaseStrength;
      baseEndurance = GameConstants.smallEnemyBaseEndurance;
      baseAgility = GameConstants.smallEnemyBaseAgility;
    }

    return _EnemyStats(
      vitality: baseVitality * currentAnte,
      strength: baseStrength * currentAnte,
      endurance: baseEndurance * currentAnte,
      agility: baseAgility * currentAnte,
    );
  }
}

class _EnemyStats {
  final int vitality;
  final int strength;
  final int endurance;
  final int agility;

  _EnemyStats({
    required this.vitality,
    required this.strength,
    required this.endurance,
    required this.agility,
  });
}
