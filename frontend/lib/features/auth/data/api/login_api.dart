import 'dart:convert';

import 'package:flutter_application_2/core/service/api/api_service.dart';
import 'package:flutter_application_2/core/service/api/end_points.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/service/cache_helper.dart';
import '../../../../core/utils/auth_helpers.dart';

class LoginApi extends LoginRepo {
  final ApiService apiService = ApiService();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {

    var response = await apiService.post(EndPoints.login, body: {
      'email': email,
      'password': password,
    });
    // Convert response to map string dynamic
    response = jsonDecode(response.toString());
    return response;
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    var response = await apiService.patch(EndPoints.refreshToken, body: {
      'refresh_token': refreshToken,
    });
    response = jsonDecode(response.toString());
    return response;
  }
}


