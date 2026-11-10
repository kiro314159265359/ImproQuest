import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/profile/presentation/views/widgets/achievements_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/widget/snackabars.dart';
import '../../../home/data/model/achievement_model.dart';
import '../manager/achievement_cubit.dart';
import '../manager/achievement_state.dart';

class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  @override
  void initState() {
    super.initState();
    context.read<AchievementCubit>().getAchievementsList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            labelStyle: TextStyles.bold12White,
            dividerColor: Colors.transparent,
            labelColor: ColorManager.primaryColor,
            unselectedLabelColor: ColorManager.darkGreyColor,
            indicatorColor: ColorManager.primaryColor,
            tabs: const [
              Tab(
                text: 'Unlocked',
                icon: Icon(Icons.lock_open),
              ),
              Tab(
                text: 'Locked',
                icon: Icon(Icons.lock_outline),
              ),
            ],
          ),
          Expanded(
            child: BlocConsumer<AchievementCubit, AchievementState>(
              listener: (context, state) {
                if (state is AchievementError) {
                  Snackbars.showErrorSnackbar(context, state.failure.message);
                }
              },
              builder: (context, state) {
                if (state is AchievementsLoaded) {
                  return TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      AchievementsList(
                        isLoading: false,
                        isLocked: false,
                        achievementsList: state.unlockedAchievementsList,
                      ),
                      AchievementsList(
                        isLoading: false,
                        isLocked: true,
                        achievementsList: state.lockedAchievementsList,
                      ),
                    ],
                  );
                }
                final dummyAchievements = List.generate(
                  10,
                  (index) => AchievementModel(
                    name: 'Achievement',
                    description: 'Description',
                  ),
                );
                return TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    AchievementsList(
                      isLoading: true,
                      isLocked: false,
                      achievementsList: dummyAchievements,
                    ),
                    AchievementsList(
                      isLoading: true,
                      isLocked: true,
                      achievementsList: dummyAchievements,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
