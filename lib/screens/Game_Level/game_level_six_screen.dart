import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/data/level_six_data.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/services/user_progress_service.dart';
import 'package:demo_app/screens/Game_Level/cutscene_screen.dart';

// ---------------------------------------------------------------------------

class GameLevelSixScreen extends StatefulWidget { 
  const GameLevelSixScreen({super.key});
  @override
  State<GameLevelSixScreen> createState() => _GameLevelSixScreenState();
}

class _GameLevelSixScreenState extends State<GameLevelSixScreen>
    with TickerProviderStateMixin {
  // --- services --------------------------------------------------------------
  final UserProgressService _progressService = UserProgressService();

  // --- state -----------------------------------------------------------------
  late PaymentScenario _scenario;
  int _scenarioIndex = 0;
  int _totalXP = 0; // Cumulative XP across all scenarios in this session

  final List<Map<String, String>> _connections = [];
  String? _selectedNodeId;
  int? _lastConnectedEdgeIndex;

  bool _isInspectMode = false;
  int _inspectCount = 3;
  GameNode? _inspectingNode;

  bool _showTutorial = true;
  int _tutorialStep = 0;

  bool _isCutscenePlaying = true; // to check if cutscene playing or not

  bool _isSimulating = false;
  bool _isGameOver = false;
  String? _resultTitle;
  String? _resultMessage;
  bool _isSuccess = false;

  List<Offset> _waypoints = [];
  int? _leakIndex;
  Offset? _leakTarget;

  // --- controllers -----------------------------------------------------------
  late AnimationController _moneyController;
  late AnimationController _edgePulseController;

  // --- cached path IDs (set during simulation, reused by painter) ------------
  List<String> _activePath = [];

  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadScenario(0);
    _moneyController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    _edgePulseController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    // ADDED: Trigger cutscene on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCutscene();
    });
  }

  // ADDED: Cutscene routing
  void _showCutscene() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, 
        pageBuilder: (context, animation, secondaryAnimation) => const CutsceneScreen(levelId: 6),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      if (!mounted) return;
      // WHEN CUTSCENE ENDS: Allow the tutorial overlay to appear!
      setState(() {
        _isCutscenePlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _edgePulseController.dispose();
    super.dispose();
  }

  void _loadScenario(int index) {
    setState(() {
      _scenarioIndex = index;
      _scenario = levelSixData[index];
      _connections.clear();
      _selectedNodeId = null;
      _lastConnectedEdgeIndex = null;
      _inspectCount = 3;
      _isInspectMode = false;
      _isSimulating = false;
      _isGameOver = false;
      _waypoints = [];
      _leakIndex = null;
      _leakTarget = null;
      _activePath = [];
    });
  }

  // --- helpers ---------------------------------------------------------------
  GameNode get _sourceNode =>
      _scenario.nodes.firstWhere((n) => n.nodeType == NodeType.source);

  GameNode get _targetNode =>
      _scenario.nodes.firstWhere((n) => n.nodeType == NodeType.target);

  bool get _canSend {
    if (_connections.isEmpty) return false;
    final src = _sourceNode.id;
    return _connections.any((c) => c['from'] == src || c['to'] == src);
  }

  /// BFS from source to target.  Returns ordered node-ID list or null.
  List<String>? _bfsPath() {
    final srcId = _sourceNode.id;
    final tgtId = _targetNode.id;
    final parent = <String, String>{};
    final visited = <String>{srcId};
    final queue = <String>[srcId];

    while (queue.isNotEmpty) {
      final cur = queue.removeAt(0);
      if (cur == tgtId) {
        final path = <String>[];
        String? step = tgtId;
        while (step != null) {
          path.insert(0, step);
          step = parent[step];
        }
        return path;
      }
      for (final conn in _connections) {
        String? next;
        if (conn['from'] == cur) next = conn['to'];
        if (conn['to'] == cur) next = conn['from'];
        if (next != null && !visited.contains(next)) {
          visited.add(next);
          parent[next] = cur;
          queue.add(next);
        }
      }
    }
    return null;
  }

  /// First bad edge along [pathIds] — returns its index or null.
  int? _findLeakIndex(List<String> pathIds) {
    for (int i = 0; i < pathIds.length - 1; i++) {
      final fwd = '${pathIds[i]}->${pathIds[i + 1]}';
      final bwd = '${pathIds[i + 1]}->${pathIds[i]}';
      if (_scenario.badPaths.containsKey(fwd) ||
          _scenario.badPaths.containsKey(bwd)) return i + 1;
    }
    return null;
  }

  /// Calculate XP for this scenario based on performance
  int _calculateScenarioXP() {
    if (!_isSuccess) return 0; // No XP for failed scenarios
    
    // Base XP for completing scenario
    int xp = 100;
    
    // Bonus for efficient routing (fewer connections = better)
    // Optimal path length is usually 2-3 connections
    final connectionEfficiency = (5 - _connections.length).clamp(0, 3) * 10;
    xp += connectionEfficiency;
    
    // Bonus for unused inspect tokens (shows good judgment)
    xp += _inspectCount * 15;
    
    // Small bonus for each scenario number (harder scenarios worth more)
    xp += (_scenarioIndex + 1) * 10;
    
    return xp.clamp(50, 200); // Min 50, max 200 per scenario
  }

  // --- interaction -----------------------------------------------------------
  void _handleNodeTap(GameNode node) {
    if (_isSimulating || _isGameOver) return;

    if (_isInspectMode) {
      if (_inspectCount > 0) {
        setState(() {
          _inspectingNode = node;
          _inspectCount--;
          _isInspectMode = false;
        });
      }
      return;
    }

    setState(() {
      if (_selectedNodeId == null) {
        _selectedNodeId = node.id;
      } else if (_selectedNodeId == node.id) {
        _selectedNodeId = null;
      } else {
        final existingIndex = _connections.indexWhere(
          (c) =>
              (c['from'] == _selectedNodeId && c['to'] == node.id) ||
              (c['from'] == node.id && c['to'] == _selectedNodeId),
        );
        if (existingIndex >= 0) {
          _connections.removeAt(existingIndex);
          _lastConnectedEdgeIndex = null;
        } else {
          _connections.add({'from': _selectedNodeId!, 'to': node.id});
          _lastConnectedEdgeIndex = _connections.length - 1;
          _edgePulseController.forward(from: 0);
        }
        _selectedNodeId = null;
      }
    });
  }

  // --- simulation ------------------------------------------------------------
  void _startSimulation(Size size) {
    final pathIds = _bfsPath();
    if (pathIds == null) {
      setState(() {
        _isSuccess = false;
        _resultTitle = "INCOMPLETE ROUTE";
        _resultMessage =
            "Your path never reached the destination. Connect the nodes and try again.";
        _isGameOver = true;
      });
      return;
    }

    final leakAt = _findLeakIndex(pathIds);

    // Grab the failure message while we already know where the leak is
    String? failureReason;
    if (leakAt != null) {
      final fwd = '${pathIds[leakAt - 1]}->${pathIds[leakAt]}';
      final bwd = '${pathIds[leakAt]}->${pathIds[leakAt - 1]}';
      failureReason = _scenario.badPaths[fwd] ?? _scenario.badPaths[bwd];
    }

    setState(() {
      _isSimulating = true;
      _activePath = pathIds;
      _waypoints = pathIds.map((id) {
        final n = _scenario.nodes.firstWhere((nd) => nd.id == id);
        return Offset(n.x * size.width, n.y * size.height);
      }).toList();
      _leakIndex = leakAt;
      _leakTarget = Offset(size.width * 0.92, size.height * 0.92);
      _lastConnectedEdgeIndex = null;
    });

    _moneyController.forward(from: 0).whenComplete(() {
      final scenarioXP = _calculateScenarioXP();
      
      setState(() {
        _isSuccess = failureReason == null;
        _resultTitle = _isSuccess ? "PAYMENT SECURE" : "PAYMENT FAILED";
        _resultMessage = _isSuccess
            ? "The payment reached the destination through a verified route."
            : "Your money did not arrive safely. Watch the replay to see where it went.\n\n${failureReason ?? ''}";
        _isGameOver = true;
        
        // Add this scenario's XP to total
        if (_isSuccess) {
          _totalXP += scenarioXP;
          // Save progress after each successful scenario (high score system)
          _progressService.saveLevelProgress(6, _totalXP);
        }
      });
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
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
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      return Stack(
                        children: [
                          CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: ConnectionPainter(
                              nodes: _scenario.nodes,
                              connections: _connections,
                              simulating: _isSimulating,
                              hasResult: _isGameOver,
                              isSuccess: _isSuccess,
                              pathIds: _activePath,
                              leakIndex: _leakIndex,
                              lastConnectedEdgeIndex: _lastConnectedEdgeIndex,
                              edgePulseValue: _edgePulseController.value,
                            ),
                          ),
                          ..._scenario.nodes.map((n) => _buildNodeWidget(n, constraints)),
                          if (_isSimulating) _buildMoneyToken(constraints),
                          if (_isInspectMode)
                            Positioned(
                              top: 12, left: 0, right: 0,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.purpleAccent),
                                  ),
                                  child: const Text("Tap a node to reveal details",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
          // ADDED: !_isCutscenePlaying check so tutorial waits for cutscene
          if (_showTutorial && !_isCutscenePlaying) _buildTutorialOverlay(),
          if (_inspectingNode != null) _buildInspectModal(),
          if (_isGameOver) _buildResultModal(),
          Positioned(
            top: 10, left: 10,
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

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.85),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("GOAL: ",
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      Flexible(
                        child: Text(_scenario.goal,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Total XP badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.amber.shade800, Colors.amber.shade600]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('$_totalXP',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(_scenario.context,
              style: const TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM CONTROLS
  // ---------------------------------------------------------------------------
  Widget _buildBottomControls() {
    if (_isSimulating || _isGameOver) return const SizedBox.shrink();
    final spent = _inspectCount <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Inspect
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                if (spent) return;
                setState(() => _isInspectMode = !_isInspectMode);
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: spent
                      ? const Color(0xFF1e293b).withOpacity(0.35)
                      : (_isInspectMode ? Colors.purple[700] : const Color(0xFF1e293b)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: spent ? Colors.grey[800]! : (_isInspectMode ? Colors.purpleAccent : Colors.grey[700]!),
                    width: 2,
                  ),
                  boxShadow: _isInspectMode && !spent
                      ? [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 15)]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, color: spent ? Colors.grey[600] : Colors.white, size: 20),
                    Text("INSPECT ($_inspectCount)",
                        style: TextStyle(color: spent ? Colors.grey[600] : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                return ElevatedButton(
                  onPressed: _canSend
                      ? () {
                          final canvasSize = Size(constraints.maxWidth, 640);
                          _startSimulation(canvasSize);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    disabledBackgroundColor: const Color(0xFF334155),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("SEND PAYMENT",
                          style: TextStyle(fontFamily: 'Orbitron', color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NODE
  // ---------------------------------------------------------------------------
  static const Map<String, IconData> _iconMap = {
    'wallet':   Icons.account_balance_wallet,
    'bank':     Icons.account_balance,
    'link':     Icons.link,
    'app':      Icons.apps,
    'merchant': Icons.store,
    'browser':  Icons.public,
    'person':   Icons.person,
    'warning':  Icons.warning_amber_rounded,
  };

  Widget _buildNodeWidget(GameNode node, BoxConstraints constraints) {
    final isSelected = _selectedNodeId == node.id;

    final (bg, border) = switch (node.nodeType) {
      NodeType.source        => (const Color(0xFF1e3a8a), Colors.blue[500]!),
      NodeType.target        => (const Color(0xFF14532d), Colors.green[500]!),
      NodeType.intermediate  => (const Color(0xFF1e293b), Colors.grey[600]!),
    };

    return Positioned(
      left: node.x * constraints.maxWidth  - 32,
      top:  node.y * constraints.maxHeight - 32,
      child: GestureDetector(
        onTap: () => _handleNodeTap(node),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: bg.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.yellowAccent
                      : (_isInspectMode ? Colors.purpleAccent : border),
                  width: isSelected ? 3 : (_isInspectMode ? 2 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? Colors.yellow.withOpacity(0.4) : Colors.black26,
                    blurRadius: isSelected ? 15 : 5,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                  if (_isInspectMode)
                    BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Icon(
                _isInspectMode ? Icons.search : (_iconMap[node.type] ?? Icons.help_outline),
                color: _isInspectMode ? Colors.purple[200] : Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 78,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f172a).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(node.label,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MONEY TOKEN  +  shared coin builder
  // ---------------------------------------------------------------------------

  /// A single ₹ coin positioned at [pos].
  static Widget _coin(Offset pos, double size, Color color, double opacity) {
    return Positioned(
      left: pos.dx - size / 2,
      top:  pos.dy - size / 2,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: size * 0.35)],
          ),
          child: Center(
            child: Text("₹", style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildMoneyToken(BoxConstraints constraints) {
    if (_waypoints.length < 2) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _moneyController,
      builder: (context, child) {
        final t = _moneyController.value;
        final pos = _interpolatePolyline(_waypoints, t);

        final leakStartT = _leakIndex != null
            ? (_leakIndex! - 1).clamp(0, _waypoints.length - 2) / (_waypoints.length - 1)
            : 2.0;

        final leaked = t > leakStartT;

        return Stack(children: [
          if (_leakIndex != null && _leakTarget != null && leaked)
            () {
              final progress = ((t - leakStartT) / (1.0 - leakStartT)).clamp(0.0, 1.0);
              return _coin(
                  Offset.lerp(_waypoints[_leakIndex!], _leakTarget!, progress)!,
                  24,
                  Colors.red.withOpacity(0.7),
                  1.0 - progress * 0.6);
            }(),
          _coin(pos, 30, leaked ? Colors.redAccent : Colors.greenAccent, 1.0),
        ]);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TUTORIAL
  // ---------------------------------------------------------------------------
  Widget _buildTutorialOverlay() {
    final step  = _tutorialStep;
    final title = step == 0 ? "How to play"   : "Connect nodes";
    final body  = step == 0
        ? "Tap any node to select it.\nIt will glow yellow."
        : "Tap a second node to\ndraw a connection between them.";
    final cta  = step == 0 ? "Got it" : "Start playing";
    final icon = step == 0 ? Icons.touch_app : Icons.timeline;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() {
          if (_tutorialStep == 0) _tutorialStep = 1;
          else _showTutorial = false;
        }),
        child: Container(
          color: Colors.black.withOpacity(0.78),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (i) => Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == step ? Colors.blueAccent : Colors.grey[600],
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 280,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 30, spreadRadius: 4)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.blueAccent, size: 40),
                      const SizedBox(height: 16),
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(body, style: const TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: Text(cta, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INSPECT MODAL
  // ---------------------------------------------------------------------------
  Widget _buildInspectModal() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purpleAccent),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.purpleAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_inspectingNode!.label,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text('"${_inspectingNode!.inspectHint}"',
                        style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
                      onPressed: () => setState(() => _inspectingNode = null),
                      child: const Text("CLOSE", style: TextStyle(color: Colors.white)),
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

  // ---------------------------------------------------------------------------
  // RESULT MODAL
  // ---------------------------------------------------------------------------
  Widget _buildResultModal() {
    final accent     = _isSuccess ? Colors.greenAccent : Colors.redAccent;
    final accentDark = _isSuccess ? Colors.green       : Colors.red;
    final scenarioXP = _calculateScenarioXP();

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0f172a),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: accent)),
                  boxShadow: [BoxShadow(color: accentDark.withOpacity(0.3), blurRadius: 40, spreadRadius: 5)],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isSuccess ? Icons.verified_user : Icons.warning_amber_rounded, size: 50, color: accent),
                        const SizedBox(height: 10),
                        Text(_resultTitle!,
                            style: TextStyle(fontFamily: 'Orbitron', fontSize: 24, fontWeight: FontWeight.bold, color: accent)),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1e293b),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(left: BorderSide(color: accentDark, width: 4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("OUTCOME", style: TextStyle(color: accentDark, fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(_resultMessage!, style: const TextStyle(color: Colors.white)),
                              if (_isSuccess) ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Scenario XP:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    Row(
                                      children: [
                                        const Icon(Icons.stars, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text("+$scenarioXP", 
                                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Total XP:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                    Text("$_totalXP", 
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
                            onPressed: () {
                              if (_isSuccess && _scenarioIndex < levelSixData.length - 1) {
                                _loadScenario(_scenarioIndex + 1);
                              } else if (!_isSuccess) {
                                _loadScenario(_scenarioIndex);
                              } else {
                                // Level complete - final save happens here too (redundant but safe)
                                _progressService.saveLevelProgress(6, _totalXP);
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            child: Text(
                                _isSuccess && _scenarioIndex < levelSixData.length - 1 ? "NEXT SCENARIO"
                                    : (!_isSuccess ? "RETRY" : "FINISH LEVEL"),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Polyline interpolation  –  position at t in [0, 1] along [points]
// ---------------------------------------------------------------------------
Offset _interpolatePolyline(List<Offset> points, double t) {
  if (points.length < 2) return points.first;
  final lengths = <double>[];
  double total = 0;
  for (int i = 0; i < points.length - 1; i++) {
    final len = (points[i + 1] - points[i]).distance;
    lengths.add(len);
    total += len;
  }
  if (total == 0) return points.first;

  double remaining = t * total;
  for (int i = 0; i < lengths.length; i++) {
    if (remaining <= lengths[i])
      return Offset.lerp(points[i], points[i + 1], lengths[i] == 0 ? 0.0 : remaining / lengths[i])!;
    remaining -= lengths[i];
  }
  return points.last;
}

// ---------------------------------------------------------------------------
// ConnectionPainter  –  per-edge green / amber / red, radius-trimmed lines
// ---------------------------------------------------------------------------
class ConnectionPainter extends CustomPainter {
  final List<GameNode> nodes;
  final List<Map<String, String>> connections;
  final bool simulating;
  final bool hasResult;
  final bool isSuccess;
  final List<String> pathIds;
  final int? lastConnectedEdgeIndex;
  final double edgePulseValue;
  final int? leakIndex;

  static const double _r = 32.0;
  static const Set<String> _unknownTypes = {'link', 'browser', 'warning'};

  ConnectionPainter({
    required this.nodes,
    required this.connections,
    required this.simulating,
    required this.hasResult,
    required this.isSuccess,
    required this.pathIds,
    this.lastConnectedEdgeIndex,
    this.edgePulseValue = 0,
    this.leakIndex,
  });

  Color _colorFor(GameNode from, GameNode to, int idx) {
    if (idx == lastConnectedEdgeIndex && edgePulseValue > 0.1)
      return Color.lerp(Colors.white, const Color(0xFF475569), 1.0 - edgePulseValue)!;

    if (!simulating && !hasResult)
      return (_unknownTypes.contains(from.type) || _unknownTypes.contains(to.type))
          ? Colors.amber : const Color(0xFF475569);

    final k1 = '${from.id}->${to.id}';
    final k2 = '${to.id}->${from.id}';
    for (int i = 0; i < pathIds.length - 1; i++) {
      final fwd = '${pathIds[i]}->${pathIds[i + 1]}';
      if (fwd == k1 || fwd == k2)
        return (leakIndex != null && i >= leakIndex! - 1) ? Colors.redAccent : Colors.greenAccent;
    }
    return const Color(0xFF334155);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < connections.length; i++) {
      final from = nodes.firstWhere((n) => n.id == connections[i]['from']);
      final to   = nodes.firstWhere((n) => n.id == connections[i]['to']);
      final p1   = Offset(from.x * size.width, from.y * size.height);
      final p2   = Offset(to.x   * size.width, to.y   * size.height);
      final dist = (p2 - p1).distance;
      if (dist == 0) continue;

      final dir = (p2 - p1) / dist;
      canvas.drawLine(p1 + dir * _r, p2 - dir * _r, Paint()
        ..color     = _colorFor(from, to, i)
        ..strokeWidth = 4
        ..style     = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter old) =>
      old.connections.length != connections.length ||
      old.simulating != simulating ||
      old.hasResult != hasResult ||
      old.isSuccess != isSuccess ||
      old.edgePulseValue != edgePulseValue ||
      old.lastConnectedEdgeIndex != lastConnectedEdgeIndex ||
      old.pathIds.length != pathIds.length;
}