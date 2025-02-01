import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/rankings/presentation/views/widgets/leaderboards_listtile.dart';

import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_images.dart';

class Rankings extends StatefulWidget {
  const Rankings({super.key});

  @override
  State<Rankings> createState() => _RankingsState();
}

class _RankingsState extends State<Rankings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundTheme(
          child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Text(
                            'Leaderboards',
                            style: TextStyles.styleExtraBold(context,
                                fontSize: 38, color: ColorManager.whiteColor),
                          ),
                        ),
                        const SizedBox(height: 35),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 16,
                            itemBuilder: (context, index) {
                              return LeaderboardsListTile(
                                  playerImage: AppImages.profilePhoto,
                                  playerPlace: index,
                                  playerName: "You",
                                  playerPoints: 50);
                            }),
                      ])))),
    );
  }
}
