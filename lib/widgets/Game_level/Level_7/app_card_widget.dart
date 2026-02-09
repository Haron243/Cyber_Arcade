// ===========================================================================
// lib/widgets/Game_level/Level_7/app_card_widget.dart
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:demo_app/data/level_seven_data.dart';

/// A card representing one app in the vetting queue.
/// Shows: icon placeholder, name, category, star rating, and suspicion meter.
class AppCardWidget extends StatelessWidget {
  final VettingApp app;
  final bool isBlocked;
  final double suspicionLevel; // 0.0 - 1.0
  final VoidCallback onTap;

  const AppCardWidget({
    super.key,
    required this.app,
    required this.isBlocked,
    required this.suspicionLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isBlocked
              ? const Color(0xFF1e293b).withOpacity(0.5)
              : const Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBlocked ? Colors.red.withOpacity(0.6) : Colors.white10,
            width: isBlocked ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // App icon placeholder
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(app.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getCategoryColor(app.category).withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryIcon(app.category),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                
                // App info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: TextStyle(
                          color: isBlocked ? Colors.white54 : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            app.starRating.toString(),
                            style: TextStyle(
                              color: isBlocked ? Colors.white38 : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            app.category,
                            style: TextStyle(
                              color: isBlocked ? Colors.white38 : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Suspicion meter (only if checks have been run)
                      if (suspicionLevel > 0)
                        _buildSuspicionMeter(),
                    ],
                  ),
                ),
              ],
            ),
            
            // Blocked overlay stamp
            if (isBlocked)
              Positioned.fill(
                child: Center(
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        border: Border.all(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'BLOCKED',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspicionMeter() {
    final dots = 5;
    final filledDots = (suspicionLevel * dots).round().clamp(0, dots);
    
    Color meterColor;
    if (suspicionLevel < 0.3) {
      meterColor = Colors.green;
    } else if (suspicionLevel < 0.6) {
      meterColor = Colors.amber;
    } else {
      meterColor = Colors.red;
    }

    return Row(
      children: List.generate(dots, (i) {
        final filled = i < filledDots;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: filled ? meterColor : Colors.white24,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tools':
      case 'utility':
        return Colors.blue;
      case 'finance':
        return Colors.green;
      case 'game':
      case 'games':
        return Colors.purple;
      case 'productivity':
        return Colors.orange;
      case 'photo':
      case 'media':
        return Colors.pink;
      case 'health':
        return Colors.teal;
      case 'weather':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tools':
      case 'utility':
        return '🔧';
      case 'finance':
        return '💰';
      case 'game':
      case 'games':
        return '🎮';
      case 'productivity':
        return '📝';
      case 'photo':
        return '📸';
      case 'media':
        return '🎵';
      case 'health':
        return '💪';
      case 'weather':
        return '🌤️';
      default:
        return '📱';
    }
  }
}
