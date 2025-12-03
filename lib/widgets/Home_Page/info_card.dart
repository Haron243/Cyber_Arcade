import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the CustomPaint with a GestureDetector
    return GestureDetector(
      // 2. Add the onTap property to call your onPressed function
      onTap: onPressed,
      child: CustomPaint(
        painter: _CardBorderPainter(),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2),
              ),
              const Divider(color: Colors.red, thickness: 0.5, height: 20),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBorderPainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()
            ..color = Colors.red.withOpacity(0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

        final path = Path();
        double lineLength = 20.0;

        // Top-left corner
        path.moveTo(lineLength, 0);
        path.lineTo(0, 0);
        path.lineTo(0, lineLength);

        // Top-right corner
        path.moveTo(size.width - lineLength, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, lineLength);

        // Bottom-left corner
        path.moveTo(0, size.height - lineLength);
        path.lineTo(0, size.height);
        path.lineTo(lineLength, size.height);

        // Bottom-right corner
        path.moveTo(size.width, size.height - lineLength);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width - lineLength, size.height);

        canvas.drawPath(path, paint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}