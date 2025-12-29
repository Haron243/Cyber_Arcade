import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/data/level_one_data.dart'; 
import 'package:demo_app/services/user_progress_service.dart'; 

class GameLevelOneScreen extends StatefulWidget {
  const GameLevelOneScreen({super.key});

  @override
  State<GameLevelOneScreen> createState() => _GameLevelOneScreenState();
}

class _GameLevelOneScreenState extends State<GameLevelOneScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool? _lastGuessCorrect; // null = neutral, true = happy, false = stressed

  // Logic to determine which character image to show
  String _getCharacterImage() {
    if (_lastGuessCorrect == null) return 'assets/images/character_neutral.png';
    return _lastGuessCorrect!
        ? 'assets/images/character_happy.png'
        : 'assets/images/character_stressed.png';
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
        _lastGuessCorrect = null; // Reset character
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
              side: const BorderSide(color: Colors.greenAccent),
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
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit level
                },
                child: const Text("CONTINUE", style: TextStyle(color: Colors.greenAccent)),
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
              fit: BoxFit.cover,
            ),
          ),

          // 2. Character Layer (Bottom Left)
          Positioned(
            bottom: 0,
            left: 0, // Align to left edge
            height: MediaQuery.of(context).size.height * 0.60, // 60% of screen height
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Image.asset(
                _getCharacterImage(),
                key: ValueKey(_lastGuessCorrect), // Animate changes
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 3. UI Layer (Scrollable to prevent overflow)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HUD ---
                  _buildHUD(),

                  const SizedBox(height: 20),

                  // Spacer replacement: Push content down slightly
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                  // --- Game Card ---
                  // Align to center-right so we don't block the character
                  Align(
                    alignment: Alignment.centerRight, 
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 600 
                          ? 400 // Max width for tablets
                          : MediaQuery.of(context).size.width * 0.9, 
                      
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: _lastGuessCorrect == null
                            ? _buildQuestionCard(currentCard)
                            : _buildFeedbackCard(currentCard),
                      ),
                    ),
                  ),

                  // Bottom padding to ensure scrolling clears the bottom
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
          
          // 4. Back Button (Top Left)
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
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

  Widget _buildHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Push HUD to right
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            "${_currentIndex + 1} / ${levelOneData.length}",
            style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
          ),
          child: Text(
            "SCORE: $_score",
            style: const TextStyle(
                fontFamily: 'Orbitron',
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(WebsiteCard card) {
    return Container(
      key: const ValueKey('question'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          const Text(
            "IS THIS URL SAFE?",
            style: TextStyle(fontFamily: 'Orbitron', color: Colors.black54, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, size: 16, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    card.url,
                    style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _gameButton("LEGIT", Colors.green, () => _handleGuess(true)),
              _gameButton("SCAM", Colors.red, () => _handleGuess(false)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(WebsiteCard card) {
    final bool isSuccess = _lastGuessCorrect!;
    final Color statusColor = isSuccess ? Colors.green : Colors.red;

    return Container(
      key: const ValueKey('feedback'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 60,
            color: statusColor,
          ),
          const SizedBox(height: 10),
          Text(
            isSuccess ? "CORRECT!" : "WRONG!",
            style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 24,
                color: statusColor,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Text(
            card.reasoning,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _nextCard,
              child: const Text("NEXT", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _gameButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text,
          style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white, fontSize: 14)),
    );
  }
}