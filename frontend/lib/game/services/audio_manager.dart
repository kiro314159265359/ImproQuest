import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// AudioManager handles loading and playing sounds for the game
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  bool _backgroundMusicPlaying = false;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _musicVolume = 0.6; // 60% default
  double _sfxVolume = 0.4; // 40% default
  final String _bgmPath = 'music/bg.mp3';

  // Preference keys
  static const String _musicVolumeKey = 'music_volume';
  static const String _sfxVolumeKey = 'sfx_volume';

  // Dictionary mapping animation types to sound effects
  final Map<String, String> _soundEffects = {
    'Attack_1': 'sfx/sword_hit.mp3',
    'player_death': 'sfx/player_death.mp3',
    'enemy_death': 'sfx/enemy_death.mp3',
    'button_click': 'sfx/button_click.mp3',
  };

  /// Initialize audio resources
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Preload all sound effects
      for (final effect in _soundEffects.values) {
        await FlameAudio.audioCache.load(effect);
      }

      // Preload background music
      await FlameAudio.audioCache.load(_bgmPath);

      // Load saved volume settings
      await _loadVolumeSettings();

      _initialized = true;
      print('AudioManager initialized successfully');
    } catch (e) {
      print('Error initializing AudioManager: $e');
    }
  }

  /// Load saved volume settings from SharedPreferences
  Future<void> _loadVolumeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _musicVolume = prefs.getDouble(_musicVolumeKey) ?? 0.6;
      _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 0.4;
    } catch (e) {
      print('Error loading volume settings: $e');
    }
  }

  /// Save volume settings to SharedPreferences
  Future<void> _saveVolumeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_musicVolumeKey, _musicVolume);
      await prefs.setDouble(_sfxVolumeKey, _sfxVolume);
    } catch (e) {
      print('Error saving volume settings: $e');
    }
  }

  /// Set the music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    volume = volume.clamp(0.0, 1.0);
    _musicVolume = volume;

    // Update playing music if needed
    if (_backgroundMusicPlaying) {
      try {
        // Some implementations might not support changing volume while playing
        // Consider stopping and restarting the music with the new volume
        await FlameAudio.bgm.stop();
        await FlameAudio.bgm.play(_bgmPath, volume: _musicVolume);
      } catch (e) {
        print('Error updating music volume: $e');
      }
    }

    // Save the new setting
    await _saveVolumeSettings();
  }

  /// Set the sound effects volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    volume = volume.clamp(0.0, 1.0);
    _sfxVolume = volume;

    // No need to update currently playing sounds as they're one-shot
    // Just save the setting for future sounds
    await _saveVolumeSettings();
  }

  /// Play a sound effect by its key
  void playSfx(String soundKey) {
    if (!_initialized || !_soundEnabled) return;

    final effectPath = _soundEffects[soundKey];
    if (effectPath != null) {
      try {
        FlameAudio.play(effectPath, volume: _sfxVolume);
      } catch (e) {
        print('Error playing sound effect $soundKey: $e');
      }
    } else {
      print('Sound effect not found: $soundKey');
    }
  }

  /// Play a sound effect for an animation type
  void playAnimationSound(String animationType, {bool isPlayer = true}) {
    if (!_initialized || !_soundEnabled) return;

    if (animationType == 'Attack_1') {
      playSfx('Attack_1');
    }
  }

  /// Start playing background music
  void playBackgroundMusic() {
    if (!_initialized || !_musicEnabled || _backgroundMusicPlaying) return;

    try {
      FlameAudio.bgm.play(_bgmPath, volume: _musicVolume);
      _backgroundMusicPlaying = true;
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  /// Pause background music
  void pauseBackgroundMusic() {
    if (!_initialized || !_backgroundMusicPlaying) return;

    try {
      FlameAudio.bgm.pause();
      _backgroundMusicPlaying = false;
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  /// Resume background music
  void resumeBackgroundMusic() {
    if (!_initialized || _backgroundMusicPlaying || !_musicEnabled) return;

    try {
      FlameAudio.bgm.resume();
      _backgroundMusicPlaying = true;
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  /// Stop background music
  void stopBackgroundMusic() {
    if (!_initialized || !_backgroundMusicPlaying) return;

    try {
      FlameAudio.bgm.stop();
      _backgroundMusicPlaying = false;
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  /// Toggle sound effects on/off
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  /// Toggle background music on/off
  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      resumeBackgroundMusic();
    } else {
      pauseBackgroundMusic();
    }
  }

  /// Check if sound is enabled
  bool get isSoundEnabled => _soundEnabled;

  /// Check if music is enabled
  bool get isMusicEnabled => _musicEnabled;

  /// Get the current music volume (0-100)
  double getMusicVolume() {
    return _musicVolume * 100;
  }

  /// Get the current SFX volume (0-100)
  double getSfxVolume() {
    return _sfxVolume * 100;
  }
}
