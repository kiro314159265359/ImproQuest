import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/home/data/model/distance_model.dart';
import 'package:flutter_application_2/features/profile/presentation/manager/distance_cubit.dart';
import 'package:flutter_application_2/features/profile/presentation/manager/distance_state.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/get_it_constants.dart'; // Import getIt

enum ChartDataType { week, month, year }

class Distance extends StatefulWidget {
  const Distance({super.key});

  @override
  State<Distance> createState() => _DistanceState();
}

class _DistanceState extends State<Distance> {
  late DistanceCubit _weekDistanceCubit;
  late DistanceCubit _monthDistanceCubit;
  late DistanceCubit _yearDistanceCubit;

  @override
  void initState() {
    super.initState();
    // Instantiate separate cubits using getIt
    _weekDistanceCubit = getIt<DistanceCubit>()..getDistanceWeek();
    _monthDistanceCubit = getIt<DistanceCubit>()..getDistanceMonth();
    _yearDistanceCubit = getIt<DistanceCubit>()..getDistanceYear();
  }

  ({List<double> data, List<String> labels}) _prepareChartData(
      List<DistanceModel> distancePoints, ChartDataType type) {
    List<double> resultData = [];
    List<String> resultLabels = [];

    switch (type) {
      case ChartDataType.week:
        resultLabels.addAll(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]);
        resultData.addAll(List.filled(7, 0.0));

        const Map<String, int> dayNameToIndex = {
          "mo": 0,
          "mon": 0,
          "monday": 0,
          "tu": 1,
          "tue": 1,
          "tuesday": 1,
          "we": 2,
          "wed": 2,
          "wednesday": 2,
          "th": 3,
          "thu": 3,
          "thursday": 3,
          "fr": 4,
          "fri": 4,
          "friday": 4,
          "sa": 5,
          "sat": 5,
          "saturday": 5,
          "su": 6,
          "sun": 6,
          "sunday": 6,
        };

        for (var point in distancePoints) {
          int? dayIndex;
          if (point.weekday != null) {
            String cleanedWeekday = point.weekday!.toLowerCase();
            if (dayNameToIndex.containsKey(cleanedWeekday)) {
              dayIndex = dayNameToIndex[cleanedWeekday];
            } else if (cleanedWeekday.length >= 2) {
              String firstTwo = cleanedWeekday.substring(0, 2);
              if (dayNameToIndex.containsKey(firstTwo)) {
                dayIndex = dayNameToIndex[firstTwo];
              }
            }
          }

          if (dayIndex == null && point.date != null) {
            try {
              DateTime parsedDate = DateTime.parse(point.date!);
              dayIndex = parsedDate.weekday -
                  1; // DateTime.monday == 1 ... sunday == 7
            } catch (e) {
              // Ignore date parsing errors for label determination
            }
          }

          if (dayIndex != null && dayIndex >= 0 && dayIndex < 7) {
            resultData[dayIndex] = point.distance ?? 0.0;
          }
        }
        break;

      case ChartDataType.month:
        int weekCounter = 1; // Fallback counter
        for (var point in distancePoints) {
          resultData.add(point.distance ?? 0.0);
          String label;
          if (point.date != null && point.date!.length >= 10) {
            try {
              // Assuming date is in ISO8601 format or at least YYYY-MM-DD...
              // Extracts MM-DD from YYYY-MM-DD...
              String mm = point.date!.substring(5, 7);
              String dd = point.date!.substring(8, 10);
              label = "$mm-$dd";
            } catch (e) {
              // Fallback if date string is not as expected (e.g., too short, wrong format)
              label = "W$weekCounter";
            }
          } else {
            // Fallback if date is null or too short
            label = "W$weekCounter";
          }
          resultLabels.add(label);
          weekCounter++;
        }
        break;

      case ChartDataType.year:
        for (var point in distancePoints) {
          resultData.add(point.distance ?? 0.0);
          String label = '';
          if (point.date != null && point.date!.length >= 7) {
            try {
              DateTime parsedDate = DateTime.parse(point.date!);
              const monthNames = [
                "Jan",
                "Feb",
                "Mar",
                "Apr",
                "May",
                "Jun",
                "Jul",
                "Aug",
                "Sep",
                "Oct",
                "Nov",
                "Dec"
              ];
              label = monthNames[parsedDate.month - 1];
            } catch (e) {
              label = point.date!.substring(5, 7); // MM
            }
          } else if (point.weekday != null) {
            label = point.weekday!;
          } else {
            label = 'Month';
          }
          resultLabels.add(label);
        }
        break;
    }
    return (data: resultData, labels: resultLabels);
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _weekDistanceCubit),
        BlocProvider.value(value: _monthDistanceCubit),
        BlocProvider.value(value: _yearDistanceCubit),
      ],
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: ColorManager.navyColor,
            title: const Text("Distance"),
          ),
          body: BackgroundTheme(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04, vertical: h * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const TabBar(
                    padding: EdgeInsets.zero,
                    dividerColor: Colors.transparent,
                    labelColor: ColorManager.primaryColor,
                    unselectedLabelColor: ColorManager.darkGreyColor,
                    indicatorColor: ColorManager.primaryColor,
                    tabs: [
                      Tab(text: 'Week'),
                      Tab(text: 'Month'),
                      Tab(text: 'Year'),
                    ],
                  ),
                  SizedBox(height: h * 0.02),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        _buildChartTab<DistanceCubit>(ChartDataType.week, w, h),
                        _buildChartTab<DistanceCubit>(
                            ChartDataType.month, w, h),
                        _buildChartTab<DistanceCubit>(ChartDataType.year, w, h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartTab<T extends DistanceCubit>(
      ChartDataType type, double w, double h) {
    DistanceCubit cubit;
    switch (type) {
      case ChartDataType.week:
        cubit = _weekDistanceCubit;
        break;
      case ChartDataType.month:
        cubit = _monthDistanceCubit;
        break;
      case ChartDataType.year:
        cubit = _yearDistanceCubit;
        break;
    }

    return BlocBuilder<DistanceCubit, DistanceState>(
      bloc: cubit, // Ensure this uses the specific cubit instance
      builder: (context, state) {
        if (state is DistanceLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DistanceLoaded) {
          final chartData = _prepareChartData(state.distanceList, type);
          // For week, _prepareChartData always returns 7 labels & data points.
          // For month/year, if distancePoints is empty, chartData.labels will be empty.
          if (type != ChartDataType.week && chartData.labels.isEmpty) {
            return Center(
                child: Text("No data available.",
                    style: TextStyles.regular16White));
          }
          return _buildSmallBarChart(
            data: chartData.data,
            unit: "Km",
            labels: chartData.labels, // Will have 7 day labels for week type
            width: w,
            height: h * 0.28,
          );
        }
        if (type == ChartDataType.week) {
          return _buildSmallBarChart(
            data: List.filled(7, 0.0), // Empty bars
            unit: "Km",
            labels: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"], // Week labels
            width: w,
            height: h * 0.28,
          );
        } else {
          // Month or Year error
          return _buildSmallBarChart(
            data: [], // Empty bars
            unit: "Km",
            labels: [], // No labels
            width: w,
            height: h * 0.28,
          );
        }
      },
    );
  }

  Widget _buildSmallBarChart({
    required List<double> data,
    required String unit,
    required List<String> labels,
    required double width,
    required double height,
  }) {
    double maxValue;
    if (data.isEmpty) {
      maxValue = 10;
    } else {
      maxValue = data.reduce((a, b) => a > b ? a : b);
    }
    double step;
    if (maxValue <= 10) {
      step = 2;
      maxValue = 10;
    } else if (maxValue <= 50) {
      step = 10;
      maxValue = 50;
    } else if (maxValue <= 100) {
      step = 20;
      maxValue = 100;
    } else if (maxValue <= 250) {
      step = 50;
      maxValue = 250;
    } else if (maxValue <= 500) {
      step = 100;
      maxValue = 500;
    } else {
      step = 200;
      maxValue = ((maxValue / step).ceil() * step).toDouble();
    }

    List<double> yTicks = [];
    for (double i = step; i <= maxValue; i += step) {
      yTicks.add(i);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: height * 0.02),
          child: SizedBox(
            height: height,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(
                  data.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i],
                        width: 10,
                        color: ColorManager.primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (yTicks.contains(value)) {
                          return Text(value.toInt().toString(),
                              style: TextStyles.regular12LightGrey);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        if (labels.length > 10 && idx % 5 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(labels[idx],
                            style: TextStyles.regular12LightGrey);
                      },
                      reservedSize: 20,
                    ),
                  ),
                ),
                maxY: maxValue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
