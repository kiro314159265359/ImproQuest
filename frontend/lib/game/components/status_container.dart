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
    final padding = size.x * 0.05;
    final verticalPadding = size.y * 0.05;
    final barHeight = size.y * 0.08;
    final barWidth = size.x - (2 * padding);
    final labelGroupSpacing = size.y * 0.30;
    final textBarSpacing = size.y * 0.05;

    nameText.position = Vector2(padding, verticalPadding);
    levelText.anchor = Anchor.topRight;
    levelText.position = Vector2(size.x - padding, verticalPadding);

    final hpLabelY = verticalPadding + size.y * 0.25;
    hpLabelText.position = Vector2(padding, hpLabelY);
    hpValueText.anchor = Anchor.topRight;
    hpValueText.position = Vector2(size.x - padding, hpLabelY);
    hpBar.position =
        Vector2(padding, hpLabelY + textBarSpacing + size.y * 0.05);
    hpBar.size = Vector2(barWidth, barHeight);

    final initLabelY = hpBar.position.y + barHeight + labelGroupSpacing * 0.5;
    initLabelText.position = Vector2(padding, initLabelY);
    initValueText.anchor = Anchor.topRight;
    initValueText.position = Vector2(size.x - padding, initLabelY);
    initBar.position =
        Vector2(padding, initLabelY + textBarSpacing + size.y * 0.05);
    initBar.size = Vector2(barWidth, barHeight);

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
