import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/utils/app_icons.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/quest_card.dart';

class QuestsList extends StatelessWidget {
  final List<Quests>? quests;

  const QuestsList({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    if (quests == null || quests!.isEmpty) {
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
      itemCount: quests!.length,
      itemBuilder: (context, index) {
        final quest = quests![index];
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
}
