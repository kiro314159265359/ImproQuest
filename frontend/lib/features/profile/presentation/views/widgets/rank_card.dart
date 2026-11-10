import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../../core/utils/app_icons.dart';

class RankCard extends StatelessWidget {
  final String userRank;

  const RankCard({
    super.key,
    required this.userRank,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorManager.gunmetal,
      child: ListTile(
          leading: Image.asset(
            _getRankIcon(userRank),
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          title: Text(
            'Your Current Tier:',
            style: TextStyles.bold16White,
          ),
          subtitle: Text(
            userRank.toUpperCase(),
            style: TextStyles.semiBold16Primary,
          )),
    );
  }

  String _getRankIcon(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return AppIcons.rankSIcon;
      case 'A':
        return AppIcons.rankAIcon;
      case 'B':
        return AppIcons.rankBIcon;
      case 'C':
        return AppIcons.rankCIcon;
      case 'D':
        return AppIcons.rankDIcon;
      case 'E':
        return AppIcons.rankEIcon;
      default:
        return AppIcons.rankEIcon;
    }
  }
}
