import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../home/presentation/manager/user_cubit.dart';
import '../../../../../core/widget/dialogs.dart';

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
    final userCubit = context.watch<UserCubit>();
    final availableSkillPoints = userCubit.currentUser?.skillPoints ?? 0;

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
            style: TextStyles.medium16White,
          ),
          Row(
            children: [
              if (availableSkillPoints > 0)
                IconButton(
                  onPressed: () {
                    Dialogs.skillpointsDialog(
                      context: context,
                      statName: widget.statName,
                      availableSkillPoints: availableSkillPoints,
                      onConfirm: (pointsSpent) {
                        if (pointsSpent > 0) {
                          userCubit.skillPoints(
                              widget.statName.toLowerCase(), pointsSpent);
                        }
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_circle_up,
                    color: ColorManager.lightGreen,
                    size: 20,
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                widget.statNum,
                style: TextStyles.medium16White,
              ),
            ],
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.statSubName,
            style: TextStyles.medium12White,
          ),
          Text(
            widget.statSubNum,
            style: TextStyles.medium12White,
          ),
        ],
      ),
    );
  }
}
