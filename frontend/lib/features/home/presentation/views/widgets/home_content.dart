import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/routes.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/core/widget/appbar_stats.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_bloc.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_state.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_quests_list.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/daily_quest_card.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/quests_list.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundTheme(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            // Show loading only when HomeBloc is in loading state
            if (homeState is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocConsumer<UserCubit, UserState>(
              listener: (context, state) {
                if (state is UserError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.failure.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is UserLoaded) {
                  return _buildHomeContent(
                      context, state.user, screenWidth, screenHeight);
                }

                // If UserCubit is loading but HomeBloc is ready, show empty content
                // This prevents infinite loading
                if (homeState is HomeReady) {
                  return const Center(
                    child: Text(
                      "Loading user data...",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addQuest",
        backgroundColor: ColorManager.primaryColor,
        tooltip: "Add Custom Quest",
        onPressed: () {
          Navigator.pushNamed(context, Routes.addQuestScreen);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, UserModel user,
      double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.025),
            const AppBarStats(),
            SizedBox(height: screenHeight * 0.025),
            CustomRichText(
              text1: 'Welcome, ',
              textStyle1: TextStyles.styleExtraBold(context,
                  fontSize: 30, color: ColorManager.whiteColor),
              text2: user.username?.trim().split(' ').first ?? 'Player',
              textStyle2: TextStyles.styleExtraBold(context,
                  fontSize: 30, color: ColorManager.primaryColor),
            ),
            SizedBox(height: screenHeight * 0.025),
            const DailyQuestCard(),
            QuestsList(quests: getIt<UserCubit>().quests),
            LabelBox(
              labelText: "Your Quests",
              child: CustomQuestsList(quests: getIt<UserCubit>().customQuests),
            ),
          ],
        ),
      ),
    );
  }
}
