import 'package:flutter/material.dart';
import '../theme/color_manger.dart';
import '../theme/text_style.dart';

class CustomPrimaryButton extends StatefulWidget {
  final String buttonText;
  final Color? fillColor;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final bool isLoading;

  const CustomPrimaryButton({
    super.key,
    required this.buttonText,
    this.fillColor,
    this.width = double.infinity,
    this.height,
    required this.onPressed,
    this.isLoading = false,
  });

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
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (widget.isLoading) {
                return ColorManager.gunmetal;
              }
              return ColorManager.primaryColor;
            },
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        onPressed: widget.isLoading ? null : widget.onPressed,
        child: widget.isLoading
            ? const CircularProgressIndicator(
                color: ColorManager.whiteColor,
                strokeWidth: 2,
              )
            : Text(
                widget.buttonText,
                style: TextStyles.styleBold(context,
                    fontSize: 18, color: ColorManager.whiteColor),
              ),
      ),
    );
  }
}
