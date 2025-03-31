import 'package:flutter_application_2/features/home/data/model/leaderboard_streak_model.dart';
import '../../data/model/leaderboard_level_model.dart';
import '../../data/model/user_model.dart';

abstract class UserRepo {
  Future<UserModel> getUserData();
  Future<UserModel> updateUserData(UserModel user);
  Future<void> completeQuest(String? qId);
  Future<void> completeStreak();
  Future<void> addCustomQuest(
      String questName, int questXp, int questGold, String questType);
  Future<LeaderboardStreakListModel> getLeaderboardByStreakList();
  Future<LeaderboardLevelListModel> getLeaderboardByLevelList();
}
