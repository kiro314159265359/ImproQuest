import 'package:flutter_application_2/features/home/data/model/user_model.dart';
import 'package:flutter_application_2/features/home/domain/repo/user_repo.dart';

import '../../../../core/service/api/api_service.dart';
import '../../../../core/service/api/end_points.dart';

class UserApi extends UserRepo {
  final ApiService apiService = ApiService();

  @override
  Future<UserModel> getUserData() async {
    var response = await apiService.get(EndPoints.userData);
    print(response);

    return UserModel.fromJson(response);

  }
}
