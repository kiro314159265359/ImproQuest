// lib/game/components/simple_progress_bar.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A simple progress bar drawn as a filled rectangle with an optional border.
class SimpleProgressBar extends PositionComponent {
  double progress; // expected to be between 0.0 and 1.0
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderWidth;

  SimpleProgressBar({
    required this.progress,
    this.backgroundColor = Colors.grey,
    this.foregroundColor = Colors.green,
    this.borderWidth = 2.0,
    super.size,
    super.position,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = size.toRect();

    // Draw background.
    final bgPaint = Paint()..color = backgroundColor;
    final bgRRect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(bgRRect, bgPaint);

    // Draw foreground (filled portion).
    final filledWidth = size.x * progress.clamp(0, 1);
    final fgRect = Rect.fromLTWH(0, 0, filledWidth, size.y);
    final fgRRect = RRect.fromRectAndRadius(fgRect, const Radius.circular(10));
    final fgPaint = Paint()..color = foregroundColor;
    canvas.drawRRect(fgRRect, fgPaint);
  }
}
