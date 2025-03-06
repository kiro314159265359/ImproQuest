import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedDataUtil {
  static const String _trackingDataKey = 'tracking_data';

  static Future<void> saveTrackingData({
    required double distance,
    required String activityType,
    required DateTime timestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final trackingData = {
      'distance': distance,
      'activityType': activityType,
      'timestamp': timestamp.toIso8601String(),
    };
    await prefs.setString(_trackingDataKey, jsonEncode(trackingData));
  }

  static Future<Map<String, dynamic>?> getTrackingData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_trackingDataKey);
    if (data == null) return null;

    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearTrackingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_trackingDataKey);
  }
}
