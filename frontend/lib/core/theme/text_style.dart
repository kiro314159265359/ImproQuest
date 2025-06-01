import 'package:flutter/material.dart';
import 'color_manger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyles {
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

  static TextStyle regular16Dark = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.darkColor,
  );

  static TextStyle regularItalic12darkGold = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: ColorManager.darkGoldColor,
  );

  static TextStyle regular20White = const TextStyle(
    fontSize: 20,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.whiteColor,
  );
  static TextStyle regular24White = const TextStyle(
    fontSize: 24,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.whiteColor,
  );
  static TextStyle regular14Grey = const TextStyle(
    fontSize: 14,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.lightGrey,
  );
  static TextStyle regular14primary = const TextStyle(
    fontSize: 14,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.primaryColor,
  );
  static TextStyle regular14White = const TextStyle(
    fontSize: 14,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.whiteColor,
  );
  static TextStyle regular12White = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.whiteColor,
  );
  static TextStyle regular12Gold = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.goldColor,
  );
  static TextStyle regular12LightGrey = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.lightGrey,
  );
  static TextStyle regular12LightBlue = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.lightBlueColor,
  );
  static TextStyle medium16Dark = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w500,
    color: ColorManager.darkColor,
  );

  static TextStyle semiBold16Grey = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.lightGrey,
  );

  static TextStyle semiBold16darkGrey = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.darkGreyColor,
  );
  static TextStyle semiBold16Dark = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.darkColor,
  );

  static TextStyle bold16Dark = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.darkColor,
  );
  static TextStyle bold16Primary = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.primaryColor,
  );
  static TextStyle bold20Primary = const TextStyle(
    fontSize: 20,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.primaryColor,
  );
  static TextStyle bold24Primary = const TextStyle(
    fontSize: 24,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.primaryColor,
  );
  static TextStyle bold8Primary = const TextStyle(
    fontSize: 8,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.primaryColor,
  );
  static TextStyle bold16lightGrey = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.lightGrey,
  );
  static TextStyle bold16Grey = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.greyColor,
  );

  static TextStyle extraBold16Dark = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w800,
    color: ColorManager.darkColor,
  );

  static TextStyle extraBold20Dark = const TextStyle(
    fontSize: 20,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w800,
    color: ColorManager.darkColor,
  );
  static TextStyle extraBold24White = const TextStyle(
    fontSize: 24,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w800,
    color: ColorManager.whiteColor,
  );
  static TextStyle extraBold28White = const TextStyle(
    fontSize: 28,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w800,
    color: ColorManager.whiteColor,
  );

  static TextStyle extraBold32White = const TextStyle(
    fontSize: 32,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w800,
    color: ColorManager.whiteColor,
  );

  static TextStyle regular16White = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w400,
    color: ColorManager.whiteColor,
  );

  static TextStyle medium8White = const TextStyle(
    fontSize: 8,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w500,
    color: ColorManager.whiteColor,
  );

  static TextStyle medium12White = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w500,
    color: ColorManager.whiteColor,
  );

  static TextStyle medium16White = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w500,
    color: ColorManager.whiteColor,
  );

  static TextStyle semiBold12White = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.whiteColor,
  );

  static TextStyle semiBold16White = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.whiteColor,
  );

  static TextStyle semiBold8White = const TextStyle(
    fontSize: 8,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.whiteColor,
  );

  static TextStyle semiBold16lightGreen = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.lightGreen,
  );
  static TextStyle semiBold12lightGrey = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.lightGrey,
  );
  static TextStyle semiBold16lightGrey = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.lightGrey,
  );
  static TextStyle semiBold20White = const TextStyle(
    fontSize: 20,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.whiteColor,
  );
  static TextStyle bold16White = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.whiteColor,
  );

  static TextStyle bold16Gold = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.goldColor,
  );

  static TextStyle bold20White = const TextStyle(
    fontSize: 20,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.whiteColor,
  );
  static TextStyle bold24White = const TextStyle(
    fontSize: 24,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.whiteColor,
  );
  static TextStyle bold28White = const TextStyle(
    fontSize: 28,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.whiteColor,
  );

  static TextStyle semiBold12Primary = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.primaryColor,
  );
  static TextStyle semiBold16Primary = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.primaryColor,
  );

  static TextStyle bold16Error = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.errorColor,
  );
  static TextStyle bold12Green = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.greenColor,
  );

  static TextStyle bold12White = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.whiteColor,
  );
  static TextStyle bold20Error = const TextStyle(
    fontSize: 20,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w700,
    color: ColorManager.errorColor,
  );
  static TextStyle semiBold16Error = const TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.errorColor,
  );
  static TextStyle semiBold12Red = const TextStyle(
    fontSize: 12,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.redColor,
  );
  static TextStyle semiBold16fadedlightGrey = TextStyle(
    fontSize: 16,
    fontFamily: 'PlusJakartaSans',
    fontWeight: FontWeight.w600,
    color: ColorManager.fadedlightGrey,
  );
}
