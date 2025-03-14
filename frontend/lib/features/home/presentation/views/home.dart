import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/utils/app_icons.dart';
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

// Handle data received from the foreground service
void _onReceiveTaskData(Object data) {
  print('onReceiveTaskData from HOME: $data');
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
  // Add static reference to current state for the callback
  static _HomeState? currentState;
  Map<String, bool> questLoadingState = {};

  // Add variables to store tracking data
  String _currentActivity = 'UNKNOWN';
  String _confidence = 'UNKNOWN';
  bool _isTracking = false;
  double _totalDistance = 0.0;
  DateTime _lastUpdated = DateTime.now();

  // Reference to the debug dialog if it's open
  StateSetter? _debugDialogSetState;

  @override
  void initState() {
    super.initState();
    currentState = this; // Store reference to current state
    context.read<UserCubit>().fetchUserData();

    // Register callback to handle data from foreground service
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  @override
  void dispose() {
    if (currentState == this) {
      currentState = null; // Clear reference when disposed
    }
    // Remove callback
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    _debugDialogSetState = null; // Clear dialog reference
    super.dispose();
  }

  // Handle data received from foreground service
  void _handleTaskData(Map<String, dynamic> data) {
    setState(() {
      _currentActivity = data['activity'] ?? 'UNKNOWN';
      _confidence = data['confidence'] ?? 'UNKNOWN';
      _isTracking = data['isTracking'] ?? false;
      _totalDistance = data['totalDistance'] ?? 0.0;
      _lastUpdated = DateTime.now();

      // Update quest progress for distance-based quests
      _updateQuestProgress();

      // Update the debug dialog if it's open
      if (_debugDialogSetState != null) {
        _debugDialogSetState!(() {});
      }
    });
  }

  // Update quest progress based on distance
  void _updateQuestProgress() {
    if (mounted && _isTracking) {
      final state = context.read<UserCubit>().state;
      if (state is UserLoaded) {
        final quests = state.user.quests;
        if (quests != null) {
          for (var quest in quests) {
            // Assume quests with goals over 100 are distance-based (in meters)
            // This is a simplification - in a real app, you'd have quest types
            if (quest.isCompleted != true &&
                quest.goal != null &&
                quest.goal! > 100) {
              if (_totalDistance >= quest.goal!) {
                // Auto-complete quest when distance goal is reached
                context.read<UserCubit>().completeQuest(quest);
              }
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          },
          builder: (context, state) {
            if (state is UserLoaded) {
              return _buildHomeContent(state.user);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.primaryColor,
        tooltip: "Add Custom Quest",
        onPressed: () {
          Navigator.pushNamed(context, Routes.addQuestScreen);
        },
        child: const Icon(Icons.add),
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
                              fontSize: 18, color: ColorManager.lightGreen),
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
                          size: 9,
                        ),
                      ),
                      backgroundColor: ColorManager.containerBackGround,
                      radius: 60,
                      lineWidth: 10.0,
                      percent: context
                          .read<UserCubit>()
                          .questCompletionPercent, // user quest progress
                      center: Text(
                          "${(context.read<UserCubit>().questCompletionPercent * 100).toStringAsFixed(0)}%",
                          style: TextStyles.styleSemiBold(context,
                              fontSize: 20, color: ColorManager.whiteColor),
                          textAlign: TextAlign.center),
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
            _buildQuestsList(context.read<UserCubit>().quests),
            LabelBox(
              labelText: "Your Quests",
              child: _buildCustomQuestsList(
                  context.read<UserCubit>().customQuests),
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
          child: Text("No quests available",
              style: TextStyles.styleSemiBold(context,
                  fontSize: 20, color: ColorManager.whiteColor)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        // Calculate progress based on distance for distance-based quests
        double progress = quest.isCompleted == true ? 1.0 : 0.0;

        // If this is a distance-based quest, calculate progress based on actual distance
        if (quest.isCompleted != true &&
            quest.goal != null &&
            quest.goal! > 100) {
          progress = _totalDistance / quest.goal!;
          // Cap progress at 1.0 (100%)
          if (progress > 1.0) progress = 1.0;
        }

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
          child: Text("No custom quests available",
              style: TextStyles.styleSemiBold(context,
                  fontSize: 20, color: ColorManager.whiteColor)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        bool isLoading = questLoadingState[quest.sId] ?? false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: CustomQuestCard(
            questName: quest.name ?? "Unnamed Quest",
            questDesc:
                "${quest.xpReward ?? 0} XP • ${quest.goldReward ?? 0} Gold",
            questImageIcon: AppIcons.runningIcon,
            progress: quest.isCompleted!,
            onCompleteQuest: () async {
              setState(() {
                questLoadingState[quest.sId!] = true;
              });

              await context.read<UserCubit>().completeQuest(quest);

              setState(() {
                questLoadingState[quest.sId!] = false;
              });
            },
            isLoading: isLoading,
          ),
        );
      },
    );
  }
}
