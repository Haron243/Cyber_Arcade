import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Add this package!
import 'package:demo_app/data/level_three_data.dart';
import 'package:demo_app/widgets/Game_Level/Level_3/incoming_call_overlay.dart';
import 'package:demo_app/widgets/Game_Level/Level_3/dialpad_screen.dart';
import 'package:demo_app/widgets/Game_Level/Level_3/otp_overlay.dart';
import 'package:demo_app/services/user_progress_service.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/screens/Game_Level/cutscene_screen.dart';

class GameLevelThreeScreen extends StatefulWidget {
  const GameLevelThreeScreen({super.key});

  @override
  State<GameLevelThreeScreen> createState() => _GameLevelThreeScreenState();
}

enum GameState { incoming, connected, finished }

class _GameLevelThreeScreenState extends State<GameLevelThreeScreen> {
  // Game State
  late VishingScenario _scenario;
  GameState _gameState = GameState.incoming;
  String? _currentStepId;
  
  // Logic State
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _userInputBuffer = ""; // Stores what user types on dialpad
  bool _showOtpOverlay = false;
  String _generatedOtp = "847291"; // Default, or randomize

  // Scoring
  int _score = 0;
  bool _isWin = false;
  String _resultMessage = "";

  @override
  void initState() {
    super.initState();
    _pickRandomScenario();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- INITIALIZATION ---

  void _pickRandomScenario() {
    // Randomly select 'bank_fake' or 'bank_legit' from your data
    final random = Random();
    _scenario = levelThreeData[random.nextInt(levelThreeData.length)];
    _currentStepId = _scenario.initialStepId;
    _generateRandomOtp();
    
    // Debug print
    print("Selected Scenario: ${_scenario.id} (Scam: ${_scenario.isScam})");
  }

  void _generateRandomOtp() {
    // Generate random 6-digit code
    _generatedOtp = (Random().nextInt(900000) + 100000).toString();
  }

  // --- AUDIO LOGIC ---

  Future<void> _playStepAudio() async {
    if (_currentStepId == null) return;
    
    final step = _scenario.steps[_currentStepId];
    if (step == null) return;

    try {
      // Assumes audio files are in assets/
      // AudioPlayer usually requires "audio/filename.mp3" if in assets
      await _audioPlayer.stop(); // Stop previous
      await _audioPlayer.play(AssetSource(step.audioPath));
      
      // Check for auto-actions after audio starts
      if (step.action == CallAction.otpInput) {
        setState(() {
          _showOtpOverlay = true;
        });
      } else if (step.autoDisconnect) {
        // Wait for audio to finish then end call? 
        // For simplicity, we can let user hang up or use a delay.
        // Better: Listen to onPlayerComplete.
        _audioPlayer.onPlayerComplete.listen((event) {
            if (_gameState == GameState.connected) {
               _finishGame(isWin: step.isWin, message: step.endMessage ?? "Call Ended");
            }
        });
      }
    } catch (e) {
      print("Audio Error: $e");
    }
  }

  // --- INTERACTION HANDLERS ---

  void _acceptCall() {
    setState(() {
      _gameState = GameState.connected;
    });
    _playStepAudio();
  }

  void _declineCall() {
    // Declining immediately logic:
    // If Scam -> Win (You avoided it)
    // If Legit -> Lose (You missed important call)
    bool won = _scenario.isScam; 
    _finishGame(
      isWin: won,
      message: won 
          ? "Good job! You ignored a potential scam." 
          : "You missed an important call from your bank!",
    );
  }

  void _onDialpadKey(String key) {
    if (_gameState != GameState.connected || _currentStepId == null) return;

    final step = _scenario.steps[_currentStepId];
    if (step == null) return;

    // 1. HANDLE OTP ENTRY (The Trap)
    if (step.action == CallAction.otpInput) {
      _userInputBuffer += key;
      
      // If they type 6 digits, check against OTP
      if (_userInputBuffer.length >= 6) {
        // If they entered the OTP shown on screen -> THEY LOSE
        // (Because they shared it with the scammer)
        _finishGame(
          isWin: false,
          message: "You shared your OTP! System Compromised.",
        );
      }
      return;
    }

    // 2. HANDLE MENU NAVIGATION (Press 1, Press 2)
    if (step.action == CallAction.keypadInput && step.nextSteps != null) {
      if (step.nextSteps!.containsKey(key)) {
        // Move to next step
        setState(() {
          _currentStepId = step.nextSteps![key];
          _userInputBuffer = ""; // Reset buffer
        });
        _playStepAudio();
      }
    }
  }

  void _onHangUp() {
    // Manual Hangup Logic:
    // If Scam -> Win (Good, you hung up on them)
    // If Legit -> Lose (Bad, you hung up on real bank)
    
    // Exception: If the Legit call was basically "Done" (autoDisconnect state), hanging up is fine.
    // But usually user hangs up mid-call.
    
    final step = _scenario.steps[_currentStepId];
    bool isSafeToHangUp = step?.autoDisconnect ?? false;

    if (_scenario.isScam) {
      _finishGame(isWin: true, message: "Excellent! You hung up on a vishing attack.");
    } else {
      if (isSafeToHangUp) {
        _finishGame(isWin: true, message: "Call completed successfully.");
      } else {
        _finishGame(isWin: false, message: "You hung up on a legitimate verification call.");
      }
    }
  }

  void _finishGame({required bool isWin, required String message}) {
    _audioPlayer.stop();
    setState(() {
      _gameState = GameState.finished;
      _isWin = isWin;
      _score = isWin ? 100 : 0;
      _resultMessage = message;
      _showOtpOverlay = false; // Hide if visible
    });
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. THE GAME SCREENS (Switched via Stack or if/else)
          if (_gameState == GameState.incoming)
            IncomingCallOverlay(
              scenario: _scenario,
              onAccept: _acceptCall,
              onDecline: _declineCall,
            ),

          if (_gameState == GameState.connected)
            CyberDialpad(
              onKeyPressed: _onDialpadKey,
              onEndCall: _onHangUp,
            ),
            
          // 2. OTP OVERLAY (Conditional)
          if (_gameState == GameState.connected && _showOtpOverlay)
            OtpOverlay(
              otpCode: _generatedOtp,
              onDismiss: () {
                setState(() => _showOtpOverlay = false);
              },
            ),

          // 3. RESULT OVERLAY (Game Over)
          if (_gameState == GameState.finished)
            _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildResultOverlay() {
    Color statusColor = _isWin ? Colors.greenAccent : const Color(0xFFff3b30);
    
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor, width: 2),
            boxShadow: [
              BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 30)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isWin ? Icons.verified_user : Icons.warning_amber_rounded,
                size: 60,
                color: statusColor,
              ),
              const SizedBox(height: 20),
              Text(
                _isWin ? "MISSION SUCCESS" : "MISSION FAILED",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _resultMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const Divider(color: Colors.white24, height: 40),
              
              const Text(
                "INTEL:",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: Colors.cyanAccent,
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _scenario.educationalReasoning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              
              CyberButton(
                text: "RETURN TO BASE",
                onPressed: () async {
                  // Save progress
                  final service = UserProgressService();
                  await service.saveLevelProgress(3, _score);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close screen
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