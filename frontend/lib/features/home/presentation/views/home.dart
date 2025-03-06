import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/sensors/activity_bloc.dart';
import 'package:flutter_application_2/core/sensors/activity_event.dart';
import 'package:flutter_application_2/core/sensors/activity_state.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/utils/app_icons.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/core/widget/appbar_stats.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_quest_card.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../data/model/user_model.dart';
import '../manager/user_cubit.dart';
import '../manager/user_state.dart';
import '../utils/quest_progress_manager.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ActivityBloc _activityBloc;
  bool _activityStarted = false;

  @override
  void initState() {
    super.initState();
    // Get ActivityBloc from GetIt
    _activityBloc = getIt<ActivityBloc>();

    // Start activity tracking
    _startActivityTracking();

    // Fetch user data
    context.read<UserCubit>().fetchUserData();
  }

  void _startActivityTracking() {
    // Only start tracking if not already tracking
    if (!_activityStarted && _activityBloc.state is! ActivityTracking) {
      _activityBloc.add(StartActivityTracking());
      _activityStarted = true;
    }
  }

  // We don't need to stop tracking when leaving the homepage
  // as it should continue in the background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundTheme(
        child: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is UserLoaded) {
              return _buildHomeContent(state.user);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(UserModel user) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.025),
            const AppBarStats(),
            SizedBox(height: h * 0.025),
            CustomRichText(
              text1: 'Welcome, ',
              textStyle1: TextStyles.styleExtraBold(context,
                  fontSize: 30, color: ColorManager.whiteColor),
              text2: user.username?.trim().split(' ').first ?? 'Player',
              textStyle2: TextStyles.styleExtraBold(context,
                  fontSize: 30, color: ColorManager.primaryColor),
            ),
            SizedBox(height: h * 0.025),
            SizedBox(
              height: 150,
              child: Card(
                color: ColorManager.gunmetal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("DAILY QUESTS",
                            style: TextStyles.styleBold(context,
                                fontSize: 24, color: ColorManager.whiteColor),
                            textAlign: TextAlign.center),
                        CustomRichText(
                          text1:
                              '${context.read<UserCubit>().completedQuestCount} Quest ',
                          textStyle1: TextStyles.styleSemiBold(context,
                              fontSize: 18, color: const Color(0xFFA4FF72)),
                          text2: 'completed',
                          textStyle2: TextStyles.styleSemiBold(context,
                              fontSize: 18, color: const Color(0xFFB7B7B9)),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: ColorManager.containerBackGround,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16))),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(
                              "${context.read<UserCubit>().remainingQuestCount} Quests left",
                              style: TextStyles.styleSemiBold(context,
                                  fontSize: 18, color: ColorManager.whiteColor),
                              textAlign: TextAlign.center),
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
                            size: 9, // Icon size
                          ),
                        ),
                        backgroundColor: ColorManager.containerBackGround,
                        radius: 60,
                        lineWidth: 10.0,
                        percent:
                            context.read<UserCubit>().questCompletionPercent,
                        center: Text(
                            "${(context.read<UserCubit>().questCompletionPercent * 100).toStringAsFixed(0)}%",
                            style: TextStyles.styleSemiBold(context,
                                fontSize: 20, color: ColorManager.whiteColor),
                            textAlign: TextAlign.center),
                        linearGradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: <Color>[
                              Color(0xFFA4FF72),
                              Color(0xFFA4FF72)
                            ]),
                        rotateLinearGradient: true,
                        circularStrokeCap: CircularStrokeCap.round)
                  ],
                ),
              ),
            ),
            _buildQuestsList(user.quests),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsList(List<Quests>? quests) {
    if (quests == null || quests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Center(
          child: Text("No quests available",
              style: TextStyles.styleSemiBold(context,
                  fontSize: 20, color: ColorManager.whiteColor)),
        ),
      );
    }

    return FutureBuilder<List<Quests>>(
      future: QuestProgressManager.updateQuestsProgress(quests),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final updatedQuests = snapshot.data ?? quests;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: updatedQuests.length,
          itemBuilder: (context, index) {
            final quest = updatedQuests[index];
            return FutureBuilder<double>(
              future: QuestProgressManager.calculateVisualProgress(quest),
              builder: (context, progressSnapshot) {
                final progress = progressSnapshot.data ?? 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Card(
                    color: ColorManager.gunmetal,
                    child: Column(
                      children: [
                        CustomQuestCard(
                            questName: quest.name ?? "Unnamed Quest",
                            questDesc:
                                "${quest.xpReward ?? 0} XP • ${quest.goldReward ?? 0} Gold",
                            goal: quest.goal ?? 1000,
                            questImageIcon: AppIcons.runningIcon,
                            progress: progress,
                            questId: quest.sId,
                            isCompleted: quest.isCompleted == true),
                        ElevatedButton(
                            onPressed: progress >= 1.0 ||
                                    quest.isCompleted == true
                                ? () async {
                                    await context
                                        .read<UserCubit>()
                                        .completeQuest(quest);
                                  }
                                : null, // Disable button if quest not completed
                            child: const Text("Complete Quest"))
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
