import 'package:flutter/material.dart';
import '../../features/home/home.dart';
import '../../features/auth/Login.dart';
import '../../features/auth/register.dart';
import 'routes.dart';

class AppRoutes {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case Routes.splashScreen:
      //   return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routes.registerScreen:
        return MaterialPageRoute(builder: (_) => const Register());

      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const Login());

      case Routes.homepage:
        return MaterialPageRoute(builder: (_) => const Home());
      // case Routes.forgetPassword:
      //   return MaterialPageRoute(builder: (_) => const ForgetPassword());
    }

    return null;
  }
}
