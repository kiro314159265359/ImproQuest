import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class LeaderboardsListTile extends StatefulWidget {
  final int playerPlace;
  final String playerName;
  final String playerImage;
  final int playerPoints;
  const LeaderboardsListTile(
      {super.key,
      required this.playerImage,
      required this.playerPlace,
      required this.playerName,
      required this.playerPoints});

  @override
  State<LeaderboardsListTile> createState() => _LeaderboardsListTileState();
}

class _LeaderboardsListTileState extends State<LeaderboardsListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
        color: ColorManager.gunmetal.withOpacity(0.5),
        child: ListTile(
          leading: Text('${(widget.playerPlace + 1)}',
              style: TextStyles.styleBold(context,
                  fontSize: 16, color: ColorManager.whiteColor)),
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(widget.playerImage),
                ),
              ),
              Text(widget.playerName,
                  style: TextStyles.styleBold(context,
                      fontSize: 16, color: ColorManager.whiteColor)),
            ],
          ),
          trailing: Text('${widget.playerPoints}pts',
              style: TextStyles.styleBold(context,
                  fontSize: 16, color: ColorManager.whiteColor)),
        ));
  }
}
