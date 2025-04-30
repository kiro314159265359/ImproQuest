import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/color_manger.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import 'package:flutter_application_2/game/widgets/menu_button.dart';

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
              style: TextStyles.styleBold(context,
                  fontSize: 28, color: ColorManager.whiteColor),
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
            child: MenuButton(
              fillColor: ColorManager.primaryColor,
              buttonText: "Continue",
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
