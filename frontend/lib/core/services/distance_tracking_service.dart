import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'service_manager.dart';

class DistanceTrackingService {
  // Singleton instance
  static final DistanceTrackingService _instance =
      DistanceTrackingService._internal();
  factory DistanceTrackingService() => _instance;
  DistanceTrackingService._internal();

  // Callback for data updates
  Function(Map<String, dynamic>)? onDataReceived;

  void initialize() {
    FlutterForegroundTask.addTaskDataCallback(_handleTaskData);
  }

  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_handleTaskData);
    onDataReceived = null;
  }

  void _handleTaskData(Object data) {
    if (data is Map<String, dynamic> && onDataReceived != null) {
      print("Service received data: $data");
      onDataReceived!(data);
    }
  }

  Future<void> sendDistanceToService(double distance) async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      FlutterForegroundTask.sendDataToTask({
        'initialDistance': distance,
      });
      print("Sent initial distance to service: $distance");
    } else {
      print("Foreground service not running.");
    }
  }

  Future<double> getDistanceFromService() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      try {
        final serviceDistance =
            await FlutterForegroundTask.getData(key: 'totalDistance');
        if (serviceDistance != null) {
          double distance = 0.0;
          if (serviceDistance is double) {
            distance = serviceDistance;
          } else if (serviceDistance is int) {
            distance = serviceDistance.toDouble();
          } else if (serviceDistance is String) {
            distance = double.tryParse(serviceDistance) ?? 0.0;
          }
          print("Retrieved service distance: $distance meters");
          return distance;
        }
      } catch (e) {
        print("Error retrieving service distance: $e");
      }
    }
    return 0.0;
  }

  Future<void> startServiceIfNeeded(dynamic state) async {
    return startForegroundServiceIfNeeded(state);
  }
}
