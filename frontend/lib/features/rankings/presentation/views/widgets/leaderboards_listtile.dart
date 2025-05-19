import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../../core/utils/app_images.dart';

class LeaderboardsListTile extends StatefulWidget {
  final int? playerPlace;
  final String? playerName;
  final String? playerImage;
  final int? playerPoints;
  final bool isUser;
  const LeaderboardsListTile(
      {super.key,
      required this.playerImage,
      required this.playerPlace,
      required this.playerName,
      required this.playerPoints,
      required this.isUser});

  @override
  State<LeaderboardsListTile> createState() => _LeaderboardsListTileState();
}

class _LeaderboardsListTileState extends State<LeaderboardsListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
        color:
            widget.isUser ? ColorManager.primaryColor : ColorManager.fadedNavy,
        child: ListTile(
          leading: Text('${(widget.playerPlace! + 1)}',
              style: TextStyles.bold16White),
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: CircleAvatar(
                  backgroundColor: ColorManager.primaryColor,
                  radius: 24,
                  backgroundImage: widget.playerImage == null
                      ? const AssetImage(AppImages.profilePhoto)
                      : NetworkImage(widget.playerImage!),
                ),
              ),
              Text(widget.isUser ? "You" : widget.playerName!,
                  style: TextStyles.bold16White),
            ],
          ),
          trailing:
              Text('${widget.playerPoints}', style: TextStyles.bold16White),
        ));
  }
}
