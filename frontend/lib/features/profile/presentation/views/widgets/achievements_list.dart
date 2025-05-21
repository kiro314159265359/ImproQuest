import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../../core/utils/app_icons.dart';
import '../../../../home/data/model/achievement_model.dart';

class AchievementsList extends StatefulWidget {
  final bool isLocked;
  final bool isLoading;
  final List<AchievementModel> achievementsList;

  const AchievementsList({
    super.key,
    required this.isLocked,
    required this.isLoading,
    required this.achievementsList,
  });

  @override
  State<AchievementsList> createState() => _AchievementsListState();
}

class _AchievementsListState extends State<AchievementsList> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.achievementsList.isEmpty) {
      return Center(
        child: Text(
          widget.isLocked
              ? 'No locked achievements.'
              : 'No unlocked achievements yet!',
          style: TextStyles.regular16White,
        ),
      );
    }
    return Skeletonizer(
      enabled: widget.isLoading,
      enableSwitchAnimation: true,
      child: ListView.builder(
          itemCount: widget.achievementsList.length,
          itemBuilder: (context, index) {
            final achievement = widget.achievementsList[index];
            return Card(
              color: ColorManager.gunmetal,
              child: ListTile(
                leading: Image.asset(
                    widget.isLocked
                        ? AppIcons.trophyLockedIcon
                        : AppIcons.trophyUnlockedIcon,
                    width: 65),
                title: Text(achievement.name!, style: TextStyles.bold20White),
                subtitle: Text(achievement.description!,
                    style: TextStyles.regular12White),
              ),
            );
          }),
    );
  }
}
