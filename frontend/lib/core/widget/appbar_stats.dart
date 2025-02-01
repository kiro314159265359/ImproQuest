import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/app_images.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../theme/color_manger.dart';
import '../theme/text_style.dart';

class AppBarStats extends StatefulWidget {
  const AppBarStats({super.key});

  @override
  State<AppBarStats> createState() => _AppBarStatsState();
}

class _AppBarStatsState extends State<AppBarStats> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(46, 17, 0, 0),
              child: LinearPercentIndicator(
                width: 125,
                lineHeight: 25,
                percent: 0.5,
                center: CustomRichText(
                  text1: "120/240",
                  textStyle1: TextStyles.styleMedium(context,
                      fontSize: 12, color: ColorManager.whiteColor),
                  text2: "XP",
                  textStyle2: TextStyles.styleMedium(context,
                      fontSize: 8, color: ColorManager.whiteColor),
                ),
                barRadius: const Radius.circular(4),
                backgroundColor: ColorManager.containerBackGround,
                progressColor: const Color(0xff6693EB),
              ),
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: ColorManager.primaryColor,
              child: CircleAvatar(
                radius: 26,
                backgroundImage: const AssetImage(AppImages.profilePhoto),
                child: Transform.translate(
                  offset: const Offset(0, 28),
                  child: Container(
                    decoration: BoxDecoration(
                        color: ColorManager.deepBlue,
                        border:
                            Border.all(color: ColorManager.containerBackGround),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text("25",
                        style: TextStyles.styleMedium(context,
                            fontSize: 8, color: ColorManager.whiteColor),
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: ColorManager.containerBackGround,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              margin: const EdgeInsets.fromLTRB(50, 17, 0, 0),
              width: 110,
              height: 25,
              child: Text("1000",
                  style: TextStyles.styleMedium(context,
                      fontSize: 16, color: ColorManager.whiteColor),
                  textAlign: TextAlign.center),
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: ColorManager.gunmetal,
              child: Image.asset('assets/icons/CoinsIcon.png',
                  width: 25, fit: BoxFit.contain),
            ),
          ],
        ),
      ],
    );
  }
}
