import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/app_layout/views/app_layout.dart';
import 'package:flutter_application_2/features/auth/presentation/views/continue_register.dart';
import '../../features/home/views/home.dart';
import '../../features/auth/presentation/views/Login.dart';
import '../../features/auth/presentation/views/register.dart';
import 'routes.dart';

class AppRoutes {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case Routes.splashScreen:
      //   return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.registerScreen:
        return MaterialPageRoute(builder: (_) => const Register());
      case Routes.continueRegisterScreen:
        return MaterialPageRoute(builder: (_) => const ContinueRegister());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const Login());
      case Routes.appLayoutPage:
        return MaterialPageRoute(builder: (_) => const AppLayout());
      case Routes.homepage:
        return MaterialPageRoute(builder: (_) => const Home());
      // case Routes.forgetPassword:
      //   return MaterialPageRoute(builder: (_) => const ForgetPassword());
    }

    return null;
  }
}
