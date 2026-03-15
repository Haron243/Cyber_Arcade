import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class CyberDialpad extends StatefulWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onEndCall;

  const CyberDialpad({
    super.key,
    required this.onKeyPressed,
    required this.onEndCall,
  });

  @override
  State<CyberDialpad> createState() => _CyberDialpadState();
}

class _CyberDialpadState extends State<CyberDialpad> {
  // Timer State
  Timer? _timer;
  int _seconds = 0;
  String _inputDisplay = ""; // Shows what user typed (e.g., OTP)

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  String _formatTime(int totalSeconds) {
    int min = totalSeconds ~/ 60;
    int sec = totalSeconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  void _handleKeyPress(String value) {
    setState(() {
      _inputDisplay += value;
    });
    // Send key to parent (Game Logic)
    widget.onKeyPressed(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4a4a4a), Color(0xFF1a1a1a)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- 1. CALL TIMER ---
            Text(
              _formatTime(_seconds),
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 18,
                letterSpacing: 2,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. NUMBER DISPLAY ---
            // Shows the digits pressed
            SizedBox(
              height: 50,
              child: Text(
                _inputDisplay,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 32,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ),

            const Spacer(),

            // --- 3. THE DIALPAD GRID ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.0, // Square buttons
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _buildKey('1', ''),
                  _buildKey('2', 'ABC'),
                  _buildKey('3', 'DEF'),
                  _buildKey('4', 'GHI'),
                  _buildKey('5', 'JKL'),
                  _buildKey('6', 'MNO'),
                  _buildKey('7', 'PQRS'),
                  _buildKey('8', 'TUV'),
                  _buildKey('9', 'WXYZ'),
                  _buildKey('*', ''),
                  _buildKey('0', '+'),
                  _buildKey('#', ''),
                ],
              ),
            ),

            const Spacer(),

            // --- 4. END CALL BUTTON ---
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: GestureDetector(
                onTap: widget.onEndCall,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFff3b30), // --decline-color
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String number, String subtext) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50), // Fully circular
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass effect
        child: Material(
          color: Colors.white.withOpacity(0.15), // --button-bg
          child: InkWell(
            onTap: () => _handleKeyPress(number),
            splashColor: Colors.white.withOpacity(0.3), // Ripple effect
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontFamily: 'Inter', // Or Orbitron
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (subtext.isNotEmpty)
                  Text(
                    subtext,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6), // --text-secondary
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}