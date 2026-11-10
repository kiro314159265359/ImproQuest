import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_application_2/features/home/data/model/achievement_model.dart';
import 'package:flutter_application_2/features/home/data/model/distance_model.dart';
import 'package:image_picker/image_picker.dart';
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
      required String birthDate,
      XFile? profilePicture}) async {
    Map<String, dynamic> fields = {
      "username": username,
      "email": email,
      "height": height,
      "weight": weight,
      "gender": gender,
      "birth_date": birthDate,
    };

    FormData formData = FormData.fromMap(fields);

    if (profilePicture != null) {
      formData.files.add(MapEntry(
        "avatar",
        await MultipartFile.fromFile(profilePicture.path,
            filename: profilePicture.name),
      ));
    }

    await apiService.patch('/users/${user.sId}', body: formData);

    user.username = username;
    user.email = email;
    user.height = height;
    user.weight = weight;
    user.gender = gender;
    user.birthDate = birthDate;

    return user;
  }

  @override
  Future<void> completeQuest(String? qId) async {
    await apiService.patch('/quests/IsCompleted/$qId');
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
  Future<void> editQuest(String? qId, String questName, int questXp,
      int questGold, String questType) async {
    await apiService.put('/quests/mental-habit/$qId', body: {
      'name': questName,
      'xp_reward': questXp,
      'gold_reward': questGold,
      'type': questType,
    });
  }

  @override
  Future<void> deleteQuest(String? qId) async {
    await apiService.delete('/quests/mental-habit/$qId');
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
  Future<void> unequipItem(String? itemId, String? slot) async {
    await apiService.post(EndPoints.unequipItems, body: {
      'item_id': itemId,
      'slot': slot,
    });
  }

  @override
  Future<void> deleteAccount(UserModel user) async {
    await apiService.delete('/users/${user.sId}');
  }

  @override
  Future<InventoryModel> getUserItems() async {
    var response = await apiService.get(EndPoints.userItems);
    return InventoryModel.fromJson(jsonDecode(response.toString()));
  }

  @override
  Future<double> getDistanceToday(UserModel user) async {
    var response = await apiService.get("/runs/${user.sId}/distance/today");
    var data = jsonDecode(response.toString());
    if (data['totalDistance'] == null) {
      return 0.0;
    }
    return double.parse(data['totalDistance'].toString());
  }

  @override
  Future<List<DistanceModel>> getDistanceWeek(UserModel user) async {
    var response =
        await apiService.get("/runs/${user.sId}/distance/days-of-week");
    List<dynamic> list = response.data;
    return list
        .map((item) => DistanceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DistanceModel>> getDistanceMonth(UserModel user) async {
    var response =
        await apiService.get("/runs/${user.sId}/distance/weeks-of-month");
    List<dynamic> list = response.data;
    return list
        .map((item) => DistanceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DistanceModel>> getDistanceYear(UserModel user) async {
    var response =
        await apiService.get("/runs/${user.sId}/distance/months-of-year");
    List<dynamic> list = response.data;
    return list
        .map((item) => DistanceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AchievementModel>> getUnlockedAchievementModelList() async {
    var response = await apiService.get(EndPoints.achievementsUnlocked);
    List<dynamic> list = response.data;
    return list
        .map((item) => AchievementModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AchievementModel>> getlockedAchievementModelList() async {
    var response = await apiService.get(EndPoints.achievementsLocked);
    List<dynamic> list = response.data;
    return list
        .map((item) => AchievementModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> skillPoints(String? stats, int? points) async {
    await apiService.post('/users/stats/$stats/$points');
  }
}
