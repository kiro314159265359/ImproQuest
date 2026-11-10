import 'dart:convert';

import 'package:flutter_application_2/core/service/api/api_service.dart';
import 'package:flutter_application_2/core/service/api/end_points.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';

class LoginApi extends LoginRepo {
  final ApiService apiService;

  LoginApi(this.apiService);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    var response = await apiService.post(EndPoints.login, body: {
      'email': email,
      'password': password,
    });
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

  @override
  Future<void> forgetPassword(String email) async {
    await apiService.post(EndPoints.forgetPassword, body: {
      'email': email,
    });
  }

  @override
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    var response = await apiService.post(EndPoints.verifyOTP, body: {
      'email': email,
      'otp': otp,
    });
    response = jsonDecode(response.toString());
    return response;
  }

  @override
  Future<void> resetPassword(String newPassword, String resetToken) async {
    await apiService.post(EndPoints.resetPassword, body: {
      'new_password': newPassword,
    }, headers: {
      "Authorization": "Bearer $resetToken",
    });
  }
}
