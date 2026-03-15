import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CyberAudioPlayer extends StatefulWidget {
  final String assetPath;
  final bool autoPlay;

  const CyberAudioPlayer({
    super.key,
    required this.assetPath,
    this.autoPlay = false,
  });

  @override
  State<CyberAudioPlayer> createState() => _CyberAudioPlayerState();
}

class _CyberAudioPlayerState extends State<CyberAudioPlayer> {
  late AudioPlayer _player;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // Listen to state changes (playing, paused, stopped)
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });

    // Listen to audio duration (total length)
    _player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });

    // Listen to current playback position
    _player.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });

    // Setup the file
    _player.setSource(AssetSource(widget.assetPath));
  }

  @override
  void dispose() {
    _player.dispose(); // meaningful cleanup
    super.dispose();
  }

  void _togglePlay() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withOpacity(0.2),
                border: Border.all(color: Colors.cyanAccent),
              ),
              child: Icon(
                _playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow,
                color: Colors.cyanAccent,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // Slider and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.cyanAccent,
                    inactiveTrackColor: Colors.grey[800],
                    thumbColor: Colors.white,
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _player.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Orbitron'),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Orbitron'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}