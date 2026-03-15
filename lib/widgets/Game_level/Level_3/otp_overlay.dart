import 'package:flutter/material.dart';

class OtpOverlay extends StatefulWidget {
  final String otpCode;
  final VoidCallback onDismiss;

  const OtpOverlay({
    super.key,
    required this.otpCode,
    required this.onDismiss,
  });

  @override
  State<OtpOverlay> createState() => _OtpOverlayState();
}

class _OtpOverlayState extends State<OtpOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<Offset> _slideAnimation;

  // Swipe State
  double _dragOffset = 0.0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    // Entry Animation (Slide Down)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // Start above screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut, // Bouncy entry like a real notification
    ));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  // --- SWIPE LOGIC ---

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isDismissing) return;

    setState(() {
      // Only allow dragging UP (negative Y)
      // script.js line 225: if (deltaY < 0)
      if (details.delta.dy < 0 || _dragOffset < 0) {
        _dragOffset += details.delta.dy;
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isDismissing) return;

    // script.js line 250: if (deltaY < -50) { hideOTPNotification() }
    if (_dragOffset < -50) {
      // Dismiss Triggered
      setState(() {
        _isDismissing = true;
        _dragOffset = -200.0; // Fly off screen
      });
      // Allow animation to finish before calling parent callback
      Future.delayed(const Duration(milliseconds: 200), widget.onDismiss);
    } else {
      // Snap back to zero (Reset)
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50, // Top margin
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _dragOffset, 0),
          child: GestureDetector(
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // styles.css line 515: background: linear-gradient
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFf5f5f5)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- HEADER ---
                  Row(
                    children: [
                      const Text("🏦", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Bank Alert",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      Text(
                        "now",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 16, thickness: 0.5),

                  // --- BODY ---
                  const Text(
                    "Your OTP is:",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),

                  // OTP Code Badge
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a73e8).withOpacity(0.1), // Light blue bg
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.otpCode,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a73e8), // styles.css line 560
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const Text(
                    "Do NOT share this with anyone!",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFd93025), // Warning Red
                    ),
                  ),

                  const SizedBox(height: 8),

                  // --- SWIPE HINT ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward, size: 10, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        "Swipe up to dismiss",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}