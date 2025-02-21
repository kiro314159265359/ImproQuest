import 'package:flutter/material.dart';
import 'color_manger.dart';

class AppTheme {
  static final ThemeData appTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColorManager.deepBlue,
      dialogBackgroundColor: ColorManager.deepBlue,
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating));
}
