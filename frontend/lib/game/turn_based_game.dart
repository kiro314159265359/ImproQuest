import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter_application_2/core/theme/text_style.dart';
import '../core/theme/color_manger.dart';
import 'components/simple_progress_bar.dart';
import 'components/status_container.dart';
import 'logic/game_state.dart';
import 'logic/game_bloc.dart';
import 'services/asset_manager.dart';
import 'services/audio_manager.dart';

// Custom game character component with visibility control and animations
class GameCharacter extends SpriteAnimationComponent with HasGameRef {
  final String characterType; // "hero" or "enemy"
  final String idlePath;
  final String attackPath;
  bool isFlipped;
  StatusContainer? statusContainer;
  // Store animation references for reuse
  SpriteAnimation? _attackAnimation;
  SpriteAnimation? _deathAnimation;

  // Track animation state to avoid unnecessary updates
  bool _isAttacking = false;
  bool _isDying = false;
  int _lastCurrentHp = -1;
  int _lastMaxHp = -1;
  double _lastInitiative = -1;

  // Path for death animation
  String get deathPath =>
      'sprites/character/${characterType == "hero" ? "Shinobi" : "Fighter"}/Dead.png';

  // Get the appropriate death animation frame count based on character type
  int get deathFrameCount => characterType == "hero" ? 4 : 3;

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

    final assetManager = AssetManager();
    // Get cached animations instead of loading new ones
    animation = assetManager.getAnimation(idlePath);

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
        textRenderer: TextPaint(style: TextStyles.regular14primary),
      ),
      levelText: TextComponent(
        text: 'LEVEL 25',
        textRenderer: TextPaint(style: TextStyles.regular12White),
      ),
      hpLabelText: TextComponent(
        text: 'HP',
        textRenderer: TextPaint(style: TextStyles.regular12White),
      ),
      hpValueText: TextComponent(
        text: '100/100',
        textRenderer: TextPaint(style: TextStyles.regular12White),
      ),
      hpBar: SimpleProgressBar(
        progress: 1.0,
        size: Vector2(180, 8),
        position: Vector2(10, 25),
        foregroundColor: ColorManager.greenColor,
        backgroundColor: ColorManager.redColor,
      ),
      initLabelText: TextComponent(
        text: 'INIT',
        textRenderer: TextPaint(style: TextStyles.regular12White),
      ),
      initValueText: TextComponent(
        text: '0/100',
        textRenderer: TextPaint(style: TextStyles.regular12White),
      ),
      initBar: SimpleProgressBar(
        progress: 0.0,
        size: Vector2(180, 8),
        foregroundColor: ColorManager.blueColor,
        backgroundColor: ColorManager.greyColor,
      ),
    );
  }

  Future<void> playAttackAnimation({Function? onComplete}) async {
    if (_isAttacking) return;
    _isAttacking = true;

    final originalAnimation = animation;
    final assetManager = AssetManager();
    final audioManager = AudioManager();

    // Play attack sound - true for hero, false for enemy
    audioManager.playAnimationSound('Attack_1',
        isPlayer: characterType == "hero");

    // Get the attack animation from cache if already loaded
    _attackAnimation ??= assetManager.getAnimation(attackPath,
        frames: 4, stepTime: 0.1, loop: false);

    // Switch to attack animation
    animation = _attackAnimation;

    // Wait for animation to complete
    await animationTicker?.completed;

    // Restore original animation
    animation = originalAnimation;
    _isAttacking = false;

    // Execute callback if provided
    onComplete?.call();
  }

  Future<void> playDeathAnimation({Function? onComplete}) async {
    if (_isDying) return;
    _isDying = true;

    final assetManager = AssetManager();

    // Get the death animation from cache or load it
    try {
      _deathAnimation ??= assetManager.getAnimation(
        deathPath,
        frames: deathFrameCount, // Use the correct frame count
        stepTime: 0.1,
        loop: false,
      );

      // Switch to death animation
      animation = _deathAnimation;

      // Wait for animation to complete
      await animationTicker?.completed;

      // Execute callback if provided
      onComplete?.call();
    } catch (e) {
      print('Failed to play death animation: $e');
      // Still call the completion callback even if animation fails
      onComplete?.call();
    }
  }

  void updateHealthInfo(int currentHp, int maxHp, double playerInitiative) {
    // Skip update if values haven't changed
    if (currentHp == _lastCurrentHp &&
        maxHp == _lastMaxHp &&
        playerInitiative == _lastInitiative) {
      return;
    }

    if (statusContainer != null) {
      final healthProgress = currentHp / maxHp;
      const double initiativeThreshold = 100.0;
      double playerInitiativeProgress = playerInitiative / initiativeThreshold;

      // Batch UI updates
      statusContainer!.hpBar.progress = healthProgress;
      statusContainer!.hpValueText.text = '$currentHp/$maxHp';
      statusContainer!.initBar.progress = playerInitiativeProgress;
      statusContainer!.initValueText.text =
          '${(playerInitiativeProgress * 100).toInt()}/100';

      // Single update call for both bars
      statusContainer!.hpBar.update(0);
      statusContainer!.initBar.update(0);

      // Store values to avoid redundant updates
      _lastCurrentHp = currentHp;
      _lastMaxHp = maxHp;
      _lastInitiative = playerInitiative;
    }
  }
}

class TurnBasedGame extends FlameGame {
  GameCharacter? hero;
  GameCharacter? enemy;
  SpriteComponent? backgroundComponent;
  Function? onHeroAnimationComplete;
  Function? onEnemyAnimationComplete;
  GameBloc? gameBloc;

  // Cache game state to avoid redundant updates
  GameState? _lastState;

  // Add a completion callback for death animations
  Function? onDeathAnimationComplete;
  bool _deathAnimationPlaying = false;

  // Add a public getter for the private field
  bool get isDeathAnimationPlaying => _deathAnimationPlaying;

  void resetGameState() {
    _lastState = null;
  }

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
    // Initialize audio system
    final audioManager = AudioManager();
    await audioManager.initialize();

    // Don't start background music here automatically
    // It will be controlled by the GamePage based on game state

    // Set the game instance in AssetManager
    final assetManager = AssetManager();
    assetManager.setGame(this);
    await assetManager.initialize();

    await super.onLoad();
    await loadBackground();
    await createCharacters();
  }

  Future<void> loadBackground() async {
    final assetManager = AssetManager();
    backgroundComponent = SpriteComponent()
      ..sprite = assetManager.getSprite('sprites/backgrounds/vertical/31.png')
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
    // Skip if enemyObj is null
    if (enemyObj == null) {
      return;
    }

    // If enemy is dead (HP <= 0), let death animation play out but don't create a new enemy yet
    if (enemyObj.currentHp <= 0) {
      return;
    }

    // If current enemy exists and is the same as the previous enemy, just update stats
    if (enemy != null &&
        _lastState != null &&
        _lastState!.enemy.name == enemyObj.name) {
      // Just update stats - no need to recreate the sprite
      enemy!.updateHealthInfo(enemyObj.currentHp, enemyObj.vitality,
          _lastState?.enemyInitiative ?? 0);
      return;
    }

    // Otherwise, we need to remove the existing enemy (if any) and create a new one
    if (enemy != null) {
      enemy!.removeFromParent();
      if (enemy!.statusContainer != null) {
        enemy!.statusContainer!.removeFromParent();
      }
      enemy = null;
    }
    _createNewEnemy(enemyObj);
  }

  void _createNewEnemy(dynamic enemyObj) {
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
      position: Vector2(size.x - 100, 180),
      isFlipped: true,
    );
    add(enemy!);
  }

  void updateBars(GameState state) {
    // Check if player died and play death animation
    if (_lastState != null &&
        _lastState!.player.currentHp > 0 &&
        state.player.currentHp <= 0) {
      _playDeathAnimation(hero, isPlayer: true);
    }

    // Check if enemy died and play death animation
    if (_lastState != null &&
        _lastState!.enemy.currentHp > 0 &&
        state.enemy.currentHp <= 0) {
      _playDeathAnimation(enemy, isPlayer: false);
    }

    // Skip updates if state hasn't changed meaningfully
    if (_lastState != null &&
        _lastState!.player.currentHp == state.player.currentHp &&
        _lastState!.enemy.currentHp == state.enemy.currentHp &&
        _lastState!.playerInitiative == state.playerInitiative &&
        _lastState!.enemyInitiative == state.enemyInitiative) {
      return;
    }

    // Batch UI updates
    hero?.statusContainer?.nameText.text = state.player.name;
    enemy?.statusContainer?.nameText.text = state.enemy.name;
    hero?.statusContainer?.levelText.text = 'LEVEL ${state.player.level}';
    enemy?.statusContainer?.levelText.text = 'LEVEL ${state.enemy.level}';

    // Update health bars
    hero?.updateHealthInfo(
        state.player.currentHp, state.player.vitality, state.playerInitiative);
    enemy?.updateHealthInfo(
        state.enemy.currentHp, state.enemy.vitality, state.enemyInitiative);

    // Cache the state to avoid redundant updates
    _lastState = state;
  }

  // New method to handle death animations with completion callback
  void _playDeathAnimation(GameCharacter? character, {required bool isPlayer}) {
    if (character == null || _deathAnimationPlaying) return;

    print('Starting death animation for ${isPlayer ? "player" : "enemy"}');
    _deathAnimationPlaying = true;

    // Make sure we use the right animation
    character.playDeathAnimation(onComplete: () {
      print('Death animation completed for ${isPlayer ? "player" : "enemy"}');
      _deathAnimationPlaying = false;

      // Make sure we call the callback on the next frame to avoid state conflicts
      Future.microtask(() {
        if (onDeathAnimationComplete != null) {
          print('Calling onDeathAnimationComplete callback');
          onDeathAnimationComplete!();
        }
      });
    });
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

    // Update game logic on every frame
    if (gameBloc != null) {
      gameBloc!.updateInitiative(dt);
    }
  }

  // Set the GameBloc instance
  void setGameBloc(GameBloc bloc) {
    gameBloc = bloc;
  }
}
