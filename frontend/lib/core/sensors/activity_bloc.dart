import 'dart:async';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

import 'foreground_service.dart';
import 'tracking_utils.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  StreamSubscription<Activity>? _activitySubscription;
  StreamSubscription<geo.Position>? _positionSubscription;
  geo.Position? _lastPosition;
  double _totalDistance = 0.0;
  Timer? _saveDataTimer;

  ActivityBloc() : super(ActivityInitial()) {
    on<StartActivityTracking>(_onStartTracking);
    on<StopActivityTracking>(_onStopTracking);
    on<ActivityDetected>(_onActivityDetected);
    on<LocationUpdated>(_onLocationUpdated);
    on<ActivityError>(_onActivityError);

    _loadSavedDistance();

    // Create a timer to save distance data periodically
    _saveDataTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _saveTotalDistance();
    });
  }

  Future<void> _loadSavedDistance() async {
    _totalDistance = await TrackingUtils.getTotalDistance();
    if (state is ActivityTracking) {
      final currentState = state as ActivityTracking;
      emit(currentState.copyWith(distance: _totalDistance));
    }
  }

  Future<void> _saveTotalDistance() async {
    await TrackingUtils.saveTotalDistance(_totalDistance);
  }

  Future<void> _onStartTracking(
    StartActivityTracking event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _requestPermissions();

      // Load saved distance before starting
      _totalDistance = await TrackingUtils.getTotalDistance();

      _activitySubscription =
          FlutterActivityRecognition.instance.activityStream.listen(
        (activity) => add(ActivityDetected(activity)),
        onError: (error) => add(ActivityError(error.toString())),
      );

      ForegroundService.start();

      emit(ActivityTracking(
        timestamp: DateTime.now(),
        distance: _totalDistance,
      ));
    } catch (error) {
      emit(ActivityFailure(error.toString()));
    }
  }

  Future<void> _onStopTracking(
    StopActivityTracking event,
    Emitter<ActivityState> emit,
  ) async {
    _activitySubscription?.cancel();
    _stopLocationTracking();
    await _saveTotalDistance();
    emit(ActivityInitial());
  }

  Future<void> _onActivityDetected(
    ActivityDetected event,
    Emitter<ActivityState> emit,
  ) async {
    if (state is ActivityTracking) {
      final currentState = state as ActivityTracking;

      TrackingUtils.handleActivityDetected(
          event.activity, _startLocationTracking, _stopLocationTracking);

      emit(currentState.copyWith(
        activity: event.activity,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<ActivityState> emit,
  ) {
    if (state is ActivityTracking) {
      final currentState = state as ActivityTracking;

      _totalDistance += TrackingUtils.calculateDistance(_lastPosition,
          TrackingUtils.createPosition(event.latitude, event.longitude));
      _lastPosition =
          TrackingUtils.createPosition(event.latitude, event.longitude);

      // Save distance in SharedPreferences
      _saveTotalDistance();

      emit(currentState.copyWith(
        distance: _totalDistance,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _onActivityError(
    ActivityError event,
    Emitter<ActivityState> emit,
  ) {
    emit(ActivityFailure(event.error));
  }

  void _startLocationTracking() {
    _positionSubscription = geo.Geolocator.getPositionStream().listen(
      (position) => add(LocationUpdated(position.latitude, position.longitude)),
      onError: (error) => add(ActivityError(error.toString())),
    );
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    ForegroundService.stop();
  }

  Future<void> _requestPermissions() async {
    final activityPermission =
        await FlutterActivityRecognition.instance.checkPermission();

    if (activityPermission == ActivityPermission.DENIED) {
      final newPermission =
          await FlutterActivityRecognition.instance.requestPermission();
      if (newPermission != ActivityPermission.GRANTED) {
        throw Exception('Activity recognition permission denied');
      }
    }

    if (await Permission.locationWhenInUse.isDenied) {
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        throw Exception('Location permission denied');
      }
    }
  }

  @override
  Future<void> close() {
    _saveDataTimer?.cancel();
    _activitySubscription?.cancel();
    _positionSubscription?.cancel();
    _saveTotalDistance(); // Save before closing
    ForegroundService.stop();
    return super.close();
  }

  // Method to get current accumulated distance
  double getCurrentDistance() {
    return _totalDistance;
  }

  // Method to update quest progress based on current distance
  Future<void> updateQuestProgress(List<String> questIds) async {
    for (String questId in questIds) {
      await TrackingUtils.updateQuestProgress(questId, _totalDistance);
    }
  }
}
