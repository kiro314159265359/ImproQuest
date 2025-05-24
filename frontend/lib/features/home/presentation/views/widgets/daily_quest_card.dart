import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../data/model/user_model.dart';
import '../../manager/user_state.dart';

class DailyQuestCard extends StatelessWidget {
  const DailyQuestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) =>
          current is UserLoaded ||
          current is UserUpdated ||
          current is UserLoading ||
          current is UserError,
      builder: (context, state) {
        if (state is UserLoaded) {
          return _buildDailyQuestCard(context, state.user, state);
        } else if (state is UserUpdated) {
          return _buildDailyQuestCard(context, state.user, state);
        } else if (state is UserLoading) {
          return _buildDailyQuestCard(context, state.user, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDailyQuestCard(
      BuildContext context, UserModel user, UserState state) {
    return Skeletonizer(
      enabled: state is UserLoading,
      enableSwitchAnimation: true,
      child: SizedBox(
        height: 150,
        child: Card(
          color: ColorManager.gunmetal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "DAILY QUESTS",
                    style: TextStyles.bold20White,
                    textAlign: TextAlign.center,
                  ),
                  CustomRichText(
                    text1:
                        '${context.read<UserCubit>().completedQuestCount} Quest ',
                    textStyle1: TextStyles.semiBold16lightGreen,
                    text2: 'completed',
                    textStyle2: TextStyles.semiBold16lightGrey,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: ColorManager.containerBackGround,
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "${context.read<UserCubit>().remainingQuestCount} Quests left",
                      style: TextStyles.semiBold16White,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              CircularPercentIndicator(
                animation: true,
                widgetIndicator: Transform.translate(
                  offset: const Offset(-5, 0),
                  child: const Icon(
                    Icons.circle,
                    color: ColorManager.blackColor,
                    size: 8,
                  ),
                ),
                backgroundColor: ColorManager.containerBackGround,
                radius: 60,
                lineWidth: 10.0,
                percent: context.read<UserCubit>().questCompletionPercent,
                center: Text(
                  "${(context.read<UserCubit>().questCompletionPercent * 100).toStringAsFixed(0)}%",
                  style: TextStyles.semiBold20White,
                  textAlign: TextAlign.center,
                ),
                linearGradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: <Color>[
                      ColorManager.lightGreen,
                      ColorManager.lightGreen
                    ]),
                rotateLinearGradient: true,
                circularStrokeCap: CircularStrokeCap.round,
              )
            ],
          ),
        ),
      ),
    );
  }
}
