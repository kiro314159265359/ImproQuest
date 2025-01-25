import 'package:flutter/material.dart';

import '../../../core/theme/color_manger.dart';
import '../../../core/theme/text_style.dart';

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
              margin: const EdgeInsets.fromLTRB(50, 17, 0, 0),
              width: 125,
              height: 25,
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  color: Color(0xff6693EB),
                  value: 0.5,
                  backgroundColor: ColorManager.containerBackGround,
                ),
              ),
            ),
            const CircleAvatar(
              radius: 30,
              backgroundColor: ColorManager.primaryColor,
              child: CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage('assets/images/ProfilePhoto.png'),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CircleAvatar(
                    backgroundColor: ColorManager.whiteColor,
                    radius: 8.0,
                    child: Icon(
                      Icons.camera_alt,
                      size: 12.0,
                      color: Color(0xFF404040),
                    ),
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
              width: 125,
              height: 25,
              child: Text("1000",
                  style: TextStyles.styleMedium(context,
                      fontSize: 16, color: ColorManager.whiteColor),
                  textAlign: TextAlign.center),
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: ColorManager.gunmetal,
              child: Image.asset('assets/images/CoinsIcon.png',
                  width: 25, fit: BoxFit.contain),
            ),
          ],
        ),
      ],
    );
  }
}
