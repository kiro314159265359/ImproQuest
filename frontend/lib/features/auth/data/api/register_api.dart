import 'package:flutter_application_2/features/auth/domain/repo/register_repo.dart';
import '../../../../core/service/api/api_service.dart';
import '../../../../core/service/api/end_points.dart';

class RegisterApi extends RegisterRepo {
  final ApiService apiService = ApiService();

  @override
  Future<void> register(String email, String password, String username,
      int height, int weight, String gender, String birthday) async {
    await apiService.post(EndPoints.register, body: {
      'email': email,
      'password': password,
      'username': username,
      'height': height,
      'weight': weight,
      'gender': gender,
      'UserType': "User",
      'birthdate': birthday,
    });
  }
}
