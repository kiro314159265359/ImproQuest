import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tracking_utils.dart';

class SharedDataUtil {
  static const String _trackingDataKey = 'tracking_data';
  static const String _lastPositionKey = 'last_position';
  static const String _dataVersionKey = 'data_version';
  static const int _currentVersion = 1;

  static Future<void> saveTrackingData(TrackingData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trackingDataKey, jsonEncode(data.toJson()));
    await prefs.setInt(_dataVersionKey, _currentVersion);
  }

  static Future<TrackingData?> getTrackingData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataVersion = prefs.getInt(_dataVersionKey) ?? 1;
    final dataString = prefs.getString(_trackingDataKey);

    if (dataString == null) return null;

    try {
      final dataMap = jsonDecode(dataString) as Map<String, dynamic>;
      return TrackingData.fromJson(dataMap);
    } catch (e) {
      // Handle data format changes between versions
      if (dataVersion < _currentVersion) {
        await clearTrackingData(); // Clear incompatible data
      }
      return null;
    }
  }

  static Future<void> saveLastPosition(
      double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final positionData = {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_lastPositionKey, jsonEncode(positionData));
  }

  static Future<Map<String, dynamic>?> getLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_lastPositionKey);
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
    await prefs.remove(_lastPositionKey);
  }
}
