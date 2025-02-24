import 'dart:async';
import 'dart:isolate';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'tracking_utils.dart';

class ForegroundService {
  static void start() {
    FlutterForegroundTask.startService(
      notificationTitle: 'Activity Tracking',
      notificationText: 'Tracking your activity in the background',
      callback: startCallback,
    );
  }

  static void stop() {
    FlutterForegroundTask.stopService();
  }

  static void startCallback() {
    FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
    FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
  }
}

class ForegroundTaskHandler extends TaskHandler {
  StreamSubscription<Activity>? _activitySubscription;
  StreamSubscription<geo.Position>? _positionSubscription;
  geo.Position? _lastPosition;
  double _totalDistance = 0.0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _activitySubscription =
        FlutterActivityRecognition.instance.activityStream.listen(
      (activity) => TrackingUtils.handleActivityDetected(
          activity, _startLocationTracking, _stopLocationTracking),
      onError: (error) => _onActivityError(error.toString()),
    );

    // Start location tracking immediately in case the user is already active
    _startLocationTracking();
  }

  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _activitySubscription?.cancel();
    _positionSubscription?.cancel();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Get latest activity and location in regular intervals
    FlutterActivityRecognition.instance.activityStream.first.then((activity) {
      TrackingUtils.handleActivityDetected(
          activity, _startLocationTracking, _stopLocationTracking);
    });

    if (_positionSubscription == null) {
      _startLocationTracking(); // Ensure location tracking continues
    }
  }

  void _onActivityError(String error) {
    print("Activity Error: $error");
  }

  void _startLocationTracking() {
    if (_positionSubscription != null) return; // Avoid multiple subscriptions

    _positionSubscription = geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high, distanceFilter: 5),
    ).listen(
      (position) => _onLocationUpdated(position),
      onError: (error) => _onActivityError(error.toString()),
    );
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _onLocationUpdated(geo.Position position) {
    _totalDistance += TrackingUtils.calculateDistance(_lastPosition, position);
    _lastPosition = position;
    print("Total Distance: $_totalDistance meters");

    // Send updated distance to the app (if needed)
    FlutterForegroundTask.updateService(
        notificationText:
            "Total Distance: ${_totalDistance.toStringAsFixed(2)} m");
  }

  void _initService() {
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
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }
}
