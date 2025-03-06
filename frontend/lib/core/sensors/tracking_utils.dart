import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geolocator/geolocator.dart' as geo;

class TrackingData {
  final double distance;
  final ActivityType? activityType;
  final DateTime timestamp;
  final bool isActive;

  TrackingData({
    required this.distance,
    this.activityType,
    required this.timestamp,
    this.isActive = false,
  });

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'activityType': activityType?.toString(),
        'timestamp': timestamp.toIso8601String(),
        'isActive': isActive,
      };

  factory TrackingData.fromJson(Map<String, dynamic> json) {
    ActivityType? activityType;
    if (json['activityType'] != null) {
      try {
        activityType = ActivityType.values.firstWhere(
          (e) => e.toString() == json['activityType'],
          orElse: () => ActivityType.UNKNOWN,
        );
      } catch (_) {
        activityType = ActivityType.UNKNOWN;
      }
    }

    return TrackingData(
      distance: json['distance'] ?? 0.0,
      activityType: activityType,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] ?? false,
    );
  }
}

class TrackingUtils {
  static double calculateDistance(
      geo.Position? lastPosition, geo.Position currentPosition) {
    if (lastPosition == null) return 0.0;

    // Only count distance if it's reasonable (avoid GPS jumps)
    final distance = geo.Geolocator.distanceBetween(
      lastPosition.latitude,
      lastPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );


    return distance;
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

  static bool isActivityTrackable(Activity activity) {
    return (activity.type == ActivityType.RUNNING ||
            activity.type == ActivityType.WALKING) &&
        activity.confidence == ActivityConfidence.HIGH;
  }

  static void handleActivityDetected(Activity activity,
      Function startLocationTracking, Function stopLocationTracking) {
    if (isActivityTrackable(activity)) {
      startLocationTracking();
    } else {
      stopLocationTracking();
    }
  }

  // Additional utility methods
  static bool shouldUpdateDistance(
      geo.Position? lastPosition, geo.Position currentPosition,
      {double minDistanceFilter = 3.0}) {
    if (lastPosition == null) return true;

    // Only update if moved more than the minimum distance
    final distance = geo.Geolocator.distanceBetween(
      lastPosition.latitude,
      lastPosition.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distance >= minDistanceFilter;
  }
}
