import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/app_routes.dart';
import 'package:flutter_application_2/core/services/permission_manager.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/utils/get_it_constants.dart';
import 'features/home/presentation/manager/user_cubit.dart';
import 'core/utils/auth_helpers.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

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
}


class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    AppRoutes appRoutes = AppRoutes();
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>.value(
          value: getIt<UserCubit>(),
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
