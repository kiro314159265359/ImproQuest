import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'simple_progress_bar.dart';

class StatusContainer extends PositionComponent {
  final SimpleProgressBar progressBar;
  final TextComponent hpText;

  StatusContainer({
    required Vector2 position,
    required Vector2 size,
    required this.progressBar,
    required this.hpText,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.black;
    canvas.drawRect(size.toRect(), paint);
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    add(progressBar);
    add(hpText);
    await super.onLoad();
  }
}
