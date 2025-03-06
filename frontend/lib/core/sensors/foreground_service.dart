import 'dart:async';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'tracking_utils.dart';
import 'shared_data_util.dart';

@pragma('vm:entry-point') // Ensure this is not removed during tree shaking
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundService {
  static void start() {
    _initService();
    FlutterForegroundTask.startService(
      notificationTitle: 'Activity Tracking',
      notificationText: 'Tracking your activity in the background',
      callback: startCallback,
    );
  }

  static void stop() {
    FlutterForegroundTask.stopService();
  }

  static void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
        // Use correct repeat interval (every 5 seconds)
        eventAction: ForegroundTaskEventAction.repeat(5000),
      ),
    );
  }

  static Future<bool> checkBatteryOptimization() async {
    return FlutterForegroundTask.isIgnoringBatteryOptimizations;
  }

  static Future<void> requestDisableBatteryOptimization() async {
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }
}

class ForegroundTaskHandler extends TaskHandler {
  StreamSubscription<Activity>? _activitySubscription;
  StreamSubscription<geo.Position>? _positionSubscription;
  geo.Position? _lastPosition;
  double _totalDistance = 0.0;
  Activity? _currentActivity;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      // Restore previous tracking data if any
      final savedData = await SharedDataUtil.getTrackingData();
      if (savedData != null) {
        _totalDistance = savedData['distance'] ?? 0.0;
      }

      _activitySubscription =
          FlutterActivityRecognition.instance.activityStream.listen(
        (activity) => TrackingUtils.handleActivityDetected(
            activity, _startLocationTracking, _stopLocationTracking),
        onError: (error) => _onActivityError(error.toString()),
      );

      // Start location tracking immediately in case the user is already active
      _startLocationTracking();
    } catch (e) {
      _onActivityError("Failed to start tracking: $e");
    }
  }

  Future<void> sendUpdateToMainApp(DateTime timestamp) async {
    // Save data to shared preferences for recovery and communication
    await SharedDataUtil.saveTrackingData(
      distance: _totalDistance,
      activityType: _currentActivity?.type.toString() ?? 'unknown',
      timestamp: timestamp,
    );

    // Save data for the main app to access
    final trackingData = {
      'totalDistance': _totalDistance,
      'activityType': _currentActivity?.type.toString() ?? 'unknown',
      'timestamp': timestamp.toIso8601String(),
    };
    await FlutterForegroundTask.saveData(key: 'tracking_data', value: trackingData);

    // Update notification
    FlutterForegroundTask.updateService(
      notificationTitle: 'Activity Tracking',
      notificationText: "Distance: ${_totalDistance.toStringAsFixed(2)} m",
      callback: () {
        // This callback is executed when the notification is tapped
      },
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _activitySubscription?.cancel();
    _positionSubscription?.cancel();

    // Save final state before destruction
    await SharedDataUtil.saveTrackingData(
      distance: _totalDistance,
      activityType: _currentActivity?.type.toString() ?? 'unknown',
      timestamp: timestamp,
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Get latest activity and location in regular intervals
    FlutterActivityRecognition.instance.activityStream.first.then((activity) {
      _currentActivity = activity;
      TrackingUtils.handleActivityDetected(
          activity, _startLocationTracking, _stopLocationTracking);

      // Send updated data to main app
      sendUpdateToMainApp(timestamp);
    }).catchError((e) {
      _onActivityError("Activity error: $e");
    });

    if (_positionSubscription == null) {
      _startLocationTracking(); // Ensure location tracking continues
    }
  }

  void _onActivityError(String error) {
    // Update the notification with error info
    FlutterForegroundTask.updateService(
      notificationText: "Error: $error",
    );
  }

  void _startLocationTracking() async {
    if (_positionSubscription != null) return; // Avoid multiple subscriptions

    try {
      // Check if location service is enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _onActivityError("Location services are disabled");
        return;
      }

      _positionSubscription = geo.Geolocator.getPositionStream(
        locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.high, distanceFilter: 5),
      ).listen(
        (position) => _onLocationUpdated(position),
        onError: (error) => _onActivityError(error.toString()),
      );
    } catch (e) {
      _onActivityError("Failed to start location tracking: $e");
    }
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _onLocationUpdated(geo.Position position) {
    _totalDistance += TrackingUtils.calculateDistance(_lastPosition, position);
    _lastPosition = position;

    FlutterForegroundTask.updateService(
        notificationText:
            "Total Distance: ${_totalDistance.toStringAsFixed(2)} m");
  }
}
