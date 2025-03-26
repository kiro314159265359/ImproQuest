import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/profile/presentation/views/widgets/achievements_list.dart';
import '../../../../core/theme/color_manger.dart';

class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            dividerColor: Colors.transparent,
            labelColor: ColorManager.primaryColor,
            unselectedLabelColor: ColorManager.darkGreyColor,
            indicatorColor: ColorManager.primaryColor,
            tabs: [
              Tab(
                text: 'Unlocked',
                icon: Icon(Icons.lock_open),
              ),
              Tab(
                text: 'Locked',
                icon: Icon(Icons.lock_outline),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                AchievementsList(isLocked: false),
                AchievementsList(isLocked: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
