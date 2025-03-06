import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';

class TrackingUtils {
  // Constants for SharedPreferences keys
  static const String KEY_TOTAL_DISTANCE = "total_distance";
  static const String KEY_QUEST_PROGRESS_PREFIX = "quest_progress_";
  static const String KEY_LAST_SYNC_TIME = "last_sync_time";

  static double calculateDistance(
      geo.Position? lastPosition, geo.Position currentPosition) {
    if (lastPosition == null) return 0.0;

    return geo.Geolocator.distanceBetween(
      lastPosition.latitude,
      lastPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );
  }

  static geo.Position createPosition(double latitude, double longitude) {
    return geo.Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }

  static Future<void> saveTotalDistance(double distance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(KEY_TOTAL_DISTANCE, distance);
    await prefs.setString(KEY_LAST_SYNC_TIME, DateTime.now().toIso8601String());
  }

  static Future<double> getTotalDistance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(KEY_TOTAL_DISTANCE) ?? 0.0;
  }

  static Future<void> updateQuestProgress(
      String questId, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$KEY_QUEST_PROGRESS_PREFIX$questId', progress);
  }

  static Future<double> getQuestProgress(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$KEY_QUEST_PROGRESS_PREFIX$questId') ?? 0.0;
  }

  static Future<void> resetQuestProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(KEY_QUEST_PROGRESS_PREFIX)) {
        await prefs.remove(key);
      }
    }
  }

  static void handleActivityDetected(Activity activity,
      Function startLocationTracking, Function stopLocationTracking) {
    if ((activity.type == ActivityType.RUNNING ||
            activity.type == ActivityType.WALKING) &&
        activity.confidence == ActivityConfidence.HIGH) {
      startLocationTracking();
    } else {
      stopLocationTracking();
    }
  }
}
