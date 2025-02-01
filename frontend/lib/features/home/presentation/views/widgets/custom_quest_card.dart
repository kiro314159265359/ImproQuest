import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class CustomQuestCard extends StatefulWidget {
  final String questName;
  final String questDesc;
  final AssetImage questImageIcon;
  final double progress;
  final int goal;
  const CustomQuestCard(
      {super.key,
      required this.questName,
      required this.questDesc,
      required this.questImageIcon,
      required this.progress,
      required this.goal});

  @override
  State<CustomQuestCard> createState() => _CustomQuestCardState();
}

class _CustomQuestCardState extends State<CustomQuestCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        color: ColorManager.gunmetal,
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageIcon(
                      widget.questImageIcon,
                      color: ColorManager.whiteColor,
                      size: 25,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.questName,
                          style: TextStyles.styleSemiBold(context,
                              fontSize: 16, color: ColorManager.whiteColor),
                        ),
                        Text(
                          widget.questDesc,
                          style: TextStyles.styleSemiBold(context,
                              fontSize: 12, color: ColorManager.whiteColor),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                "[${(widget.goal * widget.progress).toInt()}/${widget.goal}]",
                style: TextStyles.styleSemiBold(context,
                    fontSize: 12, color: ColorManager.whiteColor),
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 7),
                  width: 230,
                  height: 12,
                  child: LinearProgressIndicator(
                    borderRadius: const BorderRadius.all(Radius.circular(64)),
                    color: ColorManager.primaryColor,
                    value: widget.progress,
                    backgroundColor: ColorManager.containerBackGround,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  (widget.goal * widget.progress).toInt() < widget.goal
                      ? "[ UNCOMPLETED ]"
                      : "[ COMPLETED ]",
                  style: TextStyles.styleSemiBold(context,
                      fontSize: 12, color: ColorManager.whiteColor),
                ),
              )
            ],
          ),
        ));
  }
}
