import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/app_routes.dart';
import 'package:flutter_application_2/core/services/distance_service_handler.dart';
import 'package:flutter_application_2/core/services/permission_manager.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/service/api/api_service.dart';
import 'core/utils/get_it_constants.dart';
import 'features/home/data/api/user_api.dart';
import 'features/home/presentation/manager/user_cubit.dart';
import 'core/utils/auth_helpers.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

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
      eventAction: ForegroundTaskEventAction.repeat(5000),
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use the documents directory to persist data between app restarts.
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        HydratedStorageDirectory((await getApplicationDocumentsDirectory()).path),
  );
  await setupDependencies();
  FlutterForegroundTask.initCommunicationPort();

  bool permissionGranted = await requestPermissions();
  if (permissionGranted) {
    _initService();
    await _startService();
  } else {
    print('Necessary permission(s) declined.');
  }

  final initialRoute = await determineInitialRoute(getIt<LoginRepo>());

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    AppRoutes appRoutes = AppRoutes();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserCubit(UserApi(getIt<ApiService>())),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        onGenerateRoute: appRoutes.onGenerateRoute,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.appTheme,
      ),
    );
  }
}
