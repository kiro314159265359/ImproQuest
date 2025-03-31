import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class CustomQuestCard extends StatefulWidget {
  final String questName;
  final String questDesc;
  final String questImageIcon;
  final bool progress;
  final VoidCallback onCompleteQuest;
  final bool isLoading;

  const CustomQuestCard({
    super.key,
    required this.questName,
    required this.questDesc,
    required this.questImageIcon,
    required this.progress,
    required this.onCompleteQuest,
    required this.isLoading,
  });

  @override
  State<CustomQuestCard> createState() => _CustomQuestCardState();
}

class _CustomQuestCardState extends State<CustomQuestCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorManager.gunmetal,
      child: ListTile(
        leading: ImageIcon(
          AssetImage(widget.questImageIcon),
          color: ColorManager.whiteColor,
          size: 25,
        ),
        title: Text(
          widget.questName,
          style: TextStyles.styleSemiBold(context,
              fontSize: 16, color: ColorManager.whiteColor),
        ),
        subtitle: Text(
          widget.questDesc,
          style: TextStyles.styleSemiBold(context,
              fontSize: 12, color: ColorManager.whiteColor),
        ),
        trailing: widget.isLoading
            ? const CircularProgressIndicator(
                color: ColorManager.whiteColor,
                strokeWidth: 2,
              )
            : Checkbox(
                shape: const CircleBorder(),
                activeColor: ColorManager.primaryColor,
                tristate: false,
                value: widget.progress,
                onChanged: (bool? value) {
                  if (!widget.progress) {
                    widget.onCompleteQuest();
                  }
                },
              ),
      ),
    );
  }
}
