import 'package:flutter/material.dart';

import 'color_manger.dart';

class BackgroundTheme extends StatefulWidget {
  final Widget child;
  const BackgroundTheme({super.key, required this.child});

  @override
  State<BackgroundTheme> createState() => _BackgroundThemeState();
}

class _BackgroundThemeState extends State<BackgroundTheme> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorManager.navyColor,
              ColorManager.deepBlue,
            ],
          ),
        ),
        child: widget.child);
  }
}
