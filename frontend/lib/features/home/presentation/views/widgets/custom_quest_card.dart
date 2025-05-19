import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/home/data/model/user_model.dart'; // Added import for Quests
import 'package:flutter_application_2/features/home/presentation/views/add_quest.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class CustomQuestCard extends StatefulWidget {
  final Quests quest;
  final String questImageIcon;
  final VoidCallback onCompleteQuest;
  final VoidCallback onDeleteQuest;
  final bool isLoading;

  const CustomQuestCard({
    super.key,
    required this.quest,
    required this.questImageIcon,
    required this.onCompleteQuest,
    required this.onDeleteQuest,
    required this.isLoading,
  });

  @override
  State<CustomQuestCard> createState() => _CustomQuestCardState();
}

class _CustomQuestCardState extends State<CustomQuestCard> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddQuest(
                          isEditing: true,
                          quest: widget.quest,
                        )));
              },
              backgroundColor: ColorManager.lightBlue,
              foregroundColor: ColorManager.whiteColor,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
          ]),
      endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                widget.onDeleteQuest();
              },
              backgroundColor: ColorManager.redColor,
              foregroundColor: ColorManager.whiteColor,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
          ]),
      child: Card(
        margin: EdgeInsets.zero,
        color: ColorManager.gunmetal,
        child: ListTile(
          leading: ImageIcon(
            AssetImage(widget.questImageIcon),
            color: ColorManager.whiteColor,
            size: 25,
          ),
          title: Text(
            widget.quest.name ?? "Unnamed Quest",
            style: TextStyles.semiBold16White,
          ),
          subtitle: Text(
            "${widget.quest.xpReward ?? 0} XP • ${widget.quest.goldReward ?? 0} Gold",
            style: TextStyles.semiBold12White,
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
                  value: widget.quest.isCompleted,
                  onChanged: (bool? value) {
                    if (!(widget.quest.isCompleted!)) {
                      widget.onCompleteQuest();
                    }
                  },
                ),
        ),
      ),
    );
  }
}
