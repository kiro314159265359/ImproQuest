import '../../../../core/error/failure.dart';

class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final dynamic leaderboard;
  final String type;

  LeaderboardLoaded(this.leaderboard, this.type);
}

class LeaderboardError extends LeaderboardState {
  Failure failure;
  LeaderboardError(this.failure);
}
