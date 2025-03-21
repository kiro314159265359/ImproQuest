// States
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeReady extends HomeState {
  final Map<String, bool> questLoadingStates;

  const HomeReady({this.questLoadingStates = const {}});

  HomeReady copyWith({Map<String, bool>? questLoadingStates}) {
    return HomeReady(
      questLoadingStates: questLoadingStates ?? this.questLoadingStates,
    );
  }

  @override
  List<Object?> get props => [questLoadingStates];
}
