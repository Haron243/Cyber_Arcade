import 'package:flutter/material.dart';

class CyberBackground extends StatelessWidget {
  const CyberBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The new Horizontal Gradient Layer
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // This creates the horizontal "glow" from the center out
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF0a0304), // Dark reddish-black on the edge
                Color(0xFF2a0b0f), // Deep red in the center
                Color(0xFF0a0304), // Dark reddish-black on the edge
              ],
              stops: [0.0, 0.5, 1.0], // Ensures the red is perfectly centered
            ),
          ),
        ),
        // The Grid Layer
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 20, // More crosses for a denser feel
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemBuilder: (_, index) {
            return Center(
              child: Text(
                '+',
                style: TextStyle(
                  color: const Color(0xFFFFFFFF).withOpacity(0.05), // Very subtle white/grey
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }
}