import 'dart:io';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermissions() async {
  // Android 13+, you need to allow notification permission to display foreground service notification.
  //
  // iOS: If you need notification, ask for permission.
  final NotificationPermission notificationPermission =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermission != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }

  bool isGranted = true;
  if (Platform.isAndroid) {
    // Android 12+, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // Request activity recognition permission.
    isGranted = await _checkAndRequestPermission();

    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.ignoreBatteryOptimizations,
      Permission.notification,
    ].request();

    statuses.forEach((permission, status) {
      print('Permission: $permission, Status: $status');
    });
  }
  return isGranted;
}

Future<bool> _checkAndRequestPermission() async {
  ActivityPermission permission =
      await FlutterActivityRecognition.instance.checkPermission();
  if (permission == ActivityPermission.PERMANENTLY_DENIED) {
    // permission has been permanently denied.
    return false;
  } else if (permission == ActivityPermission.DENIED) {
    permission = await FlutterActivityRecognition.instance.requestPermission();
    if (permission != ActivityPermission.GRANTED) {
      // permission is denied.
      return false;
    }
  }

  return true;
}
