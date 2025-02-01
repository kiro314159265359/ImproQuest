import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<void> saveAccessToken(String accessToken) async {
  await storage.write(key: 'accessToken', value: accessToken);
}

Future<void> saveRefreshToken(String refreshToken) async {
  // Correct key for refresh token.
  await storage.write(key: 'refreshToken', value: refreshToken);
}

Future<String?> getAccessToken() async {
  return await storage.read(key: 'accessToken');
}

Future<String?> getRefreshToken() async {
  return await storage.read(key: 'refreshToken');
}

Future<void> clearTokens() async {
  await storage.deleteAll();
}

