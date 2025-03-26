import 'package:dio/dio.dart';
import 'package:flutter_application_2/core/service/cache_helper.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart'; // changed import

class TokenInterceptor extends Interceptor {
  final Dio dio;
  final LoginRepo loginRepo;

  TokenInterceptor({required this.dio, required this.loginRepo});

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Debug: log that onRequest is triggered.

    // Retrieve access token from your storage.
    String? accessToken = await getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {}
    handler.next(options);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if status is 401
    if (err.response?.statusCode == 401) {
      // Inspect error response to confirm token expiry
      final responseData = err.response?.data;
      final isTokenExpired = responseData != null &&
          responseData['message'] != null &&
          responseData['message'] == 'TOKEN_EXPIRED';

      if (isTokenExpired) {
        RequestOptions options = err.requestOptions;
        final refreshToken = await getRefreshToken();
        if (refreshToken != null) {
          try {
            final tokenResponse = await loginRepo.refreshToken(refreshToken);
            final newAccessToken = tokenResponse['access_token'];
            final newRefreshToken = tokenResponse['refresh_token'];
            if (newAccessToken != null && newRefreshToken != null) {
              await saveAccessToken(newAccessToken);
              await saveRefreshToken(newRefreshToken);
              options.headers["Authorization"] = "Bearer $newAccessToken";
              final cloneReq = await dio.request(
                options.path,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
                data: options.data,
                queryParameters: options.queryParameters,
              );
              return handler.resolve(cloneReq);
            }
          } catch (e) {
            // Optionally handle refresh failure (e.g., force logout)
          }
        }
      }
    }
    // If not token expiry or refresh fails, propagate error
    return handler.next(err);
  }
}
