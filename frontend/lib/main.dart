import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/app_routes.dart';
import 'package:flutter_application_2/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import 'core/service/api/api_service.dart';
import 'core/utils/get_it_constants.dart';
import 'features/home/data/api/user_api.dart';
import 'features/home/presentation/manager/user_cubit.dart';
import 'core/utils/auth_helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  // Determine the initial route
  final initialRoute = await determineInitialRoute(getIt<LoginRepo>());

  runApp(MyApp(initialRoute: initialRoute));
  // runApp(DevicePreview(
  //   builder: (context) => MyApp(initialRoute: initialRoute),
  // ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    AppRoutes appRoutes = AppRoutes();
    return BlocProvider(
      create: (context) => UserCubit(UserApi(getIt<ApiService>())),
      child: MaterialApp(
          // locale: DevicePreview.locale(context),
          // builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,
          onGenerateRoute: appRoutes.onGenerateRoute,
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.appTheme),
    );
  }
}
