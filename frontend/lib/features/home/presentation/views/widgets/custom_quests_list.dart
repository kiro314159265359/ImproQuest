import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/utils/app_icons.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_bloc.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_event.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_state.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_quest_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomQuestsList extends StatelessWidget {
  final List<Quests>? quests;

  const CustomQuestsList({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    if (quests == null || quests!.isEmpty) {
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

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final loadingStates =
            state is HomeReady ? state.questLoadingStates : {};

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quests!.length,
          itemBuilder: (context, index) {
            final quest = quests![index];
            final questId = quest.sId ?? 'quest_$index';
            final isLoading = loadingStates[questId] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: CustomQuestCard(
                questName: quest.name ?? "Unnamed Quest",
                questDesc:
                    "${quest.xpReward ?? 0} XP • ${quest.goldReward ?? 0} Gold",
                questImageIcon: AppIcons.runningIcon,
                progress: quest.isCompleted ?? false,
                onCompleteQuest: () {
                  context.read<HomeBloc>().add(CompleteCustomQuest(questId));
                },
                isLoading: isLoading,
              ),
            );
          },
        );
      },
    );
  }
}
