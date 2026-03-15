import 'package:flutter/material.dart';
import 'package:demo_app/services/audio_service.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "SYSTEM SETTINGS",
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const CyberBackground(), // Keeps your cohesive styling
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AUDIO INTERFACE",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: Colors.white54,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.music_note, color: Colors.cyanAccent),
                    title: const Text(
                      "Background Music",
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      "Toggle arcade soundtrack",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: ValueListenableBuilder<bool>(
                      // Listens directly to the AudioService
                      valueListenable: AudioService().isMuted,
                      builder: (context, isMuted, child) {
                        return Switch(
                          value: !isMuted, // If NOT muted, switch is ON
                          onChanged: (value) {
                            AudioService().toggleMute();
                          },
                          activeColor: Colors.cyanAccent,
                          activeTrackColor: Colors.cyanAccent.withOpacity(0.4),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.withOpacity(0.3),
                        );
                      },
                    ),
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