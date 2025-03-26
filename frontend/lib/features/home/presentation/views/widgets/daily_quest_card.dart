import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DailyQuestCard extends StatelessWidget {
  const DailyQuestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  style: TextStyles.styleBold(context,
                      fontSize: 24, color: ColorManager.whiteColor),
                  textAlign: TextAlign.center,
                ),
                CustomRichText(
                  text1: '${getIt<UserCubit>().completedQuestCount} Quest ',
                  textStyle1: TextStyles.styleSemiBold(context,
                      fontSize: 18, color: ColorManager.lightGreen),
                  text2: 'completed',
                  textStyle2: TextStyles.styleSemiBold(context,
                      fontSize: 18, color: const Color(0xFFB7B7B9)),
                ),
                Container(
                  decoration: const BoxDecoration(
                      color: ColorManager.containerBackGround,
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    "${getIt<UserCubit>().remainingQuestCount} Quests left",
                    style: TextStyles.styleSemiBold(context,
                        fontSize: 18, color: ColorManager.whiteColor),
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
                  color: Colors.black,
                  size: 9,
                ),
              ),
              backgroundColor: ColorManager.containerBackGround,
              radius: 60,
              lineWidth: 10.0,
              percent: getIt<UserCubit>().questCompletionPercent,
              center: Text(
                "${(getIt<UserCubit>().questCompletionPercent * 100).toStringAsFixed(0)}%",
                style: TextStyles.styleSemiBold(context,
                    fontSize: 20, color: ColorManager.whiteColor),
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
    );
  }
}
