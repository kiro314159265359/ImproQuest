import 'package:flutter/material.dart';
import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';
import '../../../../../core/sensors/tracking_utils.dart';

class CustomQuestCard extends StatefulWidget {
  final String questName;
  final String questDesc;
  final String questImageIcon;
  final double progress;
  final int goal;
  final String? questId;
  final bool isCompleted;

  const CustomQuestCard(
      {super.key,
      required this.questName,
      required this.questDesc,
      required this.questImageIcon,
      required this.progress,
      required this.goal,
      this.questId,
      this.isCompleted = false});

  @override
  State<CustomQuestCard> createState() => _CustomQuestCardState();
}

class _CustomQuestCardState extends State<CustomQuestCard> {
  double _currentProgress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (widget.isCompleted) {
      setState(() {
        _currentProgress = 1.0;
        _isLoading = false;
      });
      return;
    }

    if (widget.questId != null) {
      final savedProgress =
          await TrackingUtils.getQuestProgress(widget.questId!);
      if (savedProgress > 0) {
        setState(() {
          _currentProgress = savedProgress;
          _isLoading = false;
        });
        return;
      }
    }

    // If no saved progress or quest is distance-related, calculate from actual distance
    if (widget.questName.toLowerCase().contains('distance') ||
        widget.questName.toLowerCase().contains('walk') ||
        widget.questName.toLowerCase().contains('run')) {
      final distance = await TrackingUtils.getTotalDistance();
      setState(() {
        _currentProgress = (distance / widget.goal).clamp(0.0, 1.0);
        _isLoading = false;
      });
    } else {
      setState(() {
        _currentProgress = widget.progress;
        _isLoading = false;
      });
    }
  }

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
                "[${(widget.goal * _currentProgress).toInt()}/${widget.goal}]",
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
                  child: _isLoading
                      ? const LinearProgressIndicator()
                      : LinearProgressIndicator(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(64)),
                          color: ColorManager.primaryColor,
                          value: _currentProgress,
                          backgroundColor: ColorManager.containerBackGround,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  _isLoading
                      ? "Loading..."
                      : _currentProgress >= 1.0
                          ? "[ COMPLETED ]"
                          : "[ UNCOMPLETED ]",
                  style: TextStyles.styleSemiBold(context,
                      fontSize: 12, color: ColorManager.whiteColor),
                ),
              )
            ],
          ),
        ));
  }
}
