import 'dart:convert';
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
    return UserModel.fromJson(jsonDecode(response.toString()));
  }

  @override
  Future<UserModel> updateUserData(UserModel user) async {
    await apiService.patch('/users/${user.sId}', body: user.toJson());
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
  

}
