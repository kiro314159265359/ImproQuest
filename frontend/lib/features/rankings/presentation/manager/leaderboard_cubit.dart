import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_2/features/rankings/presentation/manager/leaderboard_state.dart';
import '../../../../core/error/failure.dart';
import '../../../home/domain/repo/user_repo.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final UserRepo userRepo;
  LeaderboardCubit(this.userRepo) : super(LeaderboardInitial());

  Future<void> fetchLeaderboardLevelList() async {
    emit(LeaderboardLoading());
    try {
      final leaderboard = await userRepo.getLeaderboardByLevelList();

      emit(LeaderboardLoaded(leaderboard, 'level'));
    } catch (error) {
      if (error is DioException) {
        emit(LeaderboardError(ServerFailure.fromDioError(error)));
      } else {
        emit(LeaderboardError(ServerFailure(error.toString())));
      }
    }
  }

  Future<void> fetchLeaderboardStreakList() async {
    emit(LeaderboardLoading());
    try {
      final leaderboard = await userRepo.getLeaderboardByStreakList();

      emit(LeaderboardLoaded(leaderboard, 'streak'));
    } catch (error) {
      if (error is DioException) {
        emit(LeaderboardError(ServerFailure.fromDioError(error)));
      } else {
        emit(LeaderboardError(ServerFailure(error.toString())));
      }
    }
  }
}
