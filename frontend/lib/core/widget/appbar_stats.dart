import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/app_images.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../features/home/data/model/user_model.dart';
import '../../features/home/presentation/manager/user_cubit.dart';
import '../../features/home/presentation/manager/user_state.dart';
import '../theme/color_manger.dart';
import '../theme/text_style.dart';
import '../utils/app_icons.dart';

class AppBarStats extends StatefulWidget {
  const AppBarStats({super.key});

  @override
  State<AppBarStats> createState() => _AppBarStatsState();
}

class _AppBarStatsState extends State<AppBarStats> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) =>
          current is UserLoaded ||
          current is UserUpdated ||
          current is UserLoading ||
          current is UserError,
      builder: (context, state) {
        final bool isLoading = state is UserLoading;

        if (state is UserLoaded || state is UserUpdated) {
          UserModel user =
              state is UserLoaded ? state.user : (state as UserUpdated).user;
          return _buildAppBarStats(context, user, isLoading);
        }

        if (state is UserLoading) {
          return _buildAppBarStats(context, state.user, isLoading);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppBarStats(
      BuildContext context, UserModel user, bool isLoading) {
    var w = MediaQuery.of(context).size.width;

    return Skeletonizer(
      enabled: isLoading,
      enableSwitchAnimation: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(38, 16, 0, 0),
                child: LinearPercentIndicator(
                  width: w * 0.32,
                  lineHeight: 25,
                  percent: (user.xp! / (user.level! * 100)),
                  center: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: CustomRichText(
                      text1: "${user.xp}/${(user.level! * 100)}",
                      textStyle1: TextStyles.medium12White,
                      text2: "XP",
                      textStyle2: TextStyles.medium8White,
                    ),
                  ),
                  barRadius: const Radius.circular(4),
                  backgroundColor: ColorManager.containerBackGround,
                  progressColor: ColorManager.lightBlue,
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: ColorManager.primaryColor,
                child: CircleAvatar(
                  backgroundColor: ColorManager.primaryColor,
                  radius: 24,
                  backgroundImage: user.avatarUrl == null
                      ? const AssetImage(AppImages.profilePhoto)
                      : NetworkImage(user.avatarUrl!),
                  child: Transform.translate(
                    offset: const Offset(0, 28),
                    child: Container(
                      decoration: BoxDecoration(
                          color: ColorManager.deepBlue,
                          border: Border.all(
                              color: ColorManager.containerBackGround),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16))),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      child: Text("${user.level}",
                          style: TextStyles.medium8White,
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
                margin: const EdgeInsets.fromLTRB(48, 16, 0, 0),
                width: w * 0.28,
                height: 24,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("${user.gold}",
                      style: TextStyles.medium12White,
                      textAlign: TextAlign.center),
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: ColorManager.gunmetal,
                child: Image.asset(AppIcons.coinsIcon,
                    width: 24, fit: BoxFit.contain),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
