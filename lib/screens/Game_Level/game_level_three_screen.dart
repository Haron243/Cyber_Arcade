import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/widgets/Game_Level/cyber_audio_player.dart';
import 'package:demo_app/data/level_three_data.dart';
import 'package:demo_app/services/user_progress_service.dart';

class GameLevelThreeScreen extends StatefulWidget {
  const GameLevelThreeScreen({super.key});

  @override
  State<GameLevelThreeScreen> createState() => _GameLevelThreeScreenState();
}

class _GameLevelThreeScreenState extends State<GameLevelThreeScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool? _lastGuessCorrect;
  bool _showFeedback = false;

  void _handleGuess(bool userSaidScam) {
    final currentScenario = levelThreeData[_currentIndex];
    // Check if user's guess matches the actual nature of the call
    final isCorrect = currentScenario.isScam == userSaidScam;

    setState(() {
      _lastGuessCorrect = isCorrect;
      if (isCorrect) _score += 100;
      _showFeedback = true;
    });
  }

  void _nextScenario() {
    setState(() {
      _showFeedback = false;
      if (_currentIndex < levelThreeData.length - 1) {
        _currentIndex++;
      } else {
        _showSummaryDialog();
      }
    });
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSummaryDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = levelThreeData[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          const CyberBackground(),
          
          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Header (Score & Level)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: _buildHUD(),
                ),

                // Scrollable Game Area (Prevents overflow on small screens)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showFeedback
                          ? _buildFeedbackView(scenario) // Result Screen
                          : _buildCallInterface(scenario), // The "Call" Screen
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 3. Back Button
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
          ),
          child: Text(
            "LVL 03 // ${_currentIndex + 1}/${levelThreeData.length}",
            style: const TextStyle(
              fontFamily: 'Orbitron',
              color: Colors.purpleAccent,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "SCORE: $_score",
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCallInterface(AudioScenario scenario) {
    return Column(
      key: ValueKey(scenario.id),
      children: [
        // --- CALLER ID SECTION ---
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 20)
            ],
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF2D2D2D),
            child: Icon(Icons.person, size: 60, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          scenario.callerName,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          scenario.phoneNumber,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 16,
            color: Colors.white54,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
          ),
          child: const Text(
            "00:14 / CONNECTED",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 10,
              fontFamily: 'Orbitron',
            ),
          ),
        ),

        const SizedBox(height: 40),

        // --- AUDIO PLAYER ---
        // This is your custom widget
        CyberAudioPlayer(
          assetPath: scenario.audioAssetPath,
          autoPlay: false, 
        ),

        const SizedBox(height: 50),

        // --- DECISION BUTTONS ---
        Row(
          children: [
            Expanded(
              child: _buildDecisionButton(
                "LEGITIMATE",
                Colors.greenAccent,
                Icons.check_circle_outline,
                () => _handleGuess(false), // User says NOT scam
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDecisionButton(
                "SCAM CALL",
                const Color(0xFFF92444),
                Icons.warning_amber_rounded,
                () => _handleGuess(true), // User says SCAM
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDecisionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          border: Border.all(color: color.withOpacity(0.7), width: 2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 15)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackView(AudioScenario scenario) {
    bool isSuccess = _lastGuessCorrect!;
    Color statusColor = isSuccess ? Colors.greenAccent : const Color(0xFFF92444);

    return Container(
      key: const ValueKey('feedback'),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [BoxShadow(color: statusColor.withOpacity(0.2), blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.verified_user : Icons.error_outline,
            size: 60,
            color: statusColor,
          ),
          const SizedBox(height: 15),
          Text(
            isSuccess ? "ANALYSIS CORRECT" : "INCORRECT ANALYSIS",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: statusColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            scenario.isScam 
                ? "Target identified as VISHING (Voice Phishing)." 
                : "Target verified as LEGITIMATE caller.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          const Divider(color: Colors.white24, height: 40),
          const Text(
            "SECURITY INTEL:",
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: Colors.cyanAccent,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            scenario.educationalReasoning,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          CyberButton(
            text: "CONTINUE",
            onPressed: _nextScenario,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDialog() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purpleAccent),
            boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "OPERATION COMPLETE",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "FINAL SCORE: $_score",
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  color: Colors.purpleAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              CyberButton(
                text: "RETURN TO BASE",
                onPressed: () async {
                  // --- SAVE PROGRESS FOR LEVEL 3 ---
                  final service = UserProgressService();
                  await service.saveLevelProgress(3, _score);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to Hub
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}