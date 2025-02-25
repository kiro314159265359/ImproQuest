import '../../data/model/user_model.dart';

abstract class UserRepo {
  Future<UserModel> getUserData();
  Future<UserModel> updateUserData(UserModel user);
  Future<void> completeQuest(String? qId);
  Future<void> completeStreak();
}
