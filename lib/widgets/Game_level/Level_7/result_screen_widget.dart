// ===========================================================================
// lib/widgets/Game_level/Level_7/result_screen_widget.dart
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:demo_app/data/level_seven_data.dart';

class ResultScreenWidget extends StatelessWidget {
  final List<VettingApp> allApps;
  final Set<String> blockedAppIds;
  final int tokensRemaining;
  final int xpEarned;
  final VoidCallback onRetry;
  final VoidCallback onNextLevel;
  final bool hasNextLevel;

  const ResultScreenWidget({
    super.key,
    required this.allApps,
    required this.blockedAppIds,
    required this.tokensRemaining,
    required this.xpEarned,
    required this.onRetry,
    required this.onNextLevel,
    required this.hasNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final riskyApps = allApps.where((a) => a.isRisky).toList();
    final safeApps = allApps.where((a) => !a.isRisky).toList();

    final riskyBlocked = riskyApps.where((a) => blockedAppIds.contains(a.id)).length;
    final riskyMissed = riskyApps.length - riskyBlocked;

    final safeBlocked = safeApps.where((a) => blockedAppIds.contains(a.id)).length;
    final safeReleased = safeApps.length - safeBlocked;

    final isSuccess = riskyBlocked >= (riskyApps.length * 0.8).ceil();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    isSuccess ? Icons.verified_user : Icons.warning_amber_rounded,
                    size: 64,
                    color: isSuccess ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSuccess ? 'Apps Released' : 'Market Released',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSuccess
                        ? 'Good judgment on prioritization'
                        : 'Some risky apps slipped through',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Stats summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    '✅ Risky apps blocked',
                    '$riskyBlocked / ${riskyApps.length}',
                    riskyBlocked == riskyApps.length ? Colors.green : Colors.orange,
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _buildStatRow(
                    '⚠️ Risky apps missed',
                    riskyMissed.toString(),
                    riskyMissed == 0 ? Colors.green : Colors.red,
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _buildStatRow(
                    '🔒 Safe apps blocked',
                    safeBlocked.toString(),
                    safeBlocked == 0 ? Colors.green : Colors.orange,
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _buildStatRow(
                    '🪙 Tokens saved',
                    tokensRemaining.toString(),
                    Colors.blue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Detailed breakdown
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f172a),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.list_alt, color: Colors.white54, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'App Breakdown',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (riskyMissed > 0) ...[
                            const Text(
                              '⚠️ Risky Apps Released (Slipped Through)',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...riskyApps
                                .where((a) => !blockedAppIds.contains(a.id))
                                .map((a) => _buildAppResultItem(a, Colors.red, false)),
                            const SizedBox(height: 16),
                          ],

                          if (riskyBlocked > 0) ...[
                            const Text(
                              '✅ Risky Apps Blocked (Good Call)',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...riskyApps
                                .where((a) => blockedAppIds.contains(a.id))
                                .map((a) => _buildAppResultItem(a, Colors.green, true)),
                            const SizedBox(height: 16),
                          ],

                          if (safeBlocked > 0) ...[
                            const Text(
                              '⚠️ Safe Apps Blocked (False Alarm)',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...safeApps
                                .where((a) => blockedAppIds.contains(a.id))
                                .map((a) => _buildAppResultItem(a, Colors.orange, true)),
                            const SizedBox(height: 16),
                          ],

                          if (safeReleased > 0) ...[
                            const Text(
                              '✅ Safe Apps Released (Correct)',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...safeApps
                                .where((a) => !blockedAppIds.contains(a.id))
                                .map((a) => _buildAppResultItem(a, Colors.green, false)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // XP and actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade900, Colors.blue.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'XP Earned: $xpEarned',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onRetry,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: hasNextLevel ? onNextLevel : () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            hasNextLevel ? 'Next Scenario' : 'Finish',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAppResultItem(VettingApp app, Color color, bool wasBlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            wasBlocked ? Icons.block : Icons.check_circle_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              app.name,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              app.isRisky ? 'Risky' : 'Safe',
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
