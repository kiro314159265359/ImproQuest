import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class QuestCard extends StatefulWidget {
  final String questName;
  final String questDesc;
  final String questImageIcon;
  final double progress;
  final int goal;
  const QuestCard(
      {super.key,
      required this.questName,
      required this.questDesc,
      required this.questImageIcon,
      required this.progress,
      required this.goal});

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
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
                      AssetImage(widget.questImageIcon),
                      color: ColorManager.whiteColor,
                      size: 24,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.questName} ${widget.goal}m",
                          style: TextStyles.semiBold16White,
                        ),
                        Text(
                          widget.questDesc,
                          style: TextStyles.semiBold12White,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                "[${(widget.goal * widget.progress).toInt()}/${widget.goal}]",
                style: TextStyles.semiBold12White,
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
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
                  style: TextStyles.semiBold12White,
                ),
              )
            ],
          ),
        ));
  }
}
