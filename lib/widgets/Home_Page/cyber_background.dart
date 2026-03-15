import 'package:flutter/material.dart';

class CyberBackground extends StatelessWidget {
  const CyberBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // The exact same gradient background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0a0304), // Dark reddish-black on the edge
            Color(0xFF2a0b0f), // Deep red in the center
            Color(0xFF0a0304), // Dark reddish-black on the edge
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      // CustomPaint replaces the heavy GridView with a single, ultra-fast drawing
      child: CustomPaint(
        painter: CyberGridPainter(),
        size: Size.infinite,
      ),
    );
  }
}

// This draws the entire grid in 1 frame instead of building 500+ text widgets
class CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Exact same subtle white/grey color
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.05)
      ..strokeWidth = 1.0;

    // Matches your crossAxisCount: 20 density
    final double spacing = size.width / 20;
    
    // The size of the '+' symbol
    const double crossSize = 3.0; 

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        // Draw horizontal line of the '+'
        canvas.drawLine(Offset(x - crossSize, y), Offset(x + crossSize, y), paint);
        // Draw vertical line of the '+'
        canvas.drawLine(Offset(x, y - crossSize), Offset(x, y + crossSize), paint);
      }
    }
  }

  @override
  // Tells Flutter this background NEVER needs to be redrawn
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; 
}