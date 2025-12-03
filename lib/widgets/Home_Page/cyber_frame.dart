import 'package:flutter/material.dart';

class CyberFrame extends StatelessWidget {
  const CyberFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(),
      child: Container(),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double cornerLength = 20.0;
    const double notchHeight = 8.0;
    const double horizontalPadding = 20.0;
    const double verticalPadding = 20.0;

    // Top Frame
    final topPath = Path();
    // Top-left corner
    topPath.moveTo(horizontalPadding + cornerLength, verticalPadding);
    topPath.lineTo(horizontalPadding + cornerLength, verticalPadding + notchHeight);
    topPath.moveTo(horizontalPadding + cornerLength, verticalPadding);
    topPath.lineTo(horizontalPadding, verticalPadding);

    // Top-right corner
    topPath.moveTo(size.width - horizontalPadding - cornerLength, verticalPadding);
    topPath.lineTo(size.width - horizontalPadding - cornerLength, verticalPadding + notchHeight);
    topPath.moveTo(size.width - horizontalPadding - cornerLength, verticalPadding);
    topPath.lineTo(size.width - horizontalPadding, verticalPadding);

    canvas.drawPath(topPath, paint);

    // No need for a bottom frame as per the simple design in Screen 1
    // If you need it, uncomment the code below.
    
    // final bottomPath = Path();
    // // Bottom-left corner
    // bottomPath.moveTo(horizontalPadding, size.height - verticalPadding);
    // bottomPath.lineTo(horizontalPadding + cornerLength, size.height - verticalPadding);
    //
    // // Bottom-right corner
    // bottomPath.moveTo(size.width - horizontalPadding, size.height - verticalPadding);
    // bottomPath.lineTo(size.width - horizontalPadding - cornerLength, size.height - verticalPadding);
    //
    // canvas.drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}