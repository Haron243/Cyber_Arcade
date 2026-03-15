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
  bool _isLevel4Locked = true;
  bool _isLevel5Locked = true;
  bool _isLevel6Locked = true;
  bool _isLevel7Locked = true;
  bool _isLevel8Locked = true;
  
  // XP Tracking
  int _level1XP = 0;
  int _level2XP = 0;

  // to show level progress needed to unlock future levels
  // int _level3XP = 0;
  // int _level4XP = 0;
  // int _level5XP = 0;
  // int _level6XP = 0;
  // int _level7XP = 0;
  // int _level8XP = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final service = UserProgressService();
    
    // FIRE ALL ASYNC CALLS IN PARALLEL!
    // This executes all 9 database/storage reads at the exact same time.
    final results = await Future.wait([
      service.isLevelUnlocked(2), // index 0
      service.isLevelUnlocked(3), // index 1
      service.isLevelUnlocked(4), // index 2
      service.isLevelUnlocked(5), // index 3
      service.isLevelUnlocked(6), // index 4
      service.isLevelUnlocked(7), // index 5
      service.isLevelUnlocked(8), // index 6
      
      // To get completed level exp
      service.getLevelXP(1),      // index 7
      service.getLevelXP(2),      // index 8
    ]);

    // Safety guard: Don't update UI if the user closed the screen while loading
    if (!mounted) return;

    setState(() {
      // Extract the results based on their index in the array above
      _isLevel2Locked = !(results[0] as bool);
      _isLevel3Locked = !(results[1] as bool);
      _isLevel4Locked = !(results[2] as bool);
      _isLevel5Locked = !(results[3] as bool);
      _isLevel6Locked = !(results[4] as bool);
      _isLevel7Locked = !(results[5] as bool);
      _isLevel8Locked = !(results[6] as bool);
      
      _level1XP = results[7] as int;
      _level2XP = results[8] as int;

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background (Fixed)
          const RepaintBoundary(
            child: CyberBackground(),
          ),

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

                    const SizedBox(height: 20),

                    // LEVEL 4
                  _buildLevelCard(
                    context,
                    title: "LEVEL 04",
                    subtitle: "SHADOW WI-FI // NETWORK SECURITY",
                    description: "Identify Evil Twin access points in public spaces.",
                    color: Colors.blueAccent,
                    icon: Icons.wifi_lock,
                    route: '/gameLevelFour',
                    isLocked: _isLevel4Locked,
                    xpRequired: 800,
                  ),

                    const SizedBox(height: 20),

                    // LEVEL 5
                  _buildLevelCard(
                    context,
                    title: "LEVEL 05",
                    subtitle: "QUISHING // QR FORENSICS",
                    description: "Analyze embedded QR URLs for hidden redirects.",
                    color: Colors.cyanAccent,
                    icon: Icons.qr_code_scanner,
                    route: '/gameLevelFive',
                    isLocked: _isLevel5Locked,
                    xpRequired: 200,
                  ),

                  const SizedBox(height: 20),

                    // LEVEL 6

                  _buildLevelCard(
                    context,
                    title: "LEVEL 06",
                    subtitle: "FOLLOW THE MONEY // PAYMENT TRACING",
                    description: "Map the flow of funds to detect unauthorized redirects.",
                    color: Colors.orangeAccent,
                    icon: Icons.account_tree, // Represents the node/network path
                    route: '/gameLevelSix',
                    isLocked: _isLevel6Locked,
                    xpRequired: 500, 
                  ),

                  const SizedBox(height: 20),

                    // LEVEL 7

                  _buildLevelCard(
                    context,
                    title: "LEVEL 07",
                    subtitle: "APP ANALYSIS // MALWARE DETECTION",
                    description: "Reverse-engineer a suspicious app to identify hidden malicious behaviors.",
                    color: const Color.fromARGB(255, 255, 230, 64),
                    icon: Icons.adb_outlined, // Represents the node/network path
                    route: '/gameLevelSeven',
                    isLocked: _isLevel7Locked,
                    xpRequired: 500, 
                  ),

                  const SizedBox(height: 20),

                  // LEVEL 8
                  _buildLevelCard(
                    context,
                    title: "LEVEL 08",
                    subtitle: "THE ECHO ROOM // DIGITAL LITERACY",
                    description: "Manage the spread of unverified information in a live chat simulation.",
                    color: Colors.pinkAccent,
                    icon: Icons.forum_outlined,
                    route: '/gameLevelEight',
                    isLocked: _isLevel8Locked,
                    xpRequired: 50, 
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
          // REMOVED ClipRRect and BackdropFilter here
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8), // Increased opacity to 0.8 to compensate for no blur
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