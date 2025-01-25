import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/home/widgets/appbar_stats.dart';
import 'package:flutter_application_2/features/home/widgets/custom_rich_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math' as math;
import '../../core/theme/color_manger.dart';
import '../../core/theme/text_style.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorManager.navyColor,
              ColorManager.deepBlue,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                const AppBarStats(),
                const SizedBox(height: 25),
                CustomRichText(
                  text1: 'Welcome, ',
                  textStyle1: TextStyles.styleExtraBold(context,
                      fontSize: 30, color: ColorManager.whiteColor),
                  text2: 'Player',
                  textStyle2: TextStyles.styleExtraBold(context,
                      fontSize: 30, color: ColorManager.primaryColor),
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: const BoxDecoration(
                      color: ColorManager.gunmetal,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  width: double.infinity,
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("DAILY QUESTS",
                              style: TextStyles.styleBold(context,
                                  fontSize: 24, color: ColorManager.whiteColor),
                              textAlign: TextAlign.center),
                          CustomRichText(
                            text1: '1 Quest ',
                            textStyle1: TextStyles.styleSemiBold(context,
                                fontSize: 18, color: const Color(0xFFA4FF72)),
                            text2: 'completed',
                            textStyle2: TextStyles.styleSemiBold(context,
                                fontSize: 18, color: const Color(0xFFB7B7B9)),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                                color: ColorManager.containerBackGround,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text("3 Quests left",
                                style: TextStyles.styleSemiBold(context,
                                    fontSize: 18,
                                    color: ColorManager.whiteColor),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      CircularPercentIndicator(
                          backgroundColor: ColorManager.containerBackGround,
                          radius: 60,
                          lineWidth: 10.0,
                          percent: 0.25,
                          center: Text("25%",
                              style: TextStyles.styleSemiBold(context,
                                  fontSize: 20, color: ColorManager.whiteColor),
                              textAlign: TextAlign.center),
                          linearGradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: <Color>[
                                Color(0xFFA4FF72),
                                Color(0xFFA4FF72)
                              ]),
                          rotateLinearGradient: true,
                          circularStrokeCap: CircularStrokeCap.round)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: ColorManager.deepBlue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: IconButton(
                icon: const ImageIcon(
                  AssetImage('assets/images/HomeIcon.png'),
                  color: ColorManager.primaryColor,
                  size: 25,
                ),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: IconButton(
                icon: const ImageIcon(
                  AssetImage('assets/images/ProfileIcon.png'),
                  color: ColorManager.whiteColor,
                  size: 25,
                ),
                onPressed: () {},
              ),
            ),
            const Expanded(child: Text('')),
            Expanded(
              child: IconButton(
                icon: const ImageIcon(
                  AssetImage('assets/images/RankingsIcon.png'),
                  color: ColorManager.whiteColor,
                  size: 25,
                ),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: IconButton(
                icon: const ImageIcon(
                  AssetImage('assets/images/SettingsIcon.png'),
                  color: ColorManager.whiteColor,
                  size: 25,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationZ(
          math.pi / 4,
        ),
        child: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Fight',
          elevation: 15.0,
          backgroundColor: ColorManager.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7.0),
          ),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(
              -math.pi / 4,
            ),
            child: const ImageIcon(
              AssetImage('assets/images/Swords.png'),
              color: ColorManager.whiteColor,
              size: 25,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
