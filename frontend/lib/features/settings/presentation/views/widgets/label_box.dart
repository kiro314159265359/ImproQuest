import 'package:flutter/material.dart';

import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class LabelBox extends StatefulWidget {
  final IconData? leadingIcon;
  final String labelText;
  final Widget child;

  const LabelBox(
      {super.key,
      this.leadingIcon,
      required this.labelText,
      required this.child});

  @override
  State<LabelBox> createState() => _LabelBoxState();
}

class _LabelBoxState extends State<LabelBox> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        leading: widget.leadingIcon != null
            ? Icon(
                widget.leadingIcon,
                size: 24,
                color: ColorManager.darkGreyColor,
              )
            : null,
        title: Text(widget.labelText,
            style: TextStyles.semiBold16darkGrey, textAlign: TextAlign.start),
      ),
      widget.child
    ]);
  }
}
