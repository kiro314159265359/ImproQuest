import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'shared_data_util.dart';

/// A class that bridges data communication between foreground service
/// and the main application using both direct communication and shared preferences.
class ForegroundBackgroundBridge {
  /// Period for synchronizing data from shared preferences.
  static const Duration syncPeriod = Duration(seconds: 2);

  /// Callback executed when data is received.
  final Function(Map<String, dynamic>) onDataReceived;

  Timer? _syncTimer;
  Map<String, dynamic>? _lastData;

  ForegroundBackgroundBridge({required this.onDataReceived});

  /// Start listening for data from the foreground service.
  void startListening() {
    // First, try to get immediate data
    _checkForServiceData();

    // Then set up periodic checking
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncPeriod, (_) async {
      await _checkSharedPreferences();
    });
  }

  /// Stop listening for data.
  void stopListening() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Check for data sent by the foreground service.
  Future<void> _checkForServiceData() async {
    try {
      final data = await FlutterForegroundTask.getData<Map<String, dynamic>?>(
          key: 'tracking_data');
      if (data != null) {
        _processData(data);
      } else {
        // If no data from service, fall back to shared preferences
        await _checkSharedPreferences();
      }
    } catch (e) {
      // On error, fall back to shared preferences
      await _checkSharedPreferences();
    }
  }

  /// Check for data stored in shared preferences.
  Future<void> _checkSharedPreferences() async {
    final data = await SharedDataUtil.getTrackingData();
    if (data != null) {
      _processData(data);
    }
  }

  /// Process received data and notify listeners if data has changed.
  void _processData(Map<String, dynamic> data) {
    // Only notify if data has changed
    if (_lastData == null ||
        _lastData!['totalDistance'] != data['distance'] ||
        _lastData!['activityType'] != data['activityType']) {
      final processedData = {
        'totalDistance': data['distance'] ?? 0.0,
        'activityType': data['activityType'] ?? 'unknown',
        'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      };

      _lastData = processedData;
      onDataReceived(processedData);
    }
  }
}
