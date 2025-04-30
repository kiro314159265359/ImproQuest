import 'package:flutter/material.dart';

import '../../../../../core/theme/color_manger.dart';

class ItemButton extends StatefulWidget {
  final double width;
  final double height;
  final String itemPhoto;
  final VoidCallback? onPressed;
  const ItemButton(
      {super.key,
      required this.width,
      required this.height,
      required this.itemPhoto,
      this.onPressed});

  @override
  State<ItemButton> createState() => _ItemButtonState();
}

class _ItemButtonState extends State<ItemButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.gunmetal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
        ),
        onPressed: widget.onPressed,
        child: Image.asset(
          widget.itemPhoto,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
