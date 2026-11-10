import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import '../theme/color_manger.dart';

class Snackbars {
  static void showErrorSnackbar(BuildContext context, String message) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: SizedBox(
          height: h * 0.1,
          width: w * 0.8,
          child: AwesomeSnackbarContent(
            color: ColorManager.errorColor,
            title: 'On Snap!',
            message: message,
            contentType: ContentType.failure,
          ),
        ),
      ),
    );
  }

  static void showSuccessSnackbar(BuildContext context, String message) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: SizedBox(
          height: h * 0.1,
          width: w * 0.8,
          child: AwesomeSnackbarContent(
            color: ColorManager.greenColor,
            title: 'Congrats!',
            message: message,
            contentType: ContentType.success,
          ),
        ),
      ),
    );
  }

  static void showNoticeSnackbar(BuildContext context, String message) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: SizedBox(
          height: h * 0.1,
          width: w * 0.8,
          child: AwesomeSnackbarContent(
            color: ColorManager.darkGoldColor,
            title: 'Notice!',
            message: message,
            contentType: ContentType.warning,
          ),
        ),
      ),
    );
  }
}
