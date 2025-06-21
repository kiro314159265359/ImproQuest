import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/routes.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/widget/appbar_stats.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_quests_list.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/daily_quest_card.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/quests_list.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/widget/snackabars.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<UserCubit, UserState>(
      buildWhen: (previous, current) =>
          current is UserLoaded ||
          current is UserUpdated ||
          current is UserLoading ||
          current is UserError ||
          current is UserInitial,
      listener: (context, state) {
        if (state is UserError) {
          Snackbars.showErrorSnackbar(context, state.failure.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: BackgroundTheme(
            child: Builder(builder: (context) {
              if (state is UserLoaded) {
                return _buildHomeContent(
                    context, state.user, screenWidth, screenHeight);
              } else if (state is UserUpdated) {
                return _buildHomeContent(
                    context, state.user, screenWidth, screenHeight);
              } else if (state is UserLoading) {
                // Show loading skeleton UI that matches the home structure
                return _buildHomeContent(
                    context, state.user, screenWidth, screenHeight);
              } else if (state is UserInitial || state is UserError) {
                // Show a simple loading indicator for initial state
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return const Center(child: CircularProgressIndicator());
            }),
          ),
          floatingActionButton: (state is UserLoaded || state is UserUpdated)
              ? FloatingActionButton.small(
                  heroTag: "addQuest",
                  backgroundColor: ColorManager.primaryColor,
                  tooltip: "Add Custom Quest",
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.addQuestScreen);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, UserModel user,
      double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
        child: Skeletonizer(
          enabled: context.read<UserCubit>().state is UserLoading ||
              context.read<UserCubit>().state is UserUpdating,
          enableSwitchAnimation: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.024),
              const AppBarStats(),
              SizedBox(height: screenHeight * 0.024),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: CustomRichText(
                  text1: 'Welcome, ',
                  textStyle1: TextStyles.bold24White,
                  text2: user.username?.trim().split(' ').first ?? 'Player',
                  textStyle2: TextStyles.bold24Primary,
                ),
              ),
              SizedBox(height: screenHeight * 0.024),
              const DailyQuestCard(),
              LabelBox(
                  labelText: "Daily Quest",
                  child: QuestsList(quests: context.read<UserCubit>().quests)),
              LabelBox(
                labelText: "My Quests",
                child: CustomQuestsList(
                    quests: context.read<UserCubit>().customQuests),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
