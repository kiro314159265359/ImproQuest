import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/auth/presentation/views/continue_register.dart';
import 'package:flutter_application_2/features/auth/presentation/views/forgetpassword.dart';
import 'package:flutter_application_2/features/home/presentation/views/add_quest.dart';
import 'package:flutter_application_2/features/settings/presentation/views/personal_info.dart';
import 'package:flutter_application_2/game/game_page.dart';
import '../../features/app_layout/presentation/views/app_layout.dart';
import '../../features/home/presentation/views/home.dart';
import '../../features/auth/presentation/views/login.dart';
import '../../features/auth/presentation/views/register.dart';
import '../../game/shop_page.dart';
import 'routes.dart';

class AppRoutes {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case Routes.splashScreen:
      //   return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const Login());

      case Routes.registerScreen:
        return MaterialPageRoute(builder: (_) => const Register());

      case Routes.continueRegisterScreen:
        return MaterialPageRoute(builder: (_) => const ContinueRegister());

      case Routes.forgetPasswordScreen:
        return MaterialPageRoute(builder: (_) => const Forgetpassword());

      case Routes.appLayoutScreen:
        return MaterialPageRoute(builder: (_) => const AppLayout());

      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => const Home());

      case Routes.addQuestScreen:
        return MaterialPageRoute(builder: (_) => const AddQuest());

      case Routes.gameScreen:
        return MaterialPageRoute(builder: (_) => const GamePage());

      case Routes.shopScreen:
        return MaterialPageRoute(builder: (_) => const ShopPage());

      case Routes.personalInfoScreen:
        return MaterialPageRoute(builder: (_) => const PersonalInfo());
    }

    return null;
  }
}
