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
  static const int updateIntervalMillis = 5000;

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
        eventAction: ForegroundTaskEventAction.repeat(updateIntervalMillis),
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
  bool _isActive = false;
  DateTime _lastUpdateTime = DateTime.now();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      // Restore previous tracking data if any
      final savedData = await SharedDataUtil.getTrackingData();
      if (savedData != null) {
        _totalDistance = savedData.distance;
        _isActive = savedData.isActive;
      }

      // Restore last position if available
      final lastPositionData = await SharedDataUtil.getLastPosition();
      if (lastPositionData != null) {
        try {
          // Create a new Position instead of using copyWith
          _lastPosition = geo.Position(
            latitude: lastPositionData['latitude'],
            longitude: lastPositionData['longitude'],
            timestamp: DateTime.parse(lastPositionData['timestamp']),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
        } catch (e) {
          // Ignore position restoration errors
        }
      }

      _setupActivityRecognition();

      // Start location tracking if we were active before
      if (_isActive) {
        _startLocationTracking();
      }
    } catch (e) {
      _onError("Failed to start tracking: $e");
    }
  }

  void _setupActivityRecognition() {
    _activitySubscription =
        FlutterActivityRecognition.instance.activityStream.listen(
      (activity) {
        _currentActivity = activity;
        _isActive = TrackingUtils.isActivityTrackable(activity);

        if (_isActive) {
          _startLocationTracking();
        } else {
          _stopLocationTracking();
        }

        _updateNotification();
      },
      onError: (error) => _onError("Activity recognition error: $error"),
    );
  }

  Future<void> sendUpdateToMainApp(DateTime timestamp) async {
    final trackingData = TrackingData(
      distance: _totalDistance,
      activityType: _currentActivity?.type,
      timestamp: timestamp,
      isActive: _isActive,
    );

    // Save data to shared preferences for recovery
    await SharedDataUtil.saveTrackingData(trackingData);

    // Save last known position
    if (_lastPosition != null) {
      await SharedDataUtil.saveLastPosition(
          _lastPosition!.latitude, _lastPosition!.longitude);
    }

    // Save data for the main app to access
    await FlutterForegroundTask.saveData(
        key: 'tracking_data', value: trackingData.toJson());

    _updateNotification();
    _lastUpdateTime = timestamp;
  }

  void _updateNotification() {
    final activityStr =
        _currentActivity?.type.toString().split('.').last ?? 'Unknown';
    final statusStr = _isActive ? "Active" : "Inactive";

    FlutterForegroundTask.updateService(
      notificationTitle: 'Activity Tracking: $statusStr',
      notificationText:
          "Distance: ${_totalDistance.toStringAsFixed(2)}m | Activity: $activityStr",
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _activitySubscription?.cancel();
    _positionSubscription?.cancel();

    // Save final state before destruction
    final trackingData = TrackingData(
      distance: _totalDistance,
      activityType: _currentActivity?.type,
      timestamp: timestamp,
      isActive: false,
    );
    await SharedDataUtil.saveTrackingData(trackingData);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Check if we need to request a fresh activity
    final timeSinceLastUpdate = timestamp.difference(_lastUpdateTime);
    if (timeSinceLastUpdate.inSeconds > 30) {
      FlutterActivityRecognition.instance.activityStream.first.then((activity) {
        _currentActivity = activity;
        _isActive = TrackingUtils.isActivityTrackable(activity);

        if (_isActive && _positionSubscription == null) {
          _startLocationTracking();
        } else if (!_isActive && _positionSubscription != null) {
          _stopLocationTracking();
        }

        sendUpdateToMainApp(timestamp);
      }).catchError((e) {
        _onError("Activity error: $e");
      });
    } else {
      sendUpdateToMainApp(timestamp);
    }
  }

  void _onError(String error) {
    FlutterForegroundTask.updateService(
      notificationTitle: "Tracking Error",
      notificationText: error,
    );
  }

  void _startLocationTracking() async {
    if (_positionSubscription != null) return; // Avoid multiple subscriptions

    try {
      // Check if location service is enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _onError("Location services are disabled");
        return;
      }

      // Check permissions - needed for reliable tracking
      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          _onError("Location permission denied");
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        _onError("Location permission permanently denied");
        return;
      }

      _positionSubscription = geo.Geolocator.getPositionStream(
        locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.high, distanceFilter: 5),
      ).listen(
        (position) => _onLocationUpdated(position),
        onError: (error) => _onError("Location error: $error"),
        onDone: () => _onError("Location stream closed unexpectedly"),
        cancelOnError: false,
      );

      // Update notification to show tracking is active
      _updateNotification();
    } catch (e) {
      _onError("Failed to start location tracking: $e");
    }
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _onLocationUpdated(geo.Position position) {
    try {
      // Add distance only if it's a valid distance
      final additionalDistance =
          TrackingUtils.calculateDistance(_lastPosition, position);

      if (additionalDistance > 0) {
        _totalDistance += additionalDistance;
        _lastPosition = position;

        // Update notification with new distance
        _updateNotification();
      }
    } catch (e) {
      _onError("Error processing location update: $e");
    }
  }
}
