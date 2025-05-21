import 'package:flutter/material.dart';

import '../../../../../core/theme/color_manger.dart';
import '../../../../../core/theme/text_style.dart';

class SkillPointDialogContent extends StatefulWidget {
  final int availableSkillPoints;
  final ValueChanged<int> onPointsChanged;
  final int initialPointsToSpend;

  const SkillPointDialogContent({
    super.key,
    required this.availableSkillPoints,
    required this.onPointsChanged,
    required this.initialPointsToSpend,
  });

  @override
  State<SkillPointDialogContent> createState() =>
      _SkillPointDialogContentState();
}

class _SkillPointDialogContentState extends State<SkillPointDialogContent> {
  late int _pointsToSpend;

  @override
  void initState() {
    super.initState();
    _pointsToSpend = widget.initialPointsToSpend;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPointsChanged(_pointsToSpend);
    });
  }

  void _incrementPoints() {
    if (widget.availableSkillPoints > 0 &&
        _pointsToSpend < widget.availableSkillPoints) {
      setState(() {
        _pointsToSpend++;
        widget.onPointsChanged(_pointsToSpend);
      });
    }
  }

  void _decrementPoints() {
    if (widget.availableSkillPoints > 0 && _pointsToSpend > 1) {
      setState(() {
        _pointsToSpend--;
        widget.onPointsChanged(_pointsToSpend);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Points to spend:',
          style: TextStyles.medium16White,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: ColorManager.primaryColor),
              onPressed: (_pointsToSpend > 1) ? _decrementPoints : null,
            ),
            Text(
              '$_pointsToSpend',
              style: TextStyles.bold20White,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: ColorManager.primaryColor),
              onPressed: (_pointsToSpend < widget.availableSkillPoints)
                  ? _incrementPoints
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
