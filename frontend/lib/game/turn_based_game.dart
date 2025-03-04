import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'components/simple_progress_bar.dart';
import 'components/status_container.dart';
import 'logic/game_state.dart';

// Custom game character component with visibility control and animations
class GameCharacter extends SpriteAnimationComponent with HasGameRef {
  final String characterType; // "hero" or "enemy"
  SpriteAnimation? idleAnimation;
  final String idlePath;
  final String attackPath;
  bool isFlipped;
  StatusContainer? statusContainer;

  GameCharacter({
    required this.characterType,
    required this.idlePath,
    required this.attackPath,
    required Vector2 size,
    required Vector2 position,
    this.isFlipped = false,
  }) : super(size: size, position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load idle animation
    await loadIdleAnimation();

    // Apply flip if needed
    if (isFlipped) {
      flipHorizontallyAroundCenter();
    }

    // Create status container
    statusContainer = createStatusContainer();
    gameRef.add(statusContainer!);
  }

  Future<void> loadIdleAnimation() async {
    final image = await gameRef.images.load(idlePath);
    final sheet = SpriteSheet(image: image, srcSize: Vector2(128, 128));
    idleAnimation = sheet.createAnimation(row: 0, stepTime: 0.1, to: 6);
    animation = idleAnimation;
  }

  StatusContainer createStatusContainer() {
    final yOffset = (characterType == "hero") ? -100 : -100;

    return StatusContainer(
      position: Vector2(position.x - 75, position.y + yOffset),
      size: Vector2(150, 50),
      progressBar: SimpleProgressBar(
        progress: 1.0,
        size: Vector2(100, 10),
        position: Vector2(10, 25),
        foregroundColor: Colors.green,
        backgroundColor: Colors.red,
      ),
      hpText: TextComponent(
        text: 'HP: 100/100',
        position: Vector2(10, 5),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Future<void> playAttackAnimation() async {
    final originalAnimation = animation;

    // Load attack animation
    final attackImage = await gameRef.images.load(attackPath);
    final attackSheet =
        SpriteSheet(image: attackImage, srcSize: Vector2(128, 128));
    final attackAnimation =
        attackSheet.createAnimation(row: 0, stepTime: 0.1, to: 4)..loop = false;

    // Switch to attack animation
    animation = attackAnimation;

    // Wait for animation to complete
    await animationTicker?.completed;

    // Restore original animation
    animation = originalAnimation;
  }

  void updateHealthInfo(int currentHp, int maxHp) {
    if (statusContainer != null) {
      final healthProgress = currentHp / maxHp;
      statusContainer!.progressBar.progress = healthProgress;
      statusContainer!.hpText.text = 'HP: $currentHp/$maxHp';
      statusContainer!.progressBar.update(0);
    }
  }
}

class TurnBasedGame extends FlameGame {
  GameCharacter? hero;
  GameCharacter? enemy;
  SpriteComponent? backgroundComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load background
    await loadBackground();

    // Create hero and enemy characters
    await createHero();
    await createEnemy();
  }

  Future<void> loadBackground() async {
    final bgImage = await images.load('sprites/backgrounds/vertical/31.png');
    backgroundComponent = SpriteComponent()
      ..sprite = Sprite(bgImage)
      ..size = size
      ..position = Vector2.zero();
    add(backgroundComponent!);
  }

  Future<void> createHero() async {
    hero = GameCharacter(
      characterType: "hero",
      idlePath: 'sprites/character/Shinobi/Idle.png',
      attackPath: 'sprites/character/Shinobi/Attack_1.png',
      size: Vector2(256, 256),
      position: Vector2(128, size.y - 180),
    );
    add(hero!);
  }

  Future<void> createEnemy() async {
    enemy = GameCharacter(
      characterType: "enemy",
      idlePath: 'sprites/character/Fighter/Idle.png',
      attackPath: 'sprites/character/Fighter/Attack_1.png',
      size: Vector2(256, 256),
      position: Vector2(size.x - 128, 128),
      isFlipped: true,
    );
    add(enemy!);
  }

  Future<void> updateEnemy(dynamic enemyObj) async {
    if (enemy != null) {
      enemy!.removeFromParent();
    }

    // Determine enemy asset based on type
    String enemyIdlePath = 'sprites/character/Fighter/Idle.png';
    String enemyAttackPath = 'sprites/character/Fighter/Attack_1.png';

    if (enemyObj != null && enemyObj.isBoss) {
      // Could use different sprites for boss enemies
      enemyIdlePath = 'sprites/character/Fighter/Idle.png';
      enemyAttackPath = 'sprites/character/Fighter/Attack_1.png';
    }

    enemy = GameCharacter(
      characterType: "enemy",
      idlePath: enemyIdlePath,
      attackPath: enemyAttackPath,
      size: Vector2(256, 256),
      position: Vector2(size.x - 128, 128),
      isFlipped: true,
    );
    add(enemy!);
  }

  void updateBars(GameState state) {
    hero?.updateHealthInfo(state.player.currentHp, state.player.vitality);
    enemy?.updateHealthInfo(state.enemy.currentHp, state.enemy.vitality);
  }

  Future<void> playAttackAnimationForHero() async {
    if (hero != null) {
      await hero!.playAttackAnimation();
    }
  }

  Future<void> playAttackAnimationForEnemy() async {
    if (enemy != null) {
      await enemy!.playAttackAnimation();
    }
  }
}
