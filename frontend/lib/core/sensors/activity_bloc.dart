import 'dart:async';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'foreground_service.dart';
import 'tracking_utils.dart';
import 'activity_event.dart';
import 'activity_state.dart';
import 'shared_data_util.dart';
import 'foreground_background_bridge.dart';
import '../utils/quest_progress_manager.dart';
import '../../features/home/data/model/user_model.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  StreamSubscription<Activity>? _activitySubscription;
  StreamSubscription<geo.Position>? _positionSubscription;
  geo.Position? _lastPosition;
  double _totalDistance = 0.0;
  ForegroundBackgroundBridge? _bridge;

  ActivityBloc() : super(ActivityInitial()) {
    on<StartActivityTracking>(_onStartTracking);
    on<StopActivityTracking>(_onStopTracking);
    on<ActivityDetected>(_onActivityDetected);
    on<LocationUpdated>(_onLocationUpdated);
    on<ActivityError>(_onActivityError);
    on<BackgroundDataReceived>(_onBackgroundDataReceived);

    // If foreground task is still running when app restarts, restore the state
    _checkForegroundTaskRunning();
  }

  Future<void> _checkForegroundTaskRunning() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      // Restore data from previous session
      final savedData = await SharedDataUtil.getTrackingData();
      if (savedData != null) {
        _totalDistance = savedData['distance'] ?? 0.0;

        // Re-attach to foreground service
        add(StartActivityTracking());
      }
    }
  }

  Future<void> _onStartTracking(
    StartActivityTracking event,
    Emitter<ActivityState> emit,
  ) async {
    try {
      await _requestPermissions();

      // Check if location services are enabled
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const ActivityFailure(
            'Location services are disabled. Please enable them to continue.'));
        return;
      }

      // Check battery optimization settings
      final isBatteryOptimizationDisabled =
          await ForegroundService.checkBatteryOptimization();
      if (!isBatteryOptimizationDisabled) {
        await ForegroundService.requestDisableBatteryOptimization();
      }

      // Set up communication channel with background service
      _bridge = ForegroundBackgroundBridge(
        onDataReceived: (data) => add(BackgroundDataReceived(data)),
      );
      _bridge!.startListening();

      // Get initial data if any
      final data = await FlutterForegroundTask.getData<Map<String, dynamic>?>(
        key: 'tracking_data',
      );
      if (data != null) {
        add(BackgroundDataReceived(data));
      }

      _activitySubscription =
          FlutterActivityRecognition.instance.activityStream.listen(
        (activity) => add(ActivityDetected(activity)),
        onError: (error) => add(ActivityError(error.toString())),
      );

      ForegroundService.start();

      emit(ActivityTracking(timestamp: DateTime.now()));
    } catch (error) {
      emit(ActivityFailure(error.toString()));
    }
  }

  Future<void> _onBackgroundDataReceived(
    BackgroundDataReceived event,
    Emitter<ActivityState> emit,
  ) async {
    if (state is ActivityTracking) {
      final currentState = state as ActivityTracking;
      final distance = event.data['totalDistance'] as double? ?? _totalDistance;
      _totalDistance = distance;

      emit(currentState.copyWith(
        distance: distance,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> _onStopTracking(
    StopActivityTracking event,
    Emitter<ActivityState> emit,
  ) async {
    // Clean up resources
    _activitySubscription?.cancel();
    _activitySubscription = null;

    _stopLocationTracking();

    // Stop bridge listening
    _bridge?.stopListening();
    _bridge = null;

    // Save the final tracking data before stopping
    if (_totalDistance > 0) {
      await SharedDataUtil.saveTrackingData(
        distance: _totalDistance,
        activityType: (state is ActivityTracking &&
                (state as ActivityTracking).activity != null)
            ? (state as ActivityTracking).activity!.type.toString()
            : 'unknown',
        timestamp: DateTime.now(),
      );
    }

    ForegroundService.stop();

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

    // Also request background location for accurate tracking
    if (await Permission.locationAlways.isDenied) {
      final status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        // Replace print with a more appropriate logging approach
        _logError(
            'Background location permission denied. Tracking may be less accurate.');
      }
    }
  }

  void _logError(String message) {
    // Replace this with a proper logging framework if needed
    // For now, just add it as an error event
    add(ActivityError(message));
  }

  // Add method to update quest progress
  Future<void> updateQuestProgress(List<Quests>? quests, double newDistance) async {
    if (quests == null || quests.isEmpty) return;
    
    // Update progress for each active quest
    for (final quest in quests) {
      if (quest.sId != null && quest.isCompleted != true) {
        await QuestProgressManager.updateQuestProgress(quest.sId!, newDistance);
      }
    }
  }

  @override
  Future<void> close() {
    _activitySubscription?.cancel();
    _positionSubscription?.cancel();
    _bridge?.stopListening();
    ForegroundService.stop();
    return super.close();
  }
}
