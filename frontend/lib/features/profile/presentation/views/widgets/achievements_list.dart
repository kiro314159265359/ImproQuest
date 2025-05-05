import 'package:flutter/material.dart';

import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../../core/utils/app_icons.dart';

class AchievementsList extends StatefulWidget {
  final bool isLocked;

  const AchievementsList({super.key, required this.isLocked});

  @override
  State<AchievementsList> createState() => _AchievementsListState();
}

class _AchievementsListState extends State<AchievementsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return Card(
            color: ColorManager.gunmetal,
            child: ListTile(
              leading: Image.asset(
                  widget.isLocked
                      ? AppIcons.trophyLockedIcon
                      : AppIcons.trophyUnlockedIcon,
                  width: 65),
              title: Text("ACHIEVEMENT", style: TextStyles.bold20White),
              subtitle: Text("BLABLABLABLABLABLABLABLABLABLABLABLA",
                  style: TextStyles.regular12White),
            ),
          );
        });
  }
}
