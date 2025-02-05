import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/app_images.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../features/home/data/model/user_model.dart';
import '../../features/home/presentation/manager/user_cubit.dart';
import '../../features/home/presentation/manager/user_state.dart';
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
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          return _buildAppBatStats(state.user);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppBatStats(UserModel user) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(46, 17, 0, 0),
              child: LinearPercentIndicator(
                width: w * 0.3,
                lineHeight: 25,
                percent: (user.xp! / 240),
                center: CustomRichText(
                  text1: "${user.xp}/240",
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
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    child: Text("${user.level}",
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
              width: w * 0.3,
              height: 25,
              child: Text("${user.gold}",
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
