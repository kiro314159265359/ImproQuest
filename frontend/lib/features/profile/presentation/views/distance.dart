import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/home/data/model/distance_model.dart';
import 'package:flutter_application_2/features/profile/presentation/manager/distance_cubit.dart';
import 'package:flutter_application_2/features/profile/presentation/manager/distance_state.dart';
import '../../../../core/theme/background_theme.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';

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
    _weekDistanceCubit = context.read<DistanceCubit>()..getDistanceWeek();
    _monthDistanceCubit = context.read<DistanceCubit>()..getDistanceMonth();
    _yearDistanceCubit = context.read<DistanceCubit>()..getDistanceYear();
  }

  ({List<double> data, List<String> labels}) _prepareChartData(
      List<DistanceModel> distancePoints, ChartDataType type) {
    List<double> data = [];
    List<String> labels = [];

    if (distancePoints.isEmpty) {
      return (data: [], labels: []);
    }

    for (var point in distancePoints) {
      data.add(point.distance ?? 0.0);
      String label = '';
      switch (type) {
        case ChartDataType.week:
          label = point.weekday?.substring(0, 2) ?? // "Mo", "Tu"
              (point.date != null && point.date!.length >= 5
                  ? point.date!.substring(5, 10) // MM-DD
                  : 'Day');
          break;
        case ChartDataType.month: // Assuming API returns data per week
          label = (point.date != null && point.date!.length >= 10
                  ? point.date!.substring(5, 10) // Start date of week as MM-DD
                  : 'Week') +
              (point.weekday != null
                  ? " (${point.weekday})"
                  : ""); // Optional: if weekday has week number
          break;
        case ChartDataType.year: // Assuming API returns data per month
          if (point.date != null && point.date!.length >= 7) {
            // Try to get month name or number
            try {
              DateTime parsedDate = DateTime.parse(point.date!);
              // Basic month name mapping, can be improved with intl package
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
            // if weekday field contains month name
            label = point.weekday!;
          } else {
            label = 'Month';
          }
          break;
      }
      labels.add(label);
    }
    return (data: data, labels: labels);
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
      bloc: cubit,
      builder: (context, state) {
        if (state is DistanceLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DistanceLoaded) {
          final chartData = _prepareChartData(state.distanceList!, type);
          if (chartData.data.isEmpty) {
            return Center(
                child: Text("No data available.",
                    style: TextStyles.regular16White));
          }
          return _buildSmallBarChart(
            data: chartData.data,
            unit: "Km",
            labels: chartData.labels,
            width: w,
            height: h * 0.28,
          );
        } else if (state is DistanceError) {
          return Center(
              child: Text("Error: ${state.failure.message}",
                  style: TextStyles.regular16White));
        }
        return const Center(child: Text("Select a tab"));
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
