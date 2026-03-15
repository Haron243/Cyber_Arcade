import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/data/level_one_data.dart'; 
import 'package:demo_app/services/user_progress_service.dart'; 
import 'package:demo_app/screens/Game_Level/cutscene_screen.dart';
import 'package:demo_app/services/audio_service.dart';

class GameLevelOneScreen extends StatefulWidget {
  const GameLevelOneScreen({super.key});

  @override
  State<GameLevelOneScreen> createState() => _GameLevelOneScreenState();
}

class _GameLevelOneScreenState extends State<GameLevelOneScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool? _lastGuessCorrect; // null = neutral, true = correct, false = wrong

  // --- ADDED: Trigger cutscene on load ---
  @override
  void initState() {
    super.initState();
    
    // Wait for the game screen to build its first frame, then push the cutscene over it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCutscene();
    });
  }

  // --- ADDED: Cutscene routing logic ---
  void _showCutscene() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // Keeps the transition smooth and the route transparent
        pageBuilder: (context, animation, secondaryAnimation) => const CutsceneScreen(levelId: 1),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // A cinematic fade-in / fade-out transition
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      // The cutscene finished fading out. 
      // (If we had a game timer, we would start it here. For Level 1, we just let them play!)
    });
  }

  void _handleGuess(bool userSaysLegit) {
    final isActuallyLegit = !levelOneData[_currentIndex].isPhishing;
    final isCorrect = (userSaysLegit == isActuallyLegit);

    setState(() {
      _lastGuessCorrect = isCorrect;
      if (isCorrect) _score += 100;
    });
  }

  void _nextCard() async {
    if (_currentIndex < levelOneData.length - 1) {
      setState(() {
        _currentIndex++;
        _lastGuessCorrect = null; // Reset for the next question
      });
    } else {
      await _finishLevel();
    }
  }

  Future<void> _finishLevel() async {
    final service = UserProgressService();
    await service.saveLevelProgress(1, _score);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.cyanAccent),
            ),
            title: const Text(
              "MISSION COMPLETE",
              style: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Final Score", style: TextStyle(color: Colors.white70)),
                Text(
                  "$_score",
                  style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 40,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  AudioService().resumeBGM();
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit level
                },
                child: const Text("CONTINUE", style: TextStyle(color: Colors.cyanAccent)),
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = levelOneData[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Layer
          Positioned.fill(
            child: Image.asset(
              'assets/images/game_background.png',
              fit: BoxFit.cover, // Ensures the background scales perfectly
            ),
          ),

          // 2. UI Layer
          SafeArea(
            child: Column(
              children: [
                // --- Top Bar HUD ---
                _buildTopBar(context),

                // --- Centered Game Card ---
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width > 600 
                            ? 450 // Max width for tablets/desktop
                            : MediaQuery.of(context).size.width * 0.9, 
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(scale: animation, child: child),
                            );
                          },
                          child: _lastGuessCorrect == null
                              ? _buildQuestionCard(currentCard)
                              : _buildFeedbackCard(currentCard),
                        ),
                      ),
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

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.6),
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // HUD Pills
          Row(
            children: [
              // Progress Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  "${_currentIndex + 1} / ${levelOneData.length}",
                  style: const TextStyle(
                    fontFamily: 'Orbitron', 
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Score Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.6), width: 1.5),
                ),
                child: Text(
                  "SCORE: $_score",
                  style: const TextStyle(
                      fontFamily: 'Orbitron',
                      color: Colors.cyanAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(WebsiteCard card) {
    return Container(
      key: const ValueKey('question'),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4), 
            blurRadius: 30, 
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          const Text(
            "IS THIS URL SAFE?",
            style: TextStyle(
              fontFamily: 'Orbitron', 
              color: Colors.black87, 
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    card.url,
                    style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _gameButton("LEGIT", const Color(0xFF4CAF50), () => _handleGuess(true)), // Material Green
              _gameButton("SCAM", const Color(0xFFF44336), () => _handleGuess(false)), // Material Red
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(WebsiteCard card) {
    final bool isSuccess = _lastGuessCorrect!;
    final Color statusColor = isSuccess ? Colors.greenAccent : Colors.redAccent;

    return Container(
      key: const ValueKey('feedback'),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2), 
            blurRadius: 30, 
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 70,
            color: statusColor,
          ),
          const SizedBox(height: 15),
          Text(
            isSuccess ? "CORRECT!" : "WRONG!",
            style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 26,
                color: statusColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Text(
            card.reasoning,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9), 
              height: 1.5, 
              fontSize: 15
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _nextCard,
              child: const Text(
                "NEXT", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _gameButton(String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Orbitron', 
              color: Colors.white, 
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              letterSpacing: 1
            )
          ),
        ),
      ),
    );
  }
}