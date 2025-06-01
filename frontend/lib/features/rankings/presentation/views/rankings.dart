import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_application_2/features/rankings/presentation/views/widgets/leaderboards_list.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/get_it_constants.dart';
import '../../../home/data/model/user_model.dart';

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
                      SizedBox(height: h * 0.032),
                      Text('Leaderboards', style: TextStyles.extraBold28White),
                      CustomRichText(
                          text1: "${getIt<UserModel>().rank}",
                          textStyle1: TextStyles.bold24Primary,
                          text2: " Tier",
                          textStyle2: TextStyles.bold24White),
                      SizedBox(height: h * 0.024),
                      TabBar(
                        labelStyle: TextStyles.bold12White,
                        dividerColor: Colors.transparent,
                        labelColor: ColorManager.primaryColor,
                        unselectedLabelColor: ColorManager.darkGreyColor,
                        indicatorColor: ColorManager.primaryColor,
                        tabs: const [
                          Tab(text: 'STREAK'),
                          Tab(text: 'LEVEL'),
                        ],
                      ),
                      const Expanded(
                        child: TabBarView(
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
