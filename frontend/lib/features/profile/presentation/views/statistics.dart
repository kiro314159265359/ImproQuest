import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_icons.dart';

class Statistics extends StatefulWidget {
  final UserModel user;
  const Statistics({
    super.key,
    required this.user,
  });

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final Map<String, dynamic> weekStatus = {
    'Su': true,
    'M': false,
    'Tu': true,
    'W': false,
    'Th': null,
    'F': false,
    'Sa': true,
  };

  @override
  Widget build(BuildContext context) {
    final weekDays = weekStatus.keys.toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: ColorManager.gunmetal,
          child: Column(
            children: [
              ListTile(
                leading: Image.asset(AppIcons.flameIcon,
                    width: 25, fit: BoxFit.contain),
                title: Text("${widget.user.streak?.current}",
                    style: TextStyles.bold20Primary),
                subtitle: Text("day streak", style: TextStyles.bold8Primary),
              ),
              SizedBox(
                height: 70,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weekDays.length,
                    itemBuilder: (context, index) {
                      final day = weekDays[index];
                      final isChecked = weekStatus[day];

                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 8,
                        child: Column(
                          children: [
                            Checkbox(
                              shape: const CircleBorder(),
                              activeColor: ColorManager.primaryColor,
                              tristate: true,
                              value: isChecked,
                              onChanged: (bool? value) {},
                            ),
                            Text(day, style: TextStyles.semiBold12lightGrey),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Expanded(
          child: BarChart(
            BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        toY: 100,
                        width: 25,
                        color: ColorManager.primaryColor)
                  ]),
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        toY: 130,
                        width: 25,
                        color: ColorManager.primaryColor)
                  ]),
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        toY: 200,
                        width: 25,
                        color: ColorManager.primaryColor)
                  ]),
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        toY: 250,
                        width: 25,
                        color: ColorManager.primaryColor)
                  ]),
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        toY: 150,
                        width: 25,
                        color: ColorManager.primaryColor)
                  ]),
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        toY: 90,
                        width: 25,
                        color: ColorManager.primaryColor)
                  ]),
                ],
                titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                    topTitles: AxisTitles(),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                        drawBelowEverything: true,
                        axisNameWidget: Text("m")))),
            duration: const Duration(milliseconds: 150), // Optional
            curve: Curves.linear, // Optional
          ),
        )
      ],
    );
  }
}
