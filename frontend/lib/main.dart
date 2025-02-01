import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/app_routes.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';

import 'core/utils/auth_helpers.dart';
import 'features/auth/data/api/login_api.dart';
import 'features/auth/domain/repo/login_repo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DevicePreview(
  //   builder: (context) => const MyApp(), // Wrap your app
  // ),
  
  // Instantiate your login repository (API implementation)
  final LoginRepo loginRepo = LoginApi();
  // Determine the initial route based on token validation and refresh logic.
  final initialRoute = await determineInitialRoute(loginRepo);

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppRoutes appRoutes = AppRoutes();
    return MaterialApp(
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: appRoutes.onGenerateRoute, themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ColorManager.deepBlue,
      ),
    );
  }
}

