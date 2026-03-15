import 'package:flutter/material.dart';
import 'package:demo_app/data/level_three_data.dart'; // Import your data model
import 'package:audioplayers/audioplayers.dart';

class IncomingCallOverlay extends StatefulWidget {
  final VishingScenario scenario;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallOverlay({
    super.key,
    required this.scenario,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  late AnimationController _textBlinkController;
  late Animation<double> _opacityAnimation;

  final AudioPlayer _ringtonePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startRingtone();

    // 1. Avatar & Accept Button Pulse Animation (CSS: avatarPulse 2s infinite)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false); // CSS pulses continuously

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. Text Blink Animation (CSS: statusBlink 1.5s infinite)
    _textBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _textBlinkController, curve: Curves.easeInOut),
    );
  }

  // Ringtone Logic
  Future<void> _startRingtone() async {
    // Set to loop so it keeps ringing until answered
    await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
    await _ringtonePlayer.play(AssetSource('audio/ringtone.mp3'));
  }

  Future<void> _stopRingtone() async {
    await _ringtonePlayer.stop();
  }

  // Wrapper to stop ringtone before calling parent action
  void _handleAccept() async {
    await _stopRingtone();
    widget.onAccept();
  }

  void _handleDecline() async {
    await _stopRingtone();
    widget.onDecline();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textBlinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Full screen overlay with dark gradient background
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4a4a4a), // --bg-gradient-start
            Color(0xFF1a1a1a), // --bg-gradient-end
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // --- CALLER INFO SECTION ---
            
            // Animated Avatar
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                // Simulating the box-shadow pulse from CSS
                double pulseOpacity = 1.0 - _pulseController.value;
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2 * pulseOpacity),
                          blurRadius: _shadowAnimation.value,
                          spreadRadius: _shadowAnimation.value / 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),

            // Caller Name
            Text(
              widget.scenario.callerName,
              style: const TextStyle(
                fontFamily: 'Orbitron', // Keeping your app theme
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 8),

            // Phone Number
            Text(
              widget.scenario.phoneNumber,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 18,
                color: Colors.white.withOpacity(0.6), // --text-secondary
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 15),

            // Blinking Status Text
            FadeTransition(
              opacity: _opacityAnimation,
              child: const Text(
                "Incoming call...",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ),

            const Spacer(flex: 3),

            // --- ACTION BUTTONS ---
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // DECLINE BUTTON
                  _buildCallButton(
                    label: "Decline",
                    color: const Color(0xFFff3b30), // --decline-color
                    icon: Icons.call_end,
                    onTap: _handleDecline,
                  ),

                  // ACCEPT BUTTON (With Pulse)
                  _buildCallButton(
                    label: "Accept",
                    color: const Color(0xFF34c759), // --accept-color
                    icon: Icons.call,
                    onTap: _handleAccept,
                    isAccept: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool isAccept = false,
  }) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            // Apply pulse shadow only if it's the Accept button
            List<BoxShadow> shadows = [
              const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
            ];
            
            if (isAccept) {
               double pulseOpacity = 1.0 - _pulseController.value;
               shadows.add(
                 BoxShadow(
                   color: color.withOpacity(0.4 * pulseOpacity),
                   blurRadius: 15, // Approx 15px spread from CSS
                   spreadRadius: 15 * _pulseController.value,
                 )
               );
            }

            return GestureDetector(
              onTap: onTap,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: shadows,
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6), // --text-secondary
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}