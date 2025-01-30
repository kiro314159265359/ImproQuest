import 'package:flutter_application_2/core/service/api/api_service.dart';
import 'package:flutter_application_2/core/service/api/end_points.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';

class LoginApi extends LoginRepo {
  final ApiService apiService = ApiService();

  @override
  Future<void> login(String email, String password) async {
    var response = await apiService.post(EndPoints.loginToken, body: {
      'email': email,
      'password': password,
    });
    print(response.data);
  }
}
