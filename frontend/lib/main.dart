import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/app_routes.dart';
import 'package:flutter_application_2/core/routes/routes.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';

void main() => runApp(const MyApp()
    // DevicePreview(
    //   builder: (context) => const MyApp(), // Wrap your app
    // ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppRoutes appRoutes = AppRoutes();
    return MaterialApp(
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.loginScreen,
      onGenerateRoute: appRoutes.onGenerateRoute, themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ColorManager.deepBlue,
      ),
    );
  }
}
