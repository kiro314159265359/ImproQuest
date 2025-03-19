import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'distance_service_handler.dart';

void _initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'quest_tracking_service',
      channelName: 'Quest Tracking Service',
      channelDescription:
          'This notification appears when the foreground service is running.',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(2000),
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

Future<ServiceRequestResult> _startService() async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'Quest Tracking Service',
      notificationText: 'Tracking your activity progress',
      notificationIcon: null,
      notificationButtons: [
        const NotificationButton(id: 'btn_stop', text: 'Stop'),
      ],
      notificationInitialRoute: '/',
      callback: startCallback,
    );
  }
}

/// This top-level function checks the loaded user state and starts the foreground service
/// if there are any incomplete main quests (non‑custom quests).
Future<void> startForegroundServiceIfNeeded(dynamic state) async {
  // Assuming state is of type UserLoaded (from your UserCubit).
  final mainQuests =
      state.user.quests?.where((quest) => quest.isCustom != true).toList() ??
          [];
  bool hasIncompleteMainQuest =
      mainQuests.isNotEmpty && mainQuests.any((q) => q.isCompleted != true);

  if (hasIncompleteMainQuest) {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) {
      print(
          "Starting foreground service because there are active main quests.");
      _initService();
      await _startService();
    }
  } else {
    print("No active main quests; foreground service will not be started.");
  }
}
