import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/utils/app_icons.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../../core/widget/appbar_stats.dart';
import '../../../../home/presentation/views/widgets/custom_rich_text.dart';
import 'rank_card.dart';

class StatisticsLoading extends StatelessWidget {
  const StatisticsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    final weekDays = ['Su', 'M', 'Tu', 'W', 'Th', 'F', 'Sa'];

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
        child: Skeletonizer(
          enabled: true,
          enableSwitchAnimation: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.024),
              const AppBarStats(),
              SizedBox(height: h * 0.024),
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
              SizedBox(
                height: h * 0.02,
              ),
              const RankCard(
                userRank: 'E',
              ),
              SizedBox(
                height: h * 0.02,
              ),
              SizedBox(
                height: 150,
                child: Card(
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
                        height: 50,
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
              ),
              SizedBox(height: h * 0.02),
              SizedBox(
                height: 180,
                child: Card(
                  color: ColorManager.gunmetal,
                  child: ListTile(
                    title: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Distance",
                                  style: TextStyles.semiBold16White),
                              Text("Last 7 days",
                                  style: TextStyles.semiBold12lightGrey)
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomRichText(
                                text1: "0.00",
                                textStyle1: TextStyles.semiBold16Primary,
                                text2: "m",
                                textStyle2: TextStyles.semiBold12Primary,
                              ),
                              Text("Today",
                                  style: TextStyles.semiBold12Primary),
                            ],
                          ),
                        ]),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 28),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
