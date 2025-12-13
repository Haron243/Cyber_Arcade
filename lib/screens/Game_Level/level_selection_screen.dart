// File: lib/screens/Game_Level/level_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/widgets/Home_Page/custom_glitch_text.dart';
import 'dart:ui'; // For BackdropFilter

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Reuse the animated background
          const CyberBackground(),

          // 2. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  const Center(
                    child: CustomGlitchText(text: 'SELECT MISSION'),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    'CHOOSE YOUR DIFFICULTY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: Colors.cyanAccent.withOpacity(0.7),
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),

                  const Spacer(),

                  // Level 1 Card
                  _buildLevelCard(
                    context,
                    title: "LEVEL 01",
                    subtitle: "ROOKIE // BASIC DETECTION",
                    description: "Learn to spot basic phishing links and fake websites.",
                    color: Colors.greenAccent,
                    icon: Icons.shield_outlined,
                    route: '/gameLevelOne',
                  ),

                  const SizedBox(height: 30),

                  // Level 2 Card
                  _buildLevelCard(
                    context,
                    title: "LEVEL 02",
                    subtitle: "EXPERT // SOCIAL ENGINEERING",
                    description: "Face advanced attacks: Smishing, Urgency, and Spoofing.",
                    color: const Color(0xFFF92444), // Cyber Red
                    icon: Icons.warning_amber_rounded,
                    route: '/gameLevelTwo',
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required IconData icon,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border.all(color: color.withOpacity(0.6), width: 1.5),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 20),
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}