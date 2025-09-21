import 'package:flutter/material.dart';

class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CyberButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        painter: _CyberButtonPainter(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              color: Color(0xFF6CFBFE),
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6CFBFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    double cut = 8.0;

    path.moveTo(cut, 0);
    path.lineTo(size.width - cut, 0);
    path.lineTo(size.width, cut);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, cut);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}