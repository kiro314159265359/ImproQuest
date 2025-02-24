import 'package:equatable/equatable.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityTracking extends ActivityState {
  final Activity? activity;
  final double distance;
  final DateTime timestamp;

  const ActivityTracking({
    this.activity,
    this.distance = 0.0,
    required this.timestamp,
  });

  ActivityTracking copyWith({
    Activity? activity,
    double? distance,
    DateTime? timestamp,
  }) {
    return ActivityTracking(
      activity: activity ?? this.activity,
      distance: distance ?? this.distance,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [activity, distance, timestamp];
}

class ActivityFailure extends ActivityState {
  final String error;

  const ActivityFailure(this.error);

  @override
  List<Object?> get props => [error];
}