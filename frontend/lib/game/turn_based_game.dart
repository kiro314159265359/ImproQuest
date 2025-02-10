// lib/game/turn_based_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/extensions.dart';

class TurnBasedGame extends FlameGame {
  late SpriteAnimationComponent heroAnimationComponent;
  late SpriteAnimationComponent enemyAnimationComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Load the sprite sheet images.
    final heroImage = await images.load('sprites/character/Fighter/Idle.png');
    final enemyImage = await images.load('sprites/character/Shinobi/Idle.png');

    // 2. Create sprite sheet objects.
    // Assume each frame is 64x64 pixels. Adjust if needed.
    final heroSheet = SpriteSheet(
      image: heroImage,
      srcSize: Vector2(128, 128),
    );

    final enemySheet = SpriteSheet(
      image: enemyImage,
      srcSize: Vector2(128, 128),
    );

    // 3. Create animations from the sprite sheets.
    // For example, using the first row (row 0) with 4 frames and a 0.1 second frame duration.
    final heroAnimation = heroSheet.createAnimation(
      row: 0,
      stepTime: 0.1,
      to: 6,
    );

    final enemyAnimation = enemySheet.createAnimation(
      row: 0,
      stepTime: 0.1,
      to: 6,
    );

    // 4. Create animated sprite components.
    heroAnimationComponent = SpriteAnimationComponent(
      animation: heroAnimation,
      size: Vector2(256, 256), // Scale up the frame to desired size.
      position: Vector2(0, size.y - 325), // Position near the bottom left.
    );

    enemyAnimationComponent = SpriteAnimationComponent(
      animation: enemyAnimation,
      size: Vector2(256, 256),
      position: Vector2(size.x - 200, 0), // Position near the top right.
    );

    // 5. Add components to the game.
    add(heroAnimationComponent);
    add(enemyAnimationComponent);
  }
}
