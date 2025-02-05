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
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: BackgroundTheme(
          child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04, vertical: h * 0.02),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: h * 0.025),
                        Text(
                          'Leaderboards',
                          style: TextStyles.styleExtraBold(context,
                              fontSize: 38, color: ColorManager.whiteColor),
                        ),
                        SizedBox(height: h * 0.035),
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
