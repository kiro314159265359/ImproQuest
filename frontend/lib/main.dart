import 'dart:ui';
// import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/app_routes.dart';
import 'package:flutter_application_2/core/services/permission_manager.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_application_2/features/auth/presentation/manager/forget_password_cubit/forget_password_cubit.dart';
import 'package:flutter_application_2/features/profile/presentation/manager/distance_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/utils/get_it_constants.dart';
import 'features/auth/data/api/register_api.dart';
import 'features/auth/presentation/manager/register_cubit/register_cubit.dart';
import 'features/home/presentation/manager/user_cubit.dart';
import 'core/utils/auth_helpers.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'features/profile/presentation/manager/achievement_cubit.dart';
import 'features/rankings/presentation/manager/leaderboard_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Initialize hydrated storage so that the UserCubit is rehydrated.
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  await setupDependencies(); // This now includes HomeBloc registration

  FlutterForegroundTask.initCommunicationPort();

  bool permissionGranted = await requestPermissions();
  if (!permissionGranted) {
    print('Necessary permission(s) declined.');
  }

  final initialRoute = await determineInitialRoute(getIt<LoginRepo>());
  runApp(WithForegroundTask(child: MyApp(initialRoute: initialRoute)));
  // runApp(DevicePreview(
  //   builder: (context) =>
  //       WithForegroundTask(child: MyApp(initialRoute: initialRoute)),
  // ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    AppRoutes appRoutes = AppRoutes();
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterCubit>.value(
          value: RegisterCubit(RegisterApi()),
        ),
        BlocProvider<ForgetPasswordCubit>.value(
          value: ForgetPasswordCubit(getIt<LoginRepo>()),
        ),
        BlocProvider<UserCubit>.value(
          value: getIt<UserCubit>(),
        ),
        BlocProvider<AchievementCubit>.value(
          value: getIt<AchievementCubit>(),
        ),
        BlocProvider<DistanceCubit>.value(
          value: getIt<DistanceCubit>(),
        ),
        BlocProvider<LeaderboardCubit>.value(
          value: getIt<LeaderboardCubit>(),
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
