import 'package:flutter/foundation.dart'; // Added for ValueNotifier
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  // A reactive variable that the UI can listen to!
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);

  Future<void> startBGM() async {
    await AudioPlayer.global.setAudioContext(AudioContextConfig(
      respectSilence: true,
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build());

    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Only play if not muted
    if (!isMuted.value) {
      await _bgmPlayer.play(AssetSource('audio/sfx/bgm.mp3'), volume: 0.4);
    }
  }

  Future<void> pauseBGM() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBGM() async {
    // Only resume if the user hasn't explicitly muted the game
    if (!isMuted.value && _bgmPlayer.state != PlayerState.playing) {
      await _bgmPlayer.resume();
    }
  }

  // ADDED: The master toggle method
  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    if (isMuted.value) {
      await _bgmPlayer.pause();
    } else {
      await _bgmPlayer.resume();
    }
  }
}