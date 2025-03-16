import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/utils/app_icons.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/core/widget/appbar_stats.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_quest_card.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_rich_text.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/quest_card.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../data/model/user_model.dart';
import '../manager/user_cubit.dart';
import '../manager/user_state.dart';

/// Callback for handling foreground task data.
/// Delegates distance updates and quest progress checking to the cubit.
void _onReceiveTaskData(Object data) {
  if (data is Map<String, dynamic> && _HomeState.currentState != null) {
    _HomeState.currentState!._handleTaskData(data);
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Static reference for callback access.
  static _HomeState? currentState;
  bool _distanceSent = false; // To ensure we only send once

  // Local map to manage loading states for custom quests.
  final Map<String, bool> questLoadingState = {};

  @override
  void initState() {
    super.initState();
    // Assign the current instance for callback use.
    currentState = this;

    getIt<UserCubit>().fetchUserData();
    // Register foreground task callback.
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  /// Sends the current total distance to the foreground service
  void _sendCurrentDistanceToService(double distance) async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      FlutterForegroundTask.sendDataToTask({
        'initialDistance': distance,
      });
      print("Sent initial distance to service: $distance");
    } else {
      print("Foreground service not running.");
    }
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    currentState = null;
    super.dispose();
  }

  /// Handles background task data by delegating to the cubit's update method.
  void _handleTaskData(Map<String, dynamic> data) {
    final totalDistance = data['totalDistance'] ?? 0.0;
    getIt<UserCubit>().updateDistanceAndCheckQuests(totalDistance);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundTheme(
        child: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }
            if (state is UserLoaded && !_distanceSent) {
              _distanceSent = true;
              // Delay a bit if necessary, or send immediately.
              _sendCurrentDistanceToService(state.totalDistance);
            }
          },
          builder: (context, state) {
            if (state is UserLoaded) {
              return _buildHomeContent(state.user, screenWidth, screenHeight);
            }
            // While waiting for a loaded state (hydrated or freshly fetched)
            return const Center(child: CircularProgressIndicator());
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

  Widget _buildHomeContent(
      UserModel user, double screenWidth, double screenHeight) {
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
            _buildDailyQuestCard(),
            _buildQuestsList(getIt<UserCubit>().quests),
            LabelBox(
              labelText: "Your Quests",
              child: _buildCustomQuestsList(getIt<UserCubit>().customQuests),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuestCard() {
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

  Widget _buildQuestsList(List<Quests>? quests) {
    if (quests == null || quests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Center(
          child: Text(
            "No quests available",
            style: TextStyles.styleSemiBold(context,
                fontSize: 20, color: ColorManager.whiteColor),
          ),
        ),
      );
    }

    final state = getIt<UserCubit>().state;
    final totalDistance = state is UserLoaded ? state.totalDistance : 0.0;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        double progress = quest.isCompleted == true
            ? 1.0
            : (quest.goal != null
                ? (totalDistance / quest.goal!).clamp(0.0, 1.0)
                : 0.0);

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: QuestCard(
            questName: quest.name ?? "Unnamed Quest",
            questDesc:
                "${quest.xpReward ?? 0} XP • ${quest.goldReward ?? 0} Gold",
            goal: quest.goal ?? 1000,
            questImageIcon: AppIcons.runningIcon,
            progress: progress,
          ),
        );
      },
    );
  }

  Widget _buildCustomQuestsList(List<Quests>? quests) {
    if (quests == null || quests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Center(
          child: Text(
            "No custom quests available",
            style: TextStyles.styleSemiBold(context,
                fontSize: 20, color: ColorManager.whiteColor),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        final questId = quest.sId ?? 'quest_$index';
        final isLoading = questLoadingState[questId] ?? false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: CustomQuestCard(
            questName: quest.name ?? "Unnamed Quest",
            questDesc:
                "${quest.xpReward ?? 0} XP • ${quest.goldReward ?? 0} Gold",
            questImageIcon: AppIcons.runningIcon,
            progress: quest.isCompleted ?? false,
            onCompleteQuest: () async {
              setState(() {
                questLoadingState[questId] = true;
              });
              await getIt<UserCubit>().completeQuest(quest);
              setState(() {
                questLoadingState[questId] = false;
              });
            },
            isLoading: isLoading,
          ),
        );
      },
    );
  }
}
