import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/utils/app_icons.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_bloc.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_event.dart';
import 'package:flutter_application_2/features/home/presentation/manager/home_state.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_cubit.dart';
import 'package:flutter_application_2/features/home/presentation/manager/user_state.dart';
import 'package:flutter_application_2/features/home/presentation/views/widgets/custom_quest_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/widget/dialogs.dart';

class CustomQuestsList extends StatelessWidget {
  final List<Quests>? quests;

  const CustomQuestsList({super.key, required this.quests});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          current is HomeReady ||
          current is HomeLoading ||
          (previous is HomeReady &&
              current is HomeReady &&
              previous.questLoadingStates != current.questLoadingStates),
      builder: (context, state) {
        final loadingStates =
            state is HomeReady ? state.questLoadingStates : {};

        if (quests == null || quests!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Center(
              child: Text(
                "No custom quests available",
                style: TextStyles.semiBold20White,
              ),
            ),
          );
        }

        return Skeletonizer(
          enabled: context.read<UserCubit>().state is UserLoading,
          enableSwitchAnimation: true,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quests!.length,
            itemBuilder: (context, index) {
              final quest = quests![index];
              final questId = quest.sId ?? 'quest_$index';
              final isLoading = loadingStates[questId] ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: CustomQuestCard(
                  quest: quest,
                  questImageIcon: AppIcons.timeIcon,
                  onCompleteQuest: () {
                    context.read<HomeBloc>().add(CompleteCustomQuest(questId));
                  },
                  onDeleteQuest: () {
                    Dialogs.confirmDialog(
                        context: context,
                        title: 'Delete Quest',
                        content:
                            'Are you sure you want to delete this quest? This action cannot be undone.',
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<UserCubit>().deleteQuest(quest);
                        });
                  },
                  isLoading: isLoading,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
