import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/routes/app_routes.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_application_2/core/service/api/api_service.dart';
import 'package:flutter_application_2/features/auth/data/api/login_api.dart';
import 'package:flutter_application_2/features/auth/domain/repo/login_repo.dart';
import 'package:flutter_application_2/core/network/dio_interceptor.dart';
import 'features/home/data/api/user_api.dart';
import 'features/home/presentation/manager/user_cubit.dart';
import 'core/utils/auth_helpers.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ApiService once.
  final apiService = ApiService();
  // Inject the ApiService into LoginApi.
  final LoginRepo loginRepo = LoginApi(apiService);
  // Create and add the token interceptor.
  final tokenInterceptor = TokenInterceptor(dio: apiService.dio, loginRepo: loginRepo);
  apiService.dio.interceptors.add(tokenInterceptor);

  // Register your single instances.
  getIt.registerSingleton<ApiService>(apiService);
  getIt.registerSingleton<LoginRepo>(loginRepo);

  // Determine the initial route.
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
