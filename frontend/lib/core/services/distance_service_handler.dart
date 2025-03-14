// The callback function should always be a top-level or static function.
import 'dart:async';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart' as geo;

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

const geo.LocationSettings locationSettings = geo.LocationSettings(
  accuracy: geo.LocationAccuracy.best,
  distanceFilter: 4,
);

geo.Position? _lastPosition;
double _totalDistance = 0.0;
bool _isTracking = false;
Activity? _currentActivity;

class MyTaskHandler extends TaskHandler {
  StreamSubscription<Activity>? _activitySubscription;
  StreamSubscription<geo.Position>? _positionStream;

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _activitySubscription = FlutterActivityRecognition.instance.activityStream
        .handleError(_onError)
        .listen(_onActivity);

    _positionStream = geo.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onDistance);
  }

  void _onActivity(Activity activity) {
    _currentActivity = activity;
    if (activity.type == ActivityType.RUNNING ||
        activity.type == ActivityType.WALKING &&
            activity.confidence == ActivityConfidence.HIGH) {
      _isTracking = true;
      FlutterForegroundTask.updateService(
          notificationText: '${activity.toJson()}');
    } else {
      _isTracking = false;
      FlutterForegroundTask.updateService(
          notificationText: 'Not tracking activity ${activity.toJson()}');
      print("Not tracking activity: ${activity.toJson()}");
    }

    // Send complete data to main app
    _sendCompleteDataToMain();
  }

  void _onDistance(geo.Position? position) {
    if (position != null && _isTracking) {
      if (_lastPosition != null) {
        double segmentDistance = geo.Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude);
        _totalDistance += segmentDistance;
        print("Segment Distance: ${segmentDistance.toStringAsFixed(2)} meters");
        print("Total Distance: ${_totalDistance.toStringAsFixed(2)} meters");
        FlutterForegroundTask.updateService(
          notificationText:
              'Total distance tracked : $_totalDistance, Segment distance: $segmentDistance',
        );

        // Send complete data to main app
        _sendCompleteDataToMain();
      } else {
        print("Initial position acquired.");
      }
      _lastPosition = position;
    } else if (!_isTracking) {
      print("Not tracking distance for current activity.");
    } else {
      print("Unknown position");
    }
  }

  // New method to send all data in a consistent format
  void _sendCompleteDataToMain() {
    Map<String, dynamic> completeData = {
      'activity': _currentActivity?.type.name ?? 'UNKNOWN',
      'confidence': _currentActivity?.confidence.name ?? 'UNKNOWN',
      'isTracking': _isTracking,
      'totalDistance': _totalDistance,
    };
    print("Sending complete data to main: $completeData");
    FlutterForegroundTask.sendDataToMain(completeData);
  }

  void _onError(dynamic error) {
    print('error >> $error');
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {}

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _activitySubscription?.cancel();
    _activitySubscription = null;
    _positionStream?.cancel();
    _positionStream = null;
    _isTracking = false;
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}
