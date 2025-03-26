import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../../core/widget/custom_primary_button.dart';

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
              (widget.progress) ? "[ COMPLETED ]" : "[ UNCOMPLETED ]",
              style: TextStyles.styleSemiBold(context,
                  fontSize: 12, color: ColorManager.whiteColor),
            ),
          ],
        ),
        // subtitle: ElevatedButton(
        //   onPressed:  widget.onCompleteQuest,
        //   child:  Text("Done",style: TextStyles.styleSemiBold(context,
        //       fontSize: 16, color: ColorManager.whiteColor)),
        // ),
        subtitle: CustomPrimaryButton(
            onPressed: widget.onCompleteQuest,
            buttonText: "Done",
            height: 45,
            isLoading: widget.isLoading),
      ),
    );
  }
}
