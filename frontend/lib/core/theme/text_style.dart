import 'package:flutter/material.dart';
import 'color_manger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class TextStyles {
  static TextStyle styleRegular(context, {Color? color, double? fontSize}) {
    return TextStyle(
      color: color ?? ColorManager.darkColor,
      fontSize: fontSize ?? 16.sp,
      fontFamily: 'PlusJakartaSans',
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle styleMedium(context, {Color? color, double? fontSize}) {
    return TextStyle(
      color: color ?? ColorManager.darkColor,
      fontSize: fontSize ?? 16.sp,
      fontFamily: 'PlusJakartaSans',
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle styleSemiBold(context, {Color? color, double? fontSize}) {
    return TextStyle(
      color: color ?? ColorManager.lightGrey,
      fontSize: fontSize ?? 16.sp,
      fontFamily: 'PlusJakartaSans',
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle styleBold(context, {Color? color, double? fontSize}) {
    return TextStyle(
      color: color ?? ColorManager.darkColor,
      fontSize: fontSize ?? 16.sp,
      fontFamily: 'PlusJakartaSans',
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle styleExtraBold(context, {Color? color, double? fontSize}) {
    return TextStyle(
      color: color ?? ColorManager.darkColor,
      fontSize: fontSize ?? 16.sp,
      fontFamily: 'PlusJakartaSans',
      fontWeight: FontWeight.w800,
    );
  }
}
