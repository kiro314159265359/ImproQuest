import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/profile/presentation/manager/distance_cubit.dart';
import 'package:flutter_application_2/features/profile/presentation/manager/distance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../home/presentation/views/widgets/custom_rich_text.dart';

class Statistics extends StatefulWidget {
  final UserModel user;
  final double width;
  final double height;
  const Statistics({
    super.key,
    required this.user,
    required this.width,
    required this.height,
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
  void initState() {
    super.initState();
    context.read<DistanceCubit>().getDistanceToday();
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = weekStatus.keys.toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.height * 0.2,
            child: Card(
              color: ColorManager.gunmetal,
              child: Column(
                children: [
                  ListTile(
                    leading: Image.asset(AppIcons.flameIcon,
                        width: 25, fit: BoxFit.contain),
                    title: Text("${widget.user.streak?.current}",
                        style: TextStyles.bold20Primary),
                    subtitle:
                        Text("day streak", style: TextStyles.bold8Primary),
                  ),
                  SizedBox(
                    height: widget.height * 0.08,
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
          SizedBox(
            height: widget.height * 0.05,
          ),
          SizedBox(
            height: widget.height * 0.2,
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
                        Text("Distance", style: TextStyles.semiBold16White),
                        Text("Last 7 days",
                            style: TextStyles.semiBold12lightGrey)
                      ],
                    ),
                    BlocBuilder<DistanceCubit, DistanceState>(
                      builder: (context, state) {
                        if (state is DistanceLoading) {
                          return const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator()));
                        } else if (state is DistanceTodayLoaded) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomRichText(
                                text1: (state.distanceToday != null)
                                    ? state.distanceToday!.toStringAsFixed(2)
                                    : "0.00",
                                textStyle1: TextStyles.semiBold16Primary,
                                text2: "m",
                                textStyle2: TextStyles.semiBold12Primary,
                              ),
                              Text("Today",
                                  style: TextStyles.semiBold12Primary),
                            ],
                          );
                        } else if (state is DistanceError) {
                          return Text("Error",
                              style: TextStyles.semiBold12Primary);
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomRichText(
                              text1: "0.00",
                              textStyle1: TextStyles.semiBold16Primary,
                              text2: "m",
                              textStyle2: TextStyles.semiBold12Primary,
                            ),
                            Text("Today", style: TextStyles.semiBold12Primary),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 30),
                onTap: () {
                  Navigator.pushNamed(context, Routes.distanceScreen);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
