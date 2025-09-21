import 'package:flutter/material.dart';

class CustomGlitchText extends StatelessWidget {
  final String text;
  final double fontSize;

  const CustomGlitchText({
    super.key,
    required this.text,
    this.fontSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF92444); // This color is already perfect for the text itself

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Orbitron',
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        color: primaryColor,
        shadows: const [
          // Adjusted shadow properties for a more contained, stronger glow
          Shadow(
            blurRadius: 15.0, // Increased blur for a softer spread
            color: primaryColor,
            offset: Offset(0, 0),
          ),
          Shadow(
            blurRadius: 30.0, // Even larger blur for the outer halo
            color: primaryColor,
            offset: Offset(0, 0),
          ),
          // You can add more shadows here for a multi-layered glow if needed
        ],
      ),
    );
  }
}