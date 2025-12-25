import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/custom_glitch_text.dart';
import 'package:demo_app/services/user_progress_service.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  bool _isLoading = true;
  
  // Lock Status
  bool _isLevel2Locked = true;
  bool _isLevel3Locked = true;
  
  // XP Tracking
  int _level1XP = 0;
  int _level2XP = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final service = UserProgressService();
    
    // Check locks
    bool lvl2Open = await service.isLevelUnlocked(2);
    bool lvl3Open = await service.isLevelUnlocked(3);
    
    // Get Scores
    int xp1 = await service.getLevelXP(1);
    int xp2 = await service.getLevelXP(2);

    if (mounted) {
      setState(() {
        _isLevel2Locked = !lvl2Open;
        _isLevel3Locked = !lvl3Open;
        _level1XP = xp1;
        _level2XP = xp2;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background (Fixed)
          const CyberBackground(),

          // 2. Content (Scrollable)
          SafeArea(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  children: [
                    // --- HEADER SECTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        // Small aesthetic placeholder or profile icon could go here
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    const Center(child: CustomGlitchText(text: 'SELECT MISSION')),
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

                    const SizedBox(height: 30), // Replaces Spacer for safety

                    // --- LEVEL CARDS SECTION ---

                    // LEVEL 1
                    _buildLevelCard(
                      context,
                      title: "LEVEL 01",
                      subtitle: "ROOKIE // BASIC DETECTION",
                      description: "XP: $_level1XP / ${UserProgressService.levelOneThreshold} needed",
                      color: Colors.greenAccent,
                      icon: Icons.shield_outlined,
                      route: '/gameLevelOne',
                      isLocked: false,
                    ),

                    const SizedBox(height: 20),

                    // LEVEL 2
                    _buildLevelCard(
                      context,
                      title: "LEVEL 02",
                      subtitle: "EXPERT // SOCIAL ENG.",
                      description: "XP: $_level2XP / 600 needed",
                      color: const Color(0xFFF92444),
                      icon: Icons.warning_amber_rounded,
                      route: '/gameLevelTwo',
                      isLocked: _isLevel2Locked,
                      xpRequired: UserProgressService.levelOneThreshold,
                    ),

                    const SizedBox(height: 20),

                    // LEVEL 3
                    _buildLevelCard(
                      context,
                      title: "LEVEL 03",
                      subtitle: "MASTER // VISHING DEFENSE",
                      description: "Audio analysis required. Identify scam calls.",
                      color: Colors.purpleAccent,
                      icon: Icons.record_voice_over,
                      route: '/gameLevelThree',
                      isLocked: _isLevel3Locked, 
                      xpRequired: 600, 
                    ),

                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required IconData icon,
    required String route,
    required bool isLocked,
    int xpRequired = 0,
  }) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showLockedDialog(context, xpRequired);
        } else {
          Navigator.pushNamed(context, route).then((_) => _loadProgress());
        }
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(
                    color: isLocked ? Colors.grey.withOpacity(0.3) : color.withOpacity(0.6),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey.withOpacity(0.1) : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLocked ? Colors.grey.withOpacity(0.3) : color.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(icon, color: isLocked ? Colors.grey : color, size: 30),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              color: isLocked ? Colors.grey : color,
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
                  ],
                ),
              ),
            ),
          ),
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 40),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLockedDialog(BuildContext context, int requiredXP) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('ACCESS DENIED', style: TextStyle(fontFamily: 'Orbitron', color: Colors.redAccent)),
        content: Text('You need $requiredXP XP in the previous level to unlock this mission.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ACKNOWLEDGED', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }
}