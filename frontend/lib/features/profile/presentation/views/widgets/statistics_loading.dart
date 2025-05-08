import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/utils/app_icons.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../../core/widget/appbar_stats.dart';

class StatisticsLoading extends StatelessWidget {
  const StatisticsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    final weekDays = ['Su', 'M', 'Tu', 'W', 'Th', 'F', 'Sa'];

    return Skeletonizer(
      enabled: true,
      enableSwitchAnimation: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.025),
            const AppBarStats(),
            SizedBox(height: h * 0.025),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "STATS",
                  style: TextStyles.bold20White,
                ),
                Text(
                  "STATS",
                  style: TextStyles.bold20White,
                ),
                Text(
                  "STATS",
                  style: TextStyles.bold20White,
                ),
              ],
            ),
            Card(
              color: ColorManager.gunmetal,
              child: Column(
                children: [
                  ListTile(
                    leading: Image.asset(AppIcons.flameIcon,
                        width: 25, fit: BoxFit.contain),
                    title: Text("0", style: TextStyles.bold20Primary),
                    subtitle:
                        Text("day streak", style: TextStyles.bold8Primary),
                  ),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: weekDays.length,
                        itemBuilder: (context, index) {
                          final day = weekDays[index];

                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 8,
                            child: Column(
                              children: [
                                Text(day,
                                    style: TextStyles.semiBold12lightGrey),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 25,
                      height: 100 + (index * 30) % 150,
                      decoration: const BoxDecoration(
                        color: ColorManager.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
