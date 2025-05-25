import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<void> saveAccessToken(String accessToken) async {
  await storage.write(key: 'accessToken', value: accessToken);
}

Future<void> saveRefreshToken(String refreshToken) async {
  await storage.write(key: 'refreshToken', value: refreshToken);
}

Future<String?> getAccessToken() async {
  return await storage.read(key: 'accessToken');
}

Future<String?> getRefreshToken() async {
  return await storage.read(key: 'refreshToken');
}

Future<void> notFirstTime() async {
  await storage.write(key: 'isFirstTime', value: 'false');
}

Future<bool> isFirstTime() async {
  final value = await storage.read(key: 'isFirstTime');
  return value == null;
}

Future<void> clearTokens() async {
  await storage.deleteAll();
}
