import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../core/theme/color_manger.dart';
import 'components/simple_progress_bar.dart';
import 'components/status_container.dart';
import 'logic/game_state.dart';
import 'logic/game_bloc.dart'; // Add import for GameBloc

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

  // Refactored method to load animations
  Future<SpriteAnimation> _loadAnimation(String path,
      {int frames = 6, double stepTime = 0.1}) async {
    final image = await gameRef.images.load(path);
    final sheet = SpriteSheet(image: image, srcSize: Vector2(128, 128));
    return sheet.createAnimation(row: 0, stepTime: stepTime, to: frames);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load idle animation using new helper method
    idleAnimation = await _loadAnimation(idlePath);
    animation = idleAnimation;

    // Apply flip if needed
    if (isFlipped) {
      flipHorizontallyAroundCenter();
    }

    // Create status container
    statusContainer = createStatusContainer();
    gameRef.add(statusContainer!);
  }

  StatusContainer createStatusContainer() {
    final xOffset = (characterType == "hero") ? 85 : -250;

    return StatusContainer(
      position: Vector2(position.x + xOffset, position.y),
      size: Vector2(200, 100),
      nameText: TextComponent(
        text: 'SUNG JINWOO',
        textRenderer: TextPaint(
          style:
              const TextStyle(color: ColorManager.primaryColor, fontSize: 14),
        ),
      ),
      levelText: TextComponent(
        text: 'LEVEL 25',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      hpLabelText: TextComponent(
        text: 'HP',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      hpValueText: TextComponent(
        text: '100/100',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      hpBar: SimpleProgressBar(
        progress: 1.0,
        size: Vector2(180, 8),
        position: Vector2(10, 25),
        foregroundColor: Colors.green,
        backgroundColor: Colors.red,
      ),
      initLabelText: TextComponent(
        text: 'INIT',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      initValueText: TextComponent(
        text: '0/100',
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      initBar: SimpleProgressBar(
        progress: 0.0,
        size: Vector2(180, 8),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.grey,
      ),
    );
  }

  Future<void> playAttackAnimation({Function? onComplete}) async {
    final originalAnimation = animation;

    // Load attack animation using helper method
    final attackAnimation =
        await _loadAnimation(attackPath, frames: 4, stepTime: 0.1)
          ..loop = false;

    // Switch to attack animation
    animation = attackAnimation;

    // Wait for animation to complete
    await animationTicker?.completed;

    // Restore original animation
    animation = originalAnimation;

    // Execute callback if provided
    onComplete?.call();
  }

  void updateHealthInfo(int currentHp, int maxHp, double playerInitiative) {
    if (statusContainer != null) {
      final healthProgress = currentHp / maxHp;
      const double initiativeThreshold = 100.0;
      double playerInitiativeProgress = playerInitiative / initiativeThreshold;
      statusContainer!.hpBar.progress = healthProgress;
      statusContainer!.hpValueText.text = '$currentHp/$maxHp';
      statusContainer!.initBar.progress = playerInitiativeProgress;
      statusContainer!.initValueText.text =
          '${(playerInitiativeProgress * 100).toInt()}/100';
      statusContainer!.hpBar.update(0);
      statusContainer!.initBar.update(0);
    }
  }
}

class TurnBasedGame extends FlameGame {
  GameCharacter? hero;
  GameCharacter? enemy;
  SpriteComponent? backgroundComponent;
  Function? onHeroAnimationComplete;
  Function? onEnemyAnimationComplete;
  GameBloc? gameBloc; // Add reference to GameBloc

  // Helper method to create characters with consistent configuration
  Future<GameCharacter> _createCharacter({
    required String type,
    required String idlePath,
    required String attackPath,
    required Vector2 position,
    required bool isFlipped,
  }) async {
    final character = GameCharacter(
      characterType: type,
      idlePath: idlePath,
      attackPath: attackPath,
      size: Vector2(256, 256),
      position: position,
      isFlipped: isFlipped,
    );

    add(character);
    return character;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadBackground();
    await createCharacters();
  }

  Future<void> loadBackground() async {
    final bgImage = await images.load('sprites/backgrounds/vertical/31.png');
    backgroundComponent = SpriteComponent()
      ..sprite = Sprite(bgImage)
      ..size = size
      ..position = Vector2.zero();
    add(backgroundComponent!);
  }

  Future<void> createCharacters() async {
    // Create hero and enemy using the helper method
    hero = await _createCharacter(
      type: "hero",
      idlePath: 'sprites/character/Shinobi/Idle.png',
      attackPath: 'sprites/character/Shinobi/Attack_1.png',
      position: Vector2(100, size.y - 300),
      isFlipped: false,
    );

    enemy = await _createCharacter(
      type: "enemy",
      idlePath: 'sprites/character/Fighter/Idle.png',
      attackPath: 'sprites/character/Fighter/Attack_1.png',
      position: Vector2(size.x - 100, 180),
      isFlipped: true,
    );
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
    hero?.statusContainer?.nameText.text = state.player.name;
    enemy?.statusContainer?.nameText.text = state.enemy.name;
    hero?.statusContainer?.levelText.text = 'LEVEL ${state.player.level}';
    enemy?.statusContainer?.levelText.text = 'LEVEL ${state.enemy.level}';
    hero?.updateHealthInfo(
        state.player.currentHp, state.player.vitality, state.playerInitiative);
    enemy?.updateHealthInfo(
        state.enemy.currentHp, state.enemy.vitality, state.enemyInitiative);
  }

  // Generic method to handle animations with callbacks
  Future<void> _playCharacterAnimation(GameCharacter? character,
      {Function? onComplete}) async {
    if (character != null) {
      await character.playAttackAnimation(onComplete: onComplete);
    } else {
      // If character is null, still call the completion callback
      onComplete?.call();
    }
  }

  Future<void> playAttackAnimationForHero({Function? onComplete}) async {
    await _playCharacterAnimation(hero, onComplete: onComplete);
  }

  Future<void> playAttackAnimationForEnemy({Function? onComplete}) async {
    await _playCharacterAnimation(enemy, onComplete: onComplete);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update game logic through the bloc
    if (gameBloc != null) {
      gameBloc!.updateInitiative(dt);
    }
  }

  // Set the GameBloc instance
  void setGameBloc(GameBloc bloc) {
    gameBloc = bloc;
  }
}
