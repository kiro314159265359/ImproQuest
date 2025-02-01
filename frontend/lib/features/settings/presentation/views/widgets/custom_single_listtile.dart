import 'package:flutter/material.dart';

import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class CustomSingleListTile extends StatefulWidget {
  final IconData leadingIcon;
  final String titleText;
  final void Function() onTap;
  const CustomSingleListTile(
      {super.key,
      required this.titleText,
      required this.leadingIcon,
      required this.onTap});

  @override
  State<CustomSingleListTile> createState() => _CustomSingleListTileState();
}

class _CustomSingleListTileState extends State<CustomSingleListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorManager.gunmetal,
      child: ListTile(
        leading: Icon(widget.leadingIcon, size: 30),
        title: Text(widget.titleText,
            style: TextStyles.styleSemiBold(context,
                fontSize: 18, color: ColorManager.whiteColor)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 30),
        onTap: widget.onTap,
      ),
    );
  }
}
