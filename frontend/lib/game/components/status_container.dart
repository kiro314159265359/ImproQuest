import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme/color_manger.dart';
import 'simple_progress_bar.dart';

class StatusContainer extends PositionComponent {
  final TextComponent nameText;
  final TextComponent levelText;
  final TextComponent hpLabelText;
  final TextComponent hpValueText;
  final TextComponent initLabelText;
  final TextComponent initValueText;
  final SimpleProgressBar hpBar;
  final SimpleProgressBar initBar;

  StatusContainer({
    required this.nameText,
    required this.levelText,
    required this.hpLabelText,
    required this.hpValueText,
    required this.initLabelText,
    required this.initValueText,
    required this.hpBar,
    required this.initBar,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = ColorManager.gunmetal;
    final rect =
        RRect.fromRectAndRadius(size.toRect(), const Radius.circular(10));
    canvas.drawRRect(rect, paint);
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    nameText.position = Vector2(10, 5);
    levelText.position = Vector2(size.x - 65, 5);

    hpLabelText.position = Vector2(10, 30);
    hpValueText.position = Vector2(size.x - 60, 30);
    hpBar.position = Vector2(10, 45);

    initLabelText.position = Vector2(10, 65);
    initValueText.position = Vector2(size.x - 50, 65);
    initBar.position = Vector2(10, 80);

    add(nameText);
    add(levelText);
    add(hpLabelText);
    add(hpValueText);
    add(hpBar);
    add(initLabelText);
    add(initValueText);
    add(initBar);
    await super.onLoad();
  }
}
