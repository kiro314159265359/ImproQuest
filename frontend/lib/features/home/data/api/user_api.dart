import 'dart:convert';
import 'package:flutter_application_2/features/home/data/model/inventory_model.dart';
import 'package:flutter_application_2/features/home/data/model/leaderboard_level_model.dart';
import 'package:flutter_application_2/features/home/data/model/leaderboard_streak_model.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/domain/repo/user_repo.dart';
import '../../../../core/service/api/api_service.dart';
import '../../../../core/service/api/end_points.dart';

class UserApi extends UserRepo {
  final ApiService apiService;
  UserApi(this.apiService);

  @override
  Future<UserModel> getUserData() async {
    await apiService.put(EndPoints.quests);
    var response = await apiService.get(EndPoints.userData);
    print(jsonDecode(response.toString()));
    return UserModel.fromJson(jsonDecode(response.toString()));
  }

  @override
  Future<UserModel> updateUserData(
      {required UserModel user,
      required String username,
      required String email,
      required int height,
      required int weight,
      required String gender,
      required String birthDate}) async {
    await apiService.patch('/users/${user.sId}', body: {
      "username": username,
      "email": email,
      "height": height,
      "weight": weight,
      "gender": gender,
      "birth_date": birthDate,
    });
    return user;
  }

  @override
  Future<void> completeQuest(String? qId) async {
    await apiService.patch('/quests/IsCompleted/$qId');
  }

  @override
  Future<void> completeStreak() async {
    await apiService.patch(EndPoints.streak);
  }

  @override
  Future<void> addCustomQuest(
      String questName, int questXp, int questGold, String questType) async {
    await apiService.post(EndPoints.customQuest, body: {
      'name': questName,
      'xp_reward': questXp,
      'gold_reward': questGold,
      'type': questType,
    });
  }

  @override
  Future<LeaderboardLevelListModel> getLeaderboardByLevelList() async {
    var response = await apiService.get(EndPoints.leaderboardByLevel);
    return LeaderboardLevelListModel.fromJson(jsonDecode(response.toString()));
  }

  @override
  Future<LeaderboardStreakListModel> getLeaderboardByStreakList() async {
    var response = await apiService.get(EndPoints.leaderboardByStreak);
    return LeaderboardStreakListModel.fromJson(jsonDecode(response.toString()));
  }

  @override
  Future<void> equipItem(String? itemId, String? slot) async {
    await apiService.post(EndPoints.equipItems, body: {
      'item_id': itemId,
      'slot': slot,
    });
  }

  @override
  Future<InventoryModel> getUserItems() async {
    var response = await apiService.get(EndPoints.userItems);
    return InventoryModel.fromJson(jsonDecode(response.toString()));
  }
}
