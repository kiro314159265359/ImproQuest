import 'dart:convert';
import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/domain/repo/user_repo.dart';
import '../../../../core/service/api/api_service.dart';
import '../../../../core/service/api/end_points.dart';
import '../../../../core/utils/get_it_constants.dart';

class UserApi extends UserRepo {
  // Retrieve the same ApiService instance registered in main.dart
  final ApiService apiService = getIt<ApiService>();

  @override
  Future<UserModel> getUserData() async {
    var response = await apiService.get(EndPoints.userData);

    return UserModel.fromJson(jsonDecode(response.toString()));
  }

  @override
  Future<UserModel> updateUserData(UserModel user) async {
    await apiService.patch('/users/${user.sId}', body: user.toJson());
    return user;
  }
}
