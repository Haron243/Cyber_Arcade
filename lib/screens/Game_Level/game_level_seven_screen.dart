// ===========================================================================
// lib/screens/Game_Level/game_level_seven_screen.dart
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:demo_app/data/level_seven_data.dart';
import 'package:demo_app/services/user_progress_service.dart';
import 'package:demo_app/widgets/Game_level/Level_7/app_card_widget.dart';
import 'package:demo_app/widgets/Game_level/Level_7/inspector_panel_widget.dart';
import 'package:demo_app/widgets/Game_level/Level_7/result_screen_widget.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';

class GameLevelSevenScreen extends StatefulWidget {
  const GameLevelSevenScreen({super.key});

  @override
  State<GameLevelSevenScreen> createState() => _GameLevelSevenScreenState();
}

class _GameLevelSevenScreenState extends State<GameLevelSevenScreen> {

  // services
  final UserProgressService _progressService = UserProgressService();

  // --- Scenario state ---
  late VettingScenario _scenario;
  int _scenarioIndex = 0;

  // --- Game state ---
  late int _tokensRemaining;
  final Set<String> _blockedAppIds = {};
  
  // Per-app tracking: which checks have been run, what clues revealed
  final Map<String, Set<String>> _completedChecks = {}; // appId -> {checkId, ...}
  final Map<String, List<String>> _revealedClues = {};  // appId -> [clue, ...]

  // --- UI state ---
  VettingApp? _inspectingApp;
  bool _showTutorial = true;
  int _tutorialStep = 0; // 0 = intro, 1 = first check forced, 2 = done
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _loadScenario(0);
  }

  void _loadScenario(int index) {
    setState(() {
      _scenarioIndex = index;
      _scenario = levelSevenData[index];
      _tokensRemaining = _scenario.initialTokens;
      _blockedAppIds.clear();
      _completedChecks.clear();
      _revealedClues.clear();
      _inspectingApp = null;
      _gameOver = false;
      // Tutorial shows only on first scenario
      _showTutorial = index == 0;
      _tutorialStep = 0;
    });
  }

  // --- Suspicion calculation ---
  double _getSuspicionLevel(VettingApp app) {
    final checksRun = _completedChecks[app.id] ?? {};
    if (checksRun.isEmpty) return 0.0;

    final weights = app.checks
        .where((c) => checksRun.contains(c.id))
        .map((c) => c.suspicionWeight)
        .toList();

    if (weights.isEmpty) return 0.0;
    return weights.reduce((a, b) => a + b) / weights.length;
  }

  // --- Actions ---
  void _openInspector(VettingApp app) {
    if (_gameOver) return;
    setState(() => _inspectingApp = app);

    // Tutorial: advance to step 1 on first app tap
    if (_showTutorial && _tutorialStep == 0) {
      setState(() => _tutorialStep = 1);
    }
  }

  void _runCheck(VettingApp app, VettingCheck check) {
    if (_tokensRemaining < check.cost) return;

    setState(() {
      _tokensRemaining -= check.cost;
      _completedChecks.putIfAbsent(app.id, () => {}).add(check.id);
      _revealedClues.putIfAbsent(app.id, () => []).add(check.clueText);
    });

    // Tutorial: advance to step 2 after first check
    if (_showTutorial && _tutorialStep == 1) {
      setState(() => _tutorialStep = 2);
    }
  }

  void _toggleBlock(String appId) {
    setState(() {
      if (_blockedAppIds.contains(appId)) {
        _blockedAppIds.remove(appId);
      } else {
        _blockedAppIds.add(appId);
      }
    });
  }

  void _releaseApps() {
    if (_gameOver) return;

    final xp = _calculateXP();
    // Save progress for this level
    _progressService.saveLevelProgress(7, xp);

    setState(() {
      _gameOver = true;
      _inspectingApp = null;
    });
  }

  int _calculateXP() {
    final riskyApps = _scenario.apps.where((a) => a.isRisky).toList();
    final safeApps = _scenario.apps.where((a) => !a.isRisky).toList();

    final riskyBlocked = riskyApps.where((a) => _blockedAppIds.contains(a.id)).length;
    final riskyMissed = riskyApps.length - riskyBlocked;
    final safeBlocked = safeApps.where((a) => _blockedAppIds.contains(a.id)).length;

    // Balanced formula (from review)
    int xp = (riskyBlocked * 10)      // reward for blocking risky
        - (riskyMissed * 15)          // punish misses heavily
        - (safeBlocked * 10)          // punish false positives equally
        + (_tokensRemaining * 2);     // reward efficiency

    const minXP = 10;
    return xp.clamp(minXP, 200);
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) {
      return Scaffold(
        body: ResultScreenWidget(
          allApps: _scenario.apps,
          blockedAppIds: _blockedAppIds,
          tokensRemaining: _tokensRemaining,
          xpEarned: _calculateXP(),
          onRetry: () => _loadScenario(_scenarioIndex),
          onNextLevel: () => _loadScenario(_scenarioIndex + 1),
          hasNextLevel: _scenarioIndex < levelSevenData.length - 1,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Stack(
        children: [
          const CyberBackground(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 12, bottom: 100),
                    children: _scenario.apps.map((app) {
                      return AppCardWidget(
                        app: app,
                        isBlocked: _blockedAppIds.contains(app.id),
                        suspicionLevel: _getSuspicionLevel(app),
                        onTap: () => _openInspector(app),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Release button (bottom FAB)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _releaseApps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Release Apps to Market',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Inspector panel
          if (_inspectingApp != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _inspectingApp = null),
                child: Container(
                  color: Colors.black54,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {}, // prevent closing when tapping panel itself
                      child: InspectorPanelWidget(
                        app: _inspectingApp!,
                        tokensRemaining: _tokensRemaining,
                        completedChecks: _completedChecks[_inspectingApp!.id] ?? {},
                        revealedClues: _revealedClues[_inspectingApp!.id] ?? [],
                        onRunCheck: (check) => _runCheck(_inspectingApp!, check),
                        onBlock: () {
                          _toggleBlock(_inspectingApp!.id);
                          setState(() => _inspectingApp = null);
                        },
                        onClose: () => setState(() => _inspectingApp = null),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Tutorial overlay
          if (_showTutorial) _buildTutorialOverlay(),

          // Back button
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.9),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _scenario.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_scenario.apps.length} apps waiting',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      _tokensRemaining.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _scenario.context,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // --- Tutorial ---
  Widget _buildTutorialOverlay() {
    String title, body, cta;
    IconData icon;

    switch (_tutorialStep) {
      case 0:
        title = 'App Store Gatekeeper';
        body = 'You have ${_scenario.initialTokens} vetting tokens (🪙) to inspect apps.\n\n'
            'You can\'t check everything — choose wisely.\n\n'
            'Tap any app to begin.';
        cta = 'Got it';
        icon = Icons.shield;
        break;
      case 1:
        title = 'Run Checks';
        body = 'Tap a check to spend tokens and learn more.\n\n'
            'The more you spend, the clearer the risk becomes.\n\n'
            'After checking, you can Block the app or skip it.';
        cta = 'Continue';
        icon = Icons.search;
        break;
      default: // step 2
        title = 'Make Your Decision';
        body = 'Inspect other apps with your remaining tokens.\n\n'
            'Block anything too risky.\n\n'
            'When ready, press "Release Apps".';
        cta = 'Start';
        icon = Icons.play_arrow;
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_tutorialStep == 0 || _tutorialStep == 2) {
              _showTutorial = false;
            }
            // Step 1 advances automatically after first check
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Container(
              width: 320,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.blue, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_tutorialStep == 0 || _tutorialStep == 2) {
                            _showTutorial = false;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cta,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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