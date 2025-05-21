import 'package:flutter/material.dart';
import '../theme/color_manger.dart';
import '../theme/text_style.dart';

class CustomButton extends StatefulWidget {
  final String buttonText;
  final String? buttonIcon;
  final Color? fillColor;
  final Color borderColor;
  final Color? iconColor;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? fontSize;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.buttonText,
    this.buttonIcon,
    this.fillColor,
    this.borderColor = Colors.transparent,
    this.iconColor = ColorManager.whiteColor,
    this.width = double.infinity,
    this.fontSize = 16,
    this.height,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: widget.buttonIcon == null
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.fillColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: widget.borderColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: w * 0.02),
              ),
              onPressed: widget.isLoading ? null : widget.onPressed,
              child: Text(
                widget.buttonText,
                style: TextStyles.styleBold(context,
                    fontSize: widget.fontSize, color: ColorManager.whiteColor),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            )
          : ElevatedButton.icon(
              icon: ImageIcon(
                AssetImage(widget.buttonIcon!),
                color: widget.iconColor,
                size: 25,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.fillColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: widget.borderColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: w * 0.02),
              ),
              onPressed: widget.isLoading ? null : widget.onPressed,
              label: Text(
                widget.buttonText,
                style: TextStyles.styleBold(context,
                    fontSize: widget.fontSize, color: ColorManager.whiteColor),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ),
    );
  }
}
