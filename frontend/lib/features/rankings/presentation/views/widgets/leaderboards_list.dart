import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/features/rankings/presentation/manager/leaderboard_cubit.dart';
import 'package:flutter_application_2/features/rankings/presentation/manager/leaderboard_state.dart';
import 'package:flutter_application_2/features/rankings/presentation/views/widgets/leaderboards_listtile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/theme/background_theme.dart';
import '../../../../../core/utils/get_it_constants.dart';
import '../../../../../core/widget/snackabars.dart';
import '../../../../home/data/model/leaderboard_level_model.dart';
import '../../../../home/data/model/leaderboard_streak_model.dart';
import '../../../../home/data/model/user_model.dart';

class LeaderboardsList extends StatefulWidget {
  final String leaderboardType;

  const LeaderboardsList({
    super.key,
    required this.leaderboardType,
  });

  @override
  State<LeaderboardsList> createState() => _LeaderboardsListState();
}

class _LeaderboardsListState extends State<LeaderboardsList> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      if (widget.leaderboardType == 'level') {
        context.read<LeaderboardCubit>().fetchLeaderboardLevelList();
      } else if (widget.leaderboardType == 'streak') {
        context.read<LeaderboardCubit>().fetchLeaderboardStreakList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundTheme(
        child: BlocConsumer<LeaderboardCubit, LeaderboardState>(
          buildWhen: (previous, current) {
            if (current is LeaderboardLoaded) {
              return current.type == widget.leaderboardType;
            }
            return true;
          },
          listener: (context, state) {
            if (state is LeaderboardError) {
              Snackbars.showErrorSnackbar(context, state.failure.message);
            }
          },
          builder: (context, state) {
            if (state is LeaderboardLoaded &&
                state.type == widget.leaderboardType) {
              return _buildList(state.leaderboard, state.type, state);
            }

            return _buildLoadingList();
          },
        ),
      ),
    );
  }

  Widget _buildList(dynamic leaderboard, String type, LeaderboardState state) {
    final bool isLoading = state is LeaderboardLoading;

    if (type == 'level' && leaderboard is LeaderboardLevelListModel) {
      return Skeletonizer(
        enabled: isLoading,
        enableSwitchAnimation: true,
        child: ListView.builder(
            itemCount: leaderboard.leaderboardList!.length,
            itemBuilder: (context, index) {
              final leaderboardItem = leaderboard.leaderboardList?[index];
              final bool isUser =
                  leaderboardItem?.sId == getIt<UserModel>().sId;

              return LeaderboardsListTile(
                playerImage: leaderboardItem?.avatarUrl,
                playerPlace: index,
                playerName: leaderboardItem?.username,
                playerPoints: leaderboardItem?.level ?? 0,
                isUser: isUser,
              );
            }),
      );
    } else if (type == 'streak' && leaderboard is LeaderboardStreakListModel) {
      return Skeletonizer(
        enabled: isLoading,
        enableSwitchAnimation: true,
        child: ListView.builder(
            itemCount: leaderboard.leaderboardList!.length,
            itemBuilder: (context, index) {
              final leaderboardItem = leaderboard.leaderboardList?[index];
              final bool isUser =
                  leaderboardItem?.sId == getIt<UserModel>().sId;

              return LeaderboardsListTile(
                playerImage: leaderboardItem?.avatarUrl,
                playerPlace: index,
                playerName: leaderboardItem?.username,
                playerPoints: leaderboardItem?.highestStreak ?? 0,
                isUser: isUser,
              );
            }),
      );
    }

    return const Center(
      child: Text(
        'Unexpected Error!',
        style: TextStyle(color: ColorManager.whiteColor),
      ),
    );
  }

  Widget _buildLoadingList() {
    return Skeletonizer(
      enabled: true,
      enableSwitchAnimation: true,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return const LeaderboardsListTile(
            playerImage: null,
            playerPlace: 0,
            playerName: "Loading...",
            playerPoints: 0,
            isUser: false,
          );
        },
      ),
    );
  }
}
