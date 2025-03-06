import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Singleton instance
  static final PermissionService _instance = PermissionService._internal();
  
  factory PermissionService() => _instance;
  
  PermissionService._internal();
  
  /// Request initial permissions at app startup (without context)
  Future<void> requestInitialPermissions() async {
    await _requestActivityRecognition();
    await _requestLocationPermissionWithoutDialog();
  }
  
  /// Request all necessary permissions for the app with UI feedback
  Future<void> requestAllPermissions(BuildContext context) async {
    await _requestActivityRecognition();
    await _requestLocationPermission(context);
  }
  
  Future<bool> _requestActivityRecognition() async {
    final activityPermission = 
        await FlutterActivityRecognition.instance.checkPermission();
        
    if (activityPermission == ActivityPermission.DENIED) {
      final newPermission = 
          await FlutterActivityRecognition.instance.requestPermission();
      return newPermission == ActivityPermission.GRANTED;
    }
    
    return activityPermission == ActivityPermission.GRANTED;
  }
  
  Future<bool> _requestLocationPermissionWithoutDialog() async {
    if (await Permission.locationWhenInUse.isDenied) {
      final status = await Permission.locationWhenInUse.request();
      return status.isGranted;
    }
    return true;
  }
  
  Future<bool> _requestLocationPermission(BuildContext context) async {
    if (await Permission.locationWhenInUse.isDenied) {
      final status = await Permission.locationWhenInUse.request();
      
      if (!status.isGranted) {
        // Show a dialog explaining why location is needed
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'Location permission is needed to track your activity and progress for quests. '
                'Please enable location services to use this feature.'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return false;
      }
      return true;
    }
    return true;
  }
}
