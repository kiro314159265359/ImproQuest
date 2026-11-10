import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

/// AssetManager handles preloading and caching of game assets
class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  final Map<String, SpriteAnimation> _animationCache = {};
  final Map<String, Sprite> _spriteCache = {};
  bool _isInitialized = false;
  FlameGame? _game;

  void setGame(FlameGame game) {
    _game = game;
  }

  Future<void> initialize() async {
    if (_isInitialized || _game == null) return;

    // Preload background
    await _loadSprite('sprites/backgrounds/vertical/31.png');

    // Preload character animations
    await _preloadCharacterAnimations('Shinobi');
    await _preloadCharacterAnimations('Fighter');

    _isInitialized = true;
  }

  Future<void> _preloadCharacterAnimations(String characterType) async {
    // Idle animations loop by default
    await _loadAnimation('sprites/character/$characterType/Idle.png',
        frames: 6);

    // Attack animations should not loop
    await _loadAnimation('sprites/character/$characterType/Attack_1.png',
        frames: 4, loop: false);

    // Death animations should not loop - different frame counts for different characters
    int deathFrames = characterType == "Shinobi" ? 4 : 3;
    await _loadAnimation('sprites/character/$characterType/Dead.png',
        frames: deathFrames, stepTime: 0.1, loop: false);

    // Log that we've preloaded the death animation
    print(
        'Preloaded death animation for $characterType: sprites/character/$characterType/Dead.png');
  }

  Future<SpriteAnimation> _loadAnimation(
    String path, {
    int frames = 6,
    double stepTime = 0.1,
    bool loop = true,
  }) async {
    if (_game == null) throw Exception('Game not set in AssetManager');

    final cacheKey = '$path-$frames-$stepTime-$loop';
    if (_animationCache.containsKey(cacheKey)) {
      return _animationCache[cacheKey]!;
    }

    // Add logging to help with debugging
    print('Loading animation: $cacheKey');

    final image = await _game!.images.load(path);
    final sheet = SpriteSheet(image: image, srcSize: Vector2(128, 128));
    final animation = sheet.createAnimation(
      row: 0,
      stepTime: stepTime,
      to: frames,
    )..loop = loop;

    _animationCache[cacheKey] = animation;
    return animation;
  }

  Future<Sprite> _loadSprite(String path) async {
    if (_game == null) throw Exception('Game not set in AssetManager');

    if (_spriteCache.containsKey(path)) {
      return _spriteCache[path]!;
    }

    final image = await _game!.images.load(path);
    final sprite = Sprite(image);
    _spriteCache[path] = sprite;
    return sprite;
  }

  SpriteAnimation getAnimation(
    String path, {
    int frames = 6,
    double stepTime = 0.1,
    bool loop = true,
  }) {
    final cacheKey = '$path-$frames-$stepTime-$loop';

    if (!_animationCache.containsKey(cacheKey)) {
      print('Animation cache miss: $cacheKey');
      print('Available animations: ${_animationCache.keys.join(', ')}');

      // Attempt to load the animation on-demand if not already cached
      try {
        // This will return the future, not the actual animation
        // For synchronous code, we should pre-cache all animations
        _loadAnimation(path, frames: frames, stepTime: stepTime, loop: loop);
      } catch (e) {
        print('Failed to load animation on-demand: $e');
      }
    }

    return _animationCache[cacheKey]!;
  }

  Sprite getSprite(String path) {
    if (!_spriteCache.containsKey(path)) {
      throw Exception('Sprite not preloaded: $path');
    }
    return _spriteCache[path]!;
  }
}
