import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geolocator/geolocator.dart' as geo;

class TrackingUtils {
  static double calculateDistance(geo.Position? lastPosition, geo.Position currentPosition) {
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

  static void handleActivityDetected(Activity activity, Function startLocationTracking, Function stopLocationTracking) {
    if ((activity.type == ActivityType.RUNNING || activity.type == ActivityType.WALKING) &&
        activity.confidence == ActivityConfidence.HIGH) {
      startLocationTracking();
    } else {
      stopLocationTracking();
    }
  }
}
