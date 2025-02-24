import 'dart:async';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

import '../services/foreground_service.dart';
import '../utils/tracking_utils.dart';
import 'activity_event.dart';
import 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  StreamSubscription<Activity>? _activitySubscription;
  StreamSubscription<geo.Position>? _positionSubscription;
  geo.Position? _lastPosition;
  double _totalDistance = 0.0;
  

  ActivityBloc() : super(ActivityInitial()) {
    on<StartActivityTracking>(_onStartTracking);
    on<ActivityDetected>(_onActivityDetected);
    on<LocationUpdated>(_onLocationUpdated);
    on<ActivityError>(_onActivityError);
  }

  Future<void> _onStartTracking(
    StartActivityTracking event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _requestPermissions();
      
      _activitySubscription = FlutterActivityRecognition.instance.activityStream
          .listen(
            (activity) => add(ActivityDetected(activity)),
            onError: (error) => add(ActivityError(error.toString())),
          );

      ForegroundService.start();

      emit(ActivityTracking(timestamp: DateTime.now()));
    } catch (error) {
      emit(ActivityFailure(error.toString()));
    }
  }

  Future<void> _onActivityDetected(
    ActivityDetected event,
    Emitter<ActivityState> emit,
  ) async {
    if (state is ActivityTracking) {
      final currentState = state as ActivityTracking;
      
      TrackingUtils.handleActivityDetected(event.activity, _startLocationTracking, _stopLocationTracking);

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
      
      _totalDistance += TrackingUtils.calculateDistance(_lastPosition, TrackingUtils.createPosition(event.latitude, event.longitude));
      _lastPosition = TrackingUtils.createPosition(event.latitude, event.longitude);

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
    _activitySubscription?.cancel();
    _positionSubscription?.cancel();
    ForegroundService.stop();
    return super.close();
  }
}