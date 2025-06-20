import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/app_images.dart';

import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorManager.navyColor,
          title: Text('About', style: TextStyles.extraBold24White),
        ),
        body: BackgroundTheme(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04, vertical: h * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.improquestLogo,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Text(
                      "ImproQuest is a gamified platform designed to enhance personal growth and development through engaging quests and challenges.",
                      style: TextStyles.regular16White,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Text(
                      "Developed by a passionate team, ImproQuest aims to make self-improvement fun and rewarding.",
                      style: TextStyles.regular16White,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Text(
                      "Version 1.0.0",
                      style: TextStyles.regular16White,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
