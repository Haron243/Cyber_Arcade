import 'package:flutter/material.dart'; // Added for WidgetsBindingObserver
import 'package:audioplayers/audioplayers.dart';

// 1. ADD 'with WidgetsBindingObserver' to listen to app minimize/resume
class AudioService with WidgetsBindingObserver {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    // 2. Register this service to listen to the phone's lifecycle
    WidgetsBinding.instance.addObserver(this);
  }

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);
  
  // 3. Track if a level (like Level 3) intentionally paused the music
  bool _isLevelPaused = false;

  // 4. THIS FIRES AUTOMATICALLY WHEN THE APP IS MINIMIZED OR RESUMED
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      // App is minimized or a phone call came in -> Pause everything
      _bgmPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      // App is back on screen -> Resume ONLY if not muted and not in a silent level
      if (!isMuted.value && !_isLevelPaused) {
        _bgmPlayer.resume();
      }
    }
  }

  Future<void> startBGM() async {
    await AudioPlayer.global.setAudioContext(AudioContextConfig(
      respectSilence: true,
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build());

    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    
    if (!isMuted.value) {
      await _bgmPlayer.play(AssetSource('audio/sfx/bgm.mp3'), volume: 0.4);
    }
  }

  Future<void> pauseBGM() async {
    _isLevelPaused = true; // Mark that the game requested silence
    await _bgmPlayer.pause();
  }

  Future<void> resumeBGM() async {
    _isLevelPaused = false; // Remove the silence request
    if (!isMuted.value && _bgmPlayer.state != PlayerState.playing) {
      await _bgmPlayer.resume();
    }
  }

  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    if (isMuted.value) {
      await _bgmPlayer.pause();
    } else {
      // Only resume if a level isn't demanding silence right now
      if (!_isLevelPaused) {
        await _bgmPlayer.resume();
      }
    }
  }
}