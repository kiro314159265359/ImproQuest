import '../../features/auth/domain/repo/login_repo.dart';
import '../routes/routes.dart';
import '../service/cache_helper.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

Future<bool> hasValidAccessToken(String? accessToken) async {
  return accessToken != null && !JwtDecoder.isExpired(accessToken);
}

Future<String> _handleInvalidAccessToken(
    LoginRepo loginRepo, String? accessToken) async {
  if (accessToken == null) {
    return Routes.loginScreen;
  }

  return await _handleExpiredAccessToken(loginRepo);
}

Future<String> _handleExpiredAccessToken(LoginRepo loginRepo) async {
  final refreshToken = await getRefreshToken();

  if (refreshToken == null) {
    await clearTokens();
    return Routes.loginScreen;
  }

  return await _attemptTokenRefresh(loginRepo, refreshToken);
}

Future<String> _attemptTokenRefresh(
    LoginRepo loginRepo, String refreshToken) async {
  try {
    final response = await loginRepo.refreshToken(refreshToken);
    await _saveNewTokens(response);
    return Routes.appLayoutScreen;
  } catch (error) {
    await clearTokens();
    return Routes.loginScreen;
  }
}

Future<void> _saveNewTokens(Map<String, dynamic> response) async {
  final newAccessToken = response['user']['access_token'];
  final newRefreshToken = response['user']['refresh_token'];
  await saveAccessToken(newAccessToken);
  await saveRefreshToken(newRefreshToken);
}

Future<String> determineInitialRoute(LoginRepo loginRepo) async {
  final accessToken = await getAccessToken();
  if (await hasValidAccessToken(accessToken)) {
    return Routes.appLayoutScreen;
  }
  return await _handleInvalidAccessToken(loginRepo, accessToken);
}
