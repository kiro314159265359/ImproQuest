import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/core/widget/custom_button.dart';

class Dialogs {
  static Future<void> noticeDialog(
      {required BuildContext context,
      String? title,
      Widget? content,
      VoidCallback? onPressed}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.gunmetal,
        // shadowColor: ColorManager.neonBlue,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(width: 2, color: ColorManager.neonBlue)),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Divider(
              color: ColorManager.darkGreyColor,
              height: 5,
            ),
            Text(
              title!,
              style: TextStyles.bold28White,
            ),
            const Divider(
              color: ColorManager.darkGreyColor,
              height: 5,
            ),
          ],
        ),
        content: content,
        actions: [
          Center(
            child: CustomButton(
              fillColor: ColorManager.primaryColor,
              buttonText: "Continue",
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> confirmDialog(
      {required BuildContext context,
      String? title,
      String? content,
      VoidCallback? onPressed}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.gunmetal,
        // shadowColor: ColorManager.neonBlue,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(width: 2, color: ColorManager.neonBlue)),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Divider(
              color: ColorManager.darkGreyColor,
              height: 5,
            ),
            Text(
              title!,
              style: TextStyles.bold24White,
            ),
            const Divider(
              color: ColorManager.darkGreyColor,
              height: 5,
            ),
          ],
        ),
        content: Text(
          content!,
          style: TextStyles.medium16White,
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CustomButton(
                  borderColor: ColorManager.lightGrey,
                  fillColor: Colors.transparent,
                  buttonText: "Cancel",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  fillColor: ColorManager.errorColor,
                  buttonText: "Continue",
                  onPressed: onPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> loadingDialog({required BuildContext context}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.gunmetal,
        // shadowColor: ColorManager.neonBlue,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(width: 2, color: ColorManager.neonBlue)),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const CircularProgressIndicator(
              color: ColorManager.primaryColor,
              strokeWidth: 2,
            ),
            Text(
              "loading...",
              style: TextStyles.medium16White,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
