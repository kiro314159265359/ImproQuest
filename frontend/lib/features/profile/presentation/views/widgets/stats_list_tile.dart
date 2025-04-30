import 'package:flutter/material.dart';

import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class StatsListTile extends StatefulWidget {
  final String statName;
  final String statNum;
  final String statSubName;
  final String statSubNum;
  final String statIcon;

  const StatsListTile(
      {super.key,
      required this.statName,
      required this.statNum,
      required this.statSubName,
      required this.statSubNum,
      required this.statIcon});

  @override
  State<StatsListTile> createState() => _StatsListTileState();
}

class _StatsListTileState extends State<StatsListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ImageIcon(
        AssetImage(widget.statIcon),
        color: ColorManager.whiteColor,
        size: 25,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.statName,
            style: TextStyles.styleMedium(context,
                fontSize: 16, color: ColorManager.whiteColor),
          ),
          Text(
            widget.statNum,
            style: TextStyles.styleMedium(context,
                fontSize: 16, color: ColorManager.whiteColor),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.statSubName,
            style: TextStyles.styleMedium(context,
                fontSize: 12, color: ColorManager.whiteColor),
          ),
          Text(
            widget.statSubNum,
            style: TextStyles.styleMedium(context,
                fontSize: 12, color: ColorManager.whiteColor),
          ),
        ],
      ),
    );
  }
}
