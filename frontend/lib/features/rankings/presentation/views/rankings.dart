import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/rankings/presentation/views/widgets/leaderboards_list.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: BackgroundTheme(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04, vertical: h * 0.02),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: h * 0.025),
                      Text('Leaderboards', style: TextStyles.extraBold38White),
                      SizedBox(height: h * 0.035),
                      const TabBar(
                        dividerColor: Colors.transparent,
                        labelColor: ColorManager.primaryColor,
                        unselectedLabelColor: ColorManager.darkGreyColor,
                        indicatorColor: ColorManager.primaryColor,
                        tabs: [
                          Tab(text: 'STREAK'),
                          Tab(text: 'LEVEL'),
                        ],
                      ),
                      const Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            LeaderboardsList(leaderboardType: 'streak'),
                            LeaderboardsList(leaderboardType: 'level'),
                          ],
                        ),
                      ),
                    ]))),
      ),
    );
  }
}
