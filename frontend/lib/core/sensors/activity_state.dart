import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:equatable/equatable.dart';
import '../../features/home/data/model/user_model.dart';

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
  // Add quests field
  final List<Quests>? quests;

  const ActivityTracking({
    this.activity,
    this.distance = 0.0,
    required this.timestamp,
    this.quests,
  });

  ActivityTracking copyWith({
    Activity? activity,
    double? distance,
    DateTime? timestamp,
    List<Quests>? quests,
  }) {
    return ActivityTracking(
      activity: activity ?? this.activity,
      distance: distance ?? this.distance,
      timestamp: timestamp ?? this.timestamp,
      quests: quests ?? this.quests,
    );
  }

  @override
  List<Object?> get props => [activity, distance, timestamp, quests];
}

class ActivityFailure extends ActivityState {
  final String error;

  const ActivityFailure(this.error);

  @override
  List<Object> get props => [error];
}
