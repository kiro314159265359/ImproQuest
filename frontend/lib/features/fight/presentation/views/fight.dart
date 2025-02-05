import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/widget/custom_primary_button.dart';

import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/widget/appbar_stats.dart';

class Fight extends StatefulWidget {
  const Fight({super.key});

  @override
  State<Fight> createState() => _FightState();
}

class _FightState extends State<Fight> {
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: h * 0.025),
                        const AppBarStats(),
                        SizedBox(height: h * 0.025),
                        Center(
                          child: Card(
                            color: ColorManager.gunmetal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'STAGE 69',
                                    style: TextStyles.styleSemiBold(context,
                                        fontSize: 20,
                                        color: ColorManager.whiteColor),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: ColorManager.containerBackGround,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset(
                                    AppImages.enemy69,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'LEVEL : 200',
                                    style: TextStyles.styleSemiBold(context,
                                        fontSize: 18,
                                        color: ColorManager.whiteColor),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'HP : 1000',
                                      style: TextStyles.styleSemiBold(context,
                                          fontSize: 18,
                                          color: ColorManager.whiteColor),
                                    ),
                                    Text(
                                      'ATK : 1000',
                                      style: TextStyles.styleSemiBold(context,
                                          fontSize: 18,
                                          color: ColorManager.whiteColor),
                                    ),
                                  ],
                                ),
                                SizedBox(height: h * 0.025),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    CustomPrimaryButton(
                                        width: 180,
                                        buttonText: "ENTER BATTLE",
                                        onPressed: () {}),
                                    CustomPrimaryButton(
                                        width: 180,
                                        buttonText: "SHOP",
                                        onPressed: () {})
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ])))),
    );
  }
}
