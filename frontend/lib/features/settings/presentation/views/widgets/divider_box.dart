import 'package:flutter/material.dart';

import '../../../../../core/theme/color_manger.dart';

class DividerBox extends StatefulWidget {
  final Widget child1;
  final Widget child2;

  const DividerBox({super.key, required this.child1, required this.child2});

  @override
  State<DividerBox> createState() => _DividerBoxState();
}

class _DividerBoxState extends State<DividerBox> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorManager.gunmetal,
      child: Column(
        children: [
          widget.child1,
          const Divider(
            height: 3,
            indent: 12,
            endIndent: 12,
          ),
          widget.child2
        ],
      ),
    );
  }
}
