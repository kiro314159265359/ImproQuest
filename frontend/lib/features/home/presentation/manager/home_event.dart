// Events
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeInitialized extends HomeEvent {}

class DistanceDataReceived extends HomeEvent {
  final double distance;
  const DistanceDataReceived(this.distance);

  @override
  List<Object?> get props => [distance];
}

class CheckServiceDistance extends HomeEvent {}

class CompleteCustomQuest extends HomeEvent {
  final String questId;
  const CompleteCustomQuest(this.questId);

  @override
  List<Object?> get props => [questId];
}
