// ===========================================================================
// lib/screens/Game_Level/cutscene_screen.dart
// ===========================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:demo_app/data/cutscene_data.dart';

class CutsceneScreen extends StatefulWidget {
  final int levelId;

  const CutsceneScreen({super.key, required this.levelId});

  @override
  State<CutsceneScreen> createState() => _CutsceneScreenState();
}

class _CutsceneScreenState extends State<CutsceneScreen> {
  int _currentIndex = 0;
  late List<DialogLine> _script;
  
  // Typewriter effect state
  String _displayedText = "";
  Timer? _typewriterTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Load the script for this level, or a fallback if not found
    _script = levelCutscenes[widget.levelId] ?? [
      DialogLine(
        speakerName: "SYSTEM ERROR", 
        text: "Mission briefing data corrupted. Proceed with caution.", 
        characterImagePath: poseNeutral,
      )
    ];
    
    // Start typing the first line
    _startTyping(_script[_currentIndex].text);
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  void _startTyping(String fullText) {
    _typewriterTimer?.cancel();
    _displayedText = "";
    _isTyping = true;
    int charIndex = 0;

    // Speed of the typewriter effect (milliseconds per character)
    const typingSpeed = Duration(milliseconds: 30);

    _typewriterTimer = Timer.periodic(typingSpeed, (timer) {
      if (charIndex < fullText.length) {
        setState(() {
          _displayedText += fullText[charIndex];
          charIndex++;
        });
      } else {
        setState(() {
          _isTyping = false;
        });
        timer.cancel();
      }
    });
  }

  void _handleTap() {
    if (_isTyping) {
      // If still typing, tapping skips the animation and shows full text instantly
      _typewriterTimer?.cancel();
      setState(() {
        _displayedText = _script[_currentIndex].text;
        _isTyping = false;
      });
    } else {
      // If done typing, move to the next line or finish the cutscene
      if (_currentIndex < _script.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _startTyping(_script[_currentIndex].text);
      } else {
        // Script is over, close the cutscene to reveal the game
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLine = _script[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black, 
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap, // Tap anywhere to advance or skip typing
        child: Stack(
          children: [
            // 1. SOLID BACKGROUND (Matches your mockup)
            Positioned.fill(
              child: Image.asset(
                'assets/images/cutscenes/Portrait_background.png', 
                fit: BoxFit.cover,
              ),
            ),
            
            // Optional: A slight dark gradient at the bottom so the text box pops out more
            Positioned(
              bottom: 0, left: 0, right: 0, height: 400,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            ),

            // 2. Character Sprite (Bottom Center)
            Positioned(
              bottom: 180, // Sits exactly on top of the dialogue box
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.55,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  currentLine.characterImagePath,
                  key: ValueKey(currentLine.characterImagePath),
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),

            // 3. Cyberpunk Dialogue Box (Bottom)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.95), // Deep cyber blue/black
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.15), 
                      blurRadius: 20, 
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Speaker Name Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.1),
                        border: Border.all(color: Colors.cyanAccent),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        currentLine.speakerName,
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          color: Colors.cyanAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Dialogue Text (Typewriter Effect)
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 60), // Prevents box from jumping as text types
                      child: Text(
                        _displayedText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.6,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Blinking "Tap to Continue" Indicator
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedOpacity(
                        opacity: _isTyping ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Text(
                          "TAP TO CONTINUE ⏵",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            color: Colors.cyanAccent, 
                            fontSize: 10, 
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}