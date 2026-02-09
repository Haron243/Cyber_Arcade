// ===========================================================================
// lib/widgets/Game_level/Level_7/inspector_panel_widget.dart
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:demo_app/data/level_seven_data.dart';

/// Bottom sheet that appears when inspecting an app.
/// Shows available checks, their costs, and results of checks already run.
class InspectorPanelWidget extends StatelessWidget {
  final VettingApp app;
  final int tokensRemaining;
  final Set<String> completedChecks;
  final List<String> revealedClues;
  final Function(VettingCheck) onRunCheck;
  final VoidCallback onBlock;
  final VoidCallback onClose;

  const InspectorPanelWidget({
    super.key,
    required this.app,
    required this.tokensRemaining,
    required this.completedChecks,
    required this.revealedClues,
    required this.onRunCheck,
    required this.onBlock,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0f172a),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          app.category,
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Token display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          tokensRemaining.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Checks list
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Checks',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Check buttons
                    ...app.checks.map((check) => _buildCheckButton(check)),

                    // Results area (if any checks have been run)
                    if (revealedClues.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 12),
                      const Text(
                        'Findings',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...revealedClues.map((clue) => _buildClueItem(clue)),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Block button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onBlock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.block, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Block App',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Close button
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckButton(VettingCheck check) {
    final isCompleted = completedChecks.contains(check.id);
    final canAfford = tokensRemaining >= check.cost;

    Color buttonColor;
    if (isCompleted) {
      buttonColor = const Color(0xFF1e293b);
    } else if (!canAfford) {
      buttonColor = const Color(0xFF0f172a);
    } else if (check.cost <= 2) {
      buttonColor = Colors.green.shade900.withOpacity(0.3);
    } else {
      buttonColor = Colors.orange.shade900.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.4)
              : (canAfford ? Colors.white10 : Colors.red.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Text(check.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          
          // Check name
          Expanded(
            child: Text(
              check.name,
              style: TextStyle(
                color: isCompleted ? Colors.white54 : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Cost & button
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 20)
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: canAfford ? Colors.white10 : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    check.cost.toString(),
                    style: TextStyle(
                      color: canAfford ? Colors.white : Colors.red[300],
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: canAfford ? () => onRunCheck(check) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? Colors.blue[700] : Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Run',
                  style: TextStyle(
                    color: canAfford ? Colors.white : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClueItem(String clue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              clue,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
