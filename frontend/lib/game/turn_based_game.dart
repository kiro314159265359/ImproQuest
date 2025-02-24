// lib/game/turn_based_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'components/simple_progress_bar.dart';
import 'components/status_container.dart';
import 'logic/game_state.dart';

class TurnBasedGame extends FlameGame {
  SpriteAnimationComponent? heroAnimationComponent;
  SpriteAnimationComponent? enemyAnimationComponent;
  SpriteComponent? backgroundComponent;
  StatusContainer? playerStatusContainer;
  StatusContainer? enemyStatusContainer;

  // Progress bar components:
  SimpleProgressBar? playerHealthBar;
  SimpleProgressBar? playerInitiativeBar;
  SimpleProgressBar? enemyHealthBar;
  SimpleProgressBar? enemyInitiativeBar;

  final Random _random = Random();

  // For convenience, define the size of the bars.
  final Vector2 barSizeHealth = Vector2(100, 10);
  final Vector2 barSizeInitiative = Vector2(100, 5);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 1. Load the background image.
    final bgImage = await images.load('sprites/backgrounds/vertical/31.png');
    backgroundComponent = SpriteComponent()
      ..sprite = Sprite(bgImage)
      ..size = size
      ..position = Vector2.zero();
    add(backgroundComponent as Component);

    // 2. Load hero sprite sheet.
    final heroImage = await images.load('sprites/character/Shinobi/Idle.png');
    final heroSheet = SpriteSheet(
      image: heroImage,
      srcSize: Vector2(128, 128),
    );
    final heroAnimation = heroSheet.createAnimation(
      row: 0,
      stepTime: 0.2,
      to: 6,
    );
    heroAnimationComponent = SpriteAnimationComponent(
      animation: heroAnimation,
      size: Vector2(256, 256),
      position: Vector2(0, size.y - 300),
    );
    add(heroAnimationComponent!);

    // 3. Load an initial enemy sprite.
    await updateEnemy(null);

    // 4. Add progress bars for the player.
    // Health bar above hero (e.g., 20 pixels above the sprite).
    playerHealthBar = SimpleProgressBar(
      progress: 1.0,
      size: barSizeHealth,
      position: heroAnimationComponent!.position + Vector2(75, 50),
      foregroundColor: Colors.green,
      backgroundColor: Colors.red,
    );
    add(playerHealthBar!);

    // Initiative bar just above the health bar.

    playerStatusContainer = StatusContainer(
      position: heroAnimationComponent!.position + Vector2(75, -50),
      size: Vector2(150, 50),
      progressBar: SimpleProgressBar(
        progress: 1.0,
        size: Vector2(100, 10),
        position: Vector2(10, 25), // relative inside container
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
    add(playerStatusContainer!);

    // Create a status container for the enemy
    enemyStatusContainer = StatusContainer(
      position: enemyAnimationComponent!.position + Vector2(-200, 50),
      size: Vector2(150, 50),
      progressBar: SimpleProgressBar(
        progress: 1.0,
        size: Vector2(100, 10),
        position: Vector2(10, 25),
        foregroundColor: Colors.green,
        backgroundColor: Colors.red,
      ),
      hpText: TextComponent(
        text: 'HP: 50/50',
        position: Vector2(10, 5),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
    add(enemyStatusContainer!);
    // playerInitiativeBar = SimpleProgressBar(
    //   progress: 0.0,
    //   size: barSizeInitiative,
    //   position: heroAnimationComponent!.position + Vector2(75, 65),
    //   foregroundColor: Colors.blue,
    //   backgroundColor: Colors.grey,
    // );
    // add(playerInitiativeBar!);
    //
    // // 5. Add progress bars for the enemy.
    // // Health bar above enemy sprite.
    // enemyHealthBar = SimpleProgressBar(
    //   progress: 1.0,
    //   size: barSizeHealth,
    //   position: enemyAnimationComponent!.position + Vector2(-175, 50),
    //   foregroundColor: Colors.green,
    //   backgroundColor: Colors.red,
    // );
    // add(enemyHealthBar!);
    //
    // // Initiative bar above the enemy health bar.
    // enemyInitiativeBar = SimpleProgressBar(
    //   progress: 0.0,
    //   size: barSizeInitiative,
    //   position: enemyAnimationComponent!.position + Vector2(-175, 65),
    //   foregroundColor: Colors.blue,
    //   backgroundColor: Colors.grey,
    // );
    // add(enemyInitiativeBar!);
  }

  /// Updates the enemy sprite based on whether the enemy is a boss or not.
  Future<void> updateEnemy(dynamic enemyObj) async {
    // Remove the old enemy sprite if present.
    if (enemyAnimationComponent != null) {
      enemyAnimationComponent!.removeFromParent();
    }
    String enemyAsset =
        'sprites/character/Fighter/Idle.png'; // default asset for normal enemy
    if (enemyObj != null) {
      bool isBoss = enemyObj.isBoss;
      enemyAsset = isBoss
          ? 'sprites/character/Fighter/Idle.png'
          : 'sprites/character/Fighter/Idle.png';
    }
    final enemyImage = await images.load(enemyAsset);
    final enemySheet = SpriteSheet(
      image: enemyImage,
      srcSize: Vector2(128, 128),
    );
    // Choose a random row (if applicable).
    int row = _random.nextInt(1);
    final enemyAnimation = enemySheet.createAnimation(
      row: row,
      stepTime: 0.2,
      to: 6,
    );
    enemyAnimationComponent = SpriteAnimationComponent(
      animation: enemyAnimation,
      size: Vector2(256, 256),
      position: Vector2(size.x - 250, 0),
    )..flipHorizontallyAroundCenter();
    add(enemyAnimationComponent!);

    // Also update the enemy progress bars' positions relative to the new enemy sprite.
    enemyHealthBar?.position =
        enemyAnimationComponent!.position - Vector2(0, 20);
    enemyInitiativeBar?.position =
        enemyAnimationComponent!.position - Vector2(0, 35);
  }

  void updateBars(GameState state) {
    if (playerStatusContainer == null || enemyStatusContainer == null) {
      return;
    }
    // Calculate progress for health bars.
    double playerHealthProgress =
        state.player.currentHp / state.player.vitality;
    double enemyHealthProgress = state.enemy.currentHp / state.enemy.vitality;

    // Update the progress bars.
    playerStatusContainer!.progressBar.progress = playerHealthProgress;
    enemyStatusContainer!.progressBar.progress = enemyHealthProgress;

    // Update the HP text.
    playerStatusContainer!.hpText.text =
        'HP: ${state.player.currentHp}/${state.player.vitality}';
    enemyStatusContainer!.hpText.text =
        'HP: ${state.enemy.currentHp}/${state.enemy.vitality}';

    // Force a refresh by calling update(0) on children if needed.
    playerStatusContainer!.progressBar.update(0);
    enemyStatusContainer!.progressBar.update(0);
  }

  /// Call this method from the UI with the latest BLoC state to update the bars.
  // void updateBars(GameState state) {
  //   if (playerHealthBar == null ||
  //       playerInitiativeBar == null ||
  //       enemyHealthBar == null ||
  //       enemyInitiativeBar == null) {
  //     return;
  //   }
  //   double playerHealthProgress =
  //       state.player.currentHp / state.player.vitality;
  //   double enemyHealthProgress = state.enemy.currentHp / state.enemy.vitality;
  //   const double initiativeThreshold = 100.0;
  //   double playerInitiativeProgress =
  //       state.playerInitiative / initiativeThreshold;
  //   double enemyInitiativeProgress =
  //       state.enemyInitiative / initiativeThreshold;
  //
  //   playerHealthBar!.progress = playerHealthProgress;
  //   playerInitiativeBar!.progress = playerInitiativeProgress;
  //   enemyHealthBar!.progress = enemyHealthProgress;
  //   enemyInitiativeBar!.progress = enemyInitiativeProgress;
  //
  //   // Force refresh of progress bars
  //   playerHealthBar?.update(0);
  //   playerInitiativeBar?.update(0);
  //   enemyHealthBar?.update(0);
  //   enemyInitiativeBar?.update(0);
  // }
}
