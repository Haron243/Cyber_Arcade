// File: lib/screens/Game_Level/game_level_two_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/services/level_two_data.dart'; // Import the data file

class GameLevelTwoScreen extends StatefulWidget {
  const GameLevelTwoScreen({super.key});

  @override
  State<GameLevelTwoScreen> createState() => _GameLevelTwoScreenState();
}

class _GameLevelTwoScreenState extends State<GameLevelTwoScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool? _lastGuessCorrect;
  bool _showFeedback = false;

  void _handleGuess(bool userSaidPhishing) {
    final currentScenario = levelTwoData[_currentIndex];
    final isCorrect = currentScenario.isPhishing == userSaidPhishing;

    setState(() {
      _lastGuessCorrect = isCorrect;
      if (isCorrect) _score += 100;
      _showFeedback = true;
    });
  }

  void _nextScenario() {
    setState(() {
      _showFeedback = false;
      if (_currentIndex < levelTwoData.length - 1) {
        _currentIndex++;
      } else {
        // End of Level - Navigate back or show summary
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
    final scenario = levelTwoData[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          const CyberBackground(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                children: [
                  // --- Header: HUD ---
                  _buildHUD(),

                  const SizedBox(height: 20),

                  // --- Main Game Area ---
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showFeedback
                          ? _buildFeedbackView(scenario) // Show Result
                          : _buildScenarioCard(scenario), // Show Question
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Back Button
           Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Level Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(5),
            color: Colors.black54,
          ),
          child: Text(
            "LVL 02 // ${_currentIndex + 1}/${levelTwoData.length}",
            style: const TextStyle(
              fontFamily: 'Orbitron',
              color: Colors.cyanAccent,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ),
        // Score
        Text(
          "SCORE: $_score",
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Color(0xFFF92444),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [Shadow(color: Color(0xFFF92444), blurRadius: 10)],
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioCard(Scenario scenario) {
    bool isEmail = scenario.type == "Email";

    return Column(
      key: ValueKey(scenario.id),
      children: [
        // The "Device" Frame
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.9), // Dark Slate
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isEmail ? Colors.blueGrey : Colors.purpleAccent.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isEmail ? Colors.blue.withOpacity(0.1) : Colors.purple.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mock Browser/App Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEmail ? Icons.email_outlined : Icons.smartphone,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          scenario.urlOrSender,
                          style: const TextStyle(
                            fontFamily: 'Courier', // Monospaced for tech feel
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.title,
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          scenario.scenarioDescription,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Fake Action Button inside the email/sms
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              "VIEW DETAILS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Decision Buttons
        Row(
          children: [
            Expanded(
              child: _buildDecisionButton(
                "LEGIT",
                Colors.greenAccent,
                Icons.check_circle_outline,
                () => _handleGuess(false),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDecisionButton(
                "PHISHING",
                const Color(0xFFF92444), // Cyber Red
                Icons.warning_amber_rounded,
                () => _handleGuess(true),
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
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10)],
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackView(Scenario scenario) {
    bool isSuccess = _lastGuessCorrect!;
    Color statusColor = isSuccess ? Colors.greenAccent : const Color(0xFFF92444);

    return Container(
      key: const ValueKey('feedback'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 30)],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSuccess ? Icons.shield_outlined : Icons.gpp_bad_outlined,
            size: 80,
            color: statusColor,
          ),
          const SizedBox(height: 20),
          Text(
            isSuccess ? "THREAT NEUTRALIZED" : "SYSTEM COMPROMISED",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: statusColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            scenario.isPhishing ? "It was PHISHING." : "It was LEGITIMATE.",
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          const Divider(color: Colors.white24, height: 40),
          const Text(
            "ANALYSIS PROTOCOL:",
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
              height: 1.4,
            ),
          ),
          const Spacer(),
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
            border: Border.all(color: Colors.cyanAccent),
            boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "MISSION REPORT",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "FINAL SCORE: $_score",
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  color: Color(0xFFF92444),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              CyberButton(
                text: "RETURN TO BASE",
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to Home
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}