import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/features/rankings/presentation/manager/leaderboard_cubit.dart';
import 'package:flutter_application_2/features/rankings/presentation/manager/leaderboard_state.dart';
import 'package:flutter_application_2/features/rankings/presentation/views/widgets/leaderboards_listtile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/background_theme.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/get_it_constants.dart';
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is LeaderboardLoaded &&
                state.type == widget.leaderboardType) {
              return _buildList(state.leaderboard, state.type);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildList(dynamic leaderboard, String type) {
    if (type == 'level' && leaderboard is LeaderboardLevelListModel) {
      return ListView.builder(
          itemCount: leaderboard.leaderboardList!.length,
          itemBuilder: (context, index) {
            final leaderboardItem = leaderboard.leaderboardList?[index];
            final bool isUser = leaderboardItem?.sId == getIt<UserModel>().sId;

            return LeaderboardsListTile(
              playerImage: AppImages.profilePhoto,
              playerPlace: index,
              playerName: leaderboardItem?.username,
              playerPoints: leaderboardItem?.level ?? 0,
              isUser: isUser,
            );
          });
    } else if (type == 'streak' && leaderboard is LeaderboardStreakListModel) {
      return ListView.builder(
          itemCount: leaderboard.leaderboardList!.length,
          itemBuilder: (context, index) {
            final leaderboardItem = leaderboard.leaderboardList?[index];
            final bool isUser = leaderboardItem?.sId == getIt<UserModel>().sId;

            return LeaderboardsListTile(
              playerImage: AppImages.profilePhoto,
              playerPlace: index,
              playerName: leaderboardItem?.username,
              playerPoints: leaderboardItem?.highestStreak ?? 0,
              isUser: isUser,
            );
          });
    }

    return const Center(
      child: Text(
        'Unexpected Error!',
        style: TextStyle(color: ColorManager.whiteColor),
      ),
    );
  }
}
