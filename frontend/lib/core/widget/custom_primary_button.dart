import 'package:flutter/material.dart';
import '../theme/color_manger.dart';
import '../theme/text_style.dart';

class CustomPrimaryButton extends StatefulWidget {
  final String buttonText;
  final Color? fillColor;
  final Color? cursorColor;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const CustomPrimaryButton(
      {super.key,
      required this.buttonText,
      this.fillColor,
      this.cursorColor,
      this.width = double.infinity,
      this.height,
      required this.onPressed});

  @override
  State<CustomPrimaryButton> createState() => _CustomPrimaryButtonState();
}

class _CustomPrimaryButtonState extends State<CustomPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: widget.onPressed,
        child: Text(widget.buttonText,
            style: TextStyles.styleBold(context,
                fontSize: 18, color: ColorManager.whiteColor)),
      ),
    );
  }
}
