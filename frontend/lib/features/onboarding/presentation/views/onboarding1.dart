import 'package:flutter/material.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_images.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: BackgroundTheme(
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04, vertical: h * 0.02),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: h * 0.025),
                        Image.asset(
                          AppImages.improquestLogo,
                          width: w * 0.8,
                          height: h * 0.4,
                        ),
                        SizedBox(height: h * 0.025),
                        Text('Welcome to ImproQuest',
                            style: TextStyles.bold18White,
                            textAlign: TextAlign.center),
                        Text('Gamified Self Improvement App',
                            style: TextStyles.bold16White,
                            textAlign: TextAlign.center),
                        SizedBox(height: h * 0.025),
                        Text('start your journey to self-improvement',
                            style: TextStyles.regular14White,
                            textAlign: TextAlign.center),
                        SizedBox(height: h * 0.025),
                    
                      ])))),
    );
  }
}
