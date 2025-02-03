import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/app_routes.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/utils/auth_helpers.dart';
import 'features/auth/data/api/login_api.dart';
import 'features/auth/domain/repo/login_repo.dart';
import 'features/home/data/api/user_api.dart';
import 'features/home/presentation/manager/user_cubit.dart';

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

  @override
  Widget build(BuildContext context) {
    AppRoutes appRoutes = AppRoutes();
    return BlocProvider(
      create: (context) => UserCubit(UserApi()),
      child: MaterialApp(
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        onGenerateRoute: appRoutes.onGenerateRoute, themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: ColorManager.deepBlue,
        ),
      ),
    );
  }
}
