import 'package:flutter_application_2/features/home/data/model/inventory_model.dart';
import 'package:flutter_application_2/features/home/data/model/leaderboard_streak_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/model/achievement_model.dart';
import '../../data/model/distance_model.dart';
import '../../data/model/leaderboard_level_model.dart';
import '../../data/model/user_model.dart';

abstract class UserRepo {
  Future<UserModel> getUserData();
  Future<UserModel> updateUserData(
      {required UserModel user,
      required String username,
      required String email,
      required int height,
      required int weight,
      required String gender,
      required String birthDate,
      XFile? profilePicture});
  Future<void> completeQuest(String? qId);
  Future<void> editQuest(String? qId, String questName, int questXp,
      int questGold, String questType);
  Future<void> deleteQuest(String? qId);
  Future<void> completeStreak();
  Future<void> addCustomQuest(
      String questName, int questXp, int questGold, String questType);
  Future<List<AchievementModel>> getUnlockedAchievementModelList();
  Future<List<AchievementModel>> getlockedAchievementModelList();
  Future<LeaderboardStreakListModel> getLeaderboardByStreakList();
  Future<LeaderboardLevelListModel> getLeaderboardByLevelList();
  Future<double> getDistanceToday(UserModel user);
  Future<List<DistanceModel>> getDistanceWeek(UserModel user);
  Future<List<DistanceModel>> getDistanceMonth(UserModel user);
  Future<List<DistanceModel>> getDistanceYear(UserModel user);
  Future<InventoryModel> getUserItems();
  Future<void> equipItem(String? itemId, String? slot);
  Future<void> unequipItem(String? itemId, String? slot);
  Future<void> deleteAccount(UserModel user);
}
