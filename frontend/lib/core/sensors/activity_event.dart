import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

abstract class ActivityEvent {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class StartActivityTracking extends ActivityEvent {}

class StopActivityTracking extends ActivityEvent {}

class ActivityDetected extends ActivityEvent {
  final Activity activity;

  const ActivityDetected(this.activity);

  @override
  List<Object?> get props => [activity];
}

class LocationUpdated extends ActivityEvent {
  final double latitude;
  final double longitude;

  const LocationUpdated(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class ActivityError extends ActivityEvent {
  final String error;

  const ActivityError(this.error);

  @override
  List<Object?> get props => [error];
}
