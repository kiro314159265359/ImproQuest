import 'package:flutter/material.dart';

import '../../core/theme/color_manger.dart';
import '../../core/theme/text_style.dart';

class MenuButton extends StatefulWidget {
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

  const MenuButton({
    super.key,
    required this.buttonText,
    this.buttonIcon,
    this.fillColor,
    this.borderColor = Colors.transparent,
    this.iconColor = ColorManager.whiteColor,
    this.width = double.infinity,
    this.fontSize = 18,
    this.height,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
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
              ),
              onPressed: widget.isLoading ? null : widget.onPressed,
              child: Text(
                widget.buttonText,
                style: TextStyles.styleBold(context,
                    fontSize: widget.fontSize, color: ColorManager.whiteColor),
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
              ),
              onPressed: widget.isLoading ? null : widget.onPressed,
              label: Text(
                widget.buttonText,
                style: TextStyles.styleBold(context,
                    fontSize: widget.fontSize, color: ColorManager.whiteColor),
              ),
            ),
    );
  }
}
