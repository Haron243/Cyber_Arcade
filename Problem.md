# Here the game is stuck at the starting screen shown in the screenshot and is not progressing

## level 8 code

```text
// ===========================================================================
// lib/screens/Game_Level/game_level_eight_screen.dart
// ===========================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:demo_app/data/level_eight_data.dart';
import 'package:demo_app/services/user_progress_service.dart';

class GameLevelEightScreen extends StatefulWidget {
  const GameLevelEightScreen({super.key});

  @override
  State<GameLevelEightScreen> createState() => _GameLevelEightScreenState();
}

class _GameLevelEightScreenState extends State<GameLevelEightScreen>
    with TickerProviderStateMixin {
  // --- Services ---
  final UserProgressService _progressService = UserProgressService();

  // --- Scenario state ---
  late EchoScenario _scenario;
  int _scenarioIndex = 0;
  int _totalXP = 0;

  // --- Game state ---
  double _echoVolume = 0;
  int _timeRemaining = 60;
  final List<ChatMessage> _messages = [];
  bool _isGameOver = false;
  bool _isSuccess = false;
  Timer? _gameTimer;
  Timer? _aiTimer;

  // --- Tutorial state ---
  bool _showTutorial = true;
  int _tutorialStep = 0; // 0=intro, 1=forward, 2=react, 3=reply, 4=mute
  bool _tutorialActionCompleted = false;

  // --- UI state ---
  bool _showReplyOptions = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _echoMeterController;

  @override
  void initState() {
    super.initState();
    _echoMeterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    _loadScenario(0);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _aiTimer?.cancel();
    _scrollController.dispose();
    _echoMeterController.dispose();
    super.dispose();
  }

  void _loadScenario(int index) {
    _gameTimer?.cancel();
    _aiTimer?.cancel();

    setState(() {
      _scenarioIndex = index;
      _scenario = levelEightData[index];
      _echoVolume = _scenario.initialEchoVolume;
      _timeRemaining = _scenario.durationSeconds;
      _messages.clear();
      _messages.addAll(_scenario.initialMessages);
      _isGameOver = false;
      _isSuccess = false;
    });

    // Start game loop (only if not tutorial)
    if (!_showTutorial || _tutorialStep >= 5) {
      _startGameLoop();
    }

    // Scroll to bottom after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startGameLoop() {
    // Timer countdown
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining <= 0) {
        timer.cancel();
        _endGame(true); // Win by surviving
        return;
      }

      setState(() {
        _timeRemaining--;
      });

      // Check viral threshold
      if (_echoVolume >= 100) {
        timer.cancel();
        _endGame(false); // Loss by going viral
      }
    });

    // AI member simulation
    _aiTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isGameOver) {
        timer.cancel();
        return;
      }
      _simulateAIMember();
    });
  }

  void _simulateAIMember() {
    // Pick a random member
    final random = Random();
    final member = _scenario.members[random.nextInt(_scenario.members.length)];

    // Check if they engage based on echo volume
    final probability = member.getEngagementProbability(_echoVolume);
    if (random.nextDouble() < probability) {
      final message = ChatMessage(
        senderId: member.id,
        senderName: member.name,
        text: member.getTypicalMessage(_echoVolume),
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(message);

        // Increase echo based on persona
        switch (member.persona) {
          case MemberPersona.sharer:
            _echoVolume = (_echoVolume + 3).clamp(0, 100);
            break;
          case MemberPersona.panicker:
            _echoVolume = (_echoVolume + 4).clamp(0, 100);
            break;
          case MemberPersona.skeptic:
            _echoVolume = (_echoVolume - 2).clamp(0, 100);
            break;
          case MemberPersona.follower:
            _echoVolume = (_echoVolume + 1).clamp(0, 100);
            break;
        }
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- Player Actions ---
  void _handleForward() {
    if (_isGameOver) return;

    setState(() {
      _echoVolume = (_echoVolume + 3).clamp(0, 100);
      _messages.add(ChatMessage(
        senderId: 'player',
        senderName: 'You',
        text: 'Forwarded',
        timestamp: DateTime.now(),
        isPlayerMessage: true,
      ));
    });

    _scrollToBottom();
    _advanceTutorial(1);
  }

  void _handleReact() {
    if (_isGameOver) return;

    setState(() {
      _echoVolume = (_echoVolume + 1).clamp(0, 100);
      _messages.add(ChatMessage(
        senderId: 'player',
        senderName: 'You',
        text: '😮 Reacted',
        timestamp: DateTime.now(),
        isPlayerMessage: true,
      ));
    });

    _scrollToBottom();
    _advanceTutorial(2);
  }

  void _handleReply() {
    if (_isGameOver) return;
    setState(() => _showReplyOptions = true);
    _advanceTutorial(3);
  }

  void _handleMute() {
    if (_isGameOver) return;

    setState(() {
      _echoVolume = (_echoVolume - 5).clamp(0, 100);
      _messages.add(ChatMessage(
        senderId: 'player',
        senderName: 'You',
        text: 'Muted notifications',
        timestamp: DateTime.now(),
        isPlayerMessage: true,
      ));
    });

    _scrollToBottom();
    _advanceTutorial(4);
  }

  void _handleReplyOption(String option, int echoChange) {
    setState(() {
      _showReplyOptions = false;
      _echoVolume = (_echoVolume + echoChange).clamp(0, 100);
      _messages.add(ChatMessage(
        senderId: 'player',
        senderName: 'You',
        text: option,
        timestamp: DateTime.now(),
        isPlayerMessage: true,
      ));
    });

    _scrollToBottom();
  }

  void _advanceTutorial(int actionStep) {
    if (!_showTutorial || _tutorialStep != actionStep) return;

    setState(() {
      _tutorialActionCompleted = true;
    });
  }

  void _nextTutorialStep() {
    if (_tutorialStep < 4) {
      setState(() {
        _tutorialStep++;
        _tutorialActionCompleted = false;
      });
    } else {
      // Tutorial complete
      setState(() {
        _showTutorial = false;
      });
      _startGameLoop();
    }
  }

  void _endGame(bool success) {
    _gameTimer?.cancel();
    _aiTimer?.cancel();

    final scenarioXP = success ? 200 : 50;

    setState(() {
      _isSuccess = success;
      _isGameOver = true;
      _totalXP += scenarioXP;
    });

    // Save progress
    _progressService.saveLevelProgress(8, _totalXP);
  }

  void _nextScenario() {
    if (_scenarioIndex < levelEightData.length - 1) {
      _loadScenario(_scenarioIndex + 1);
    } else {
      // Level complete
      if (mounted) Navigator.pop(context);
    }
  }

  void _retry() {
    _loadScenario(_scenarioIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp beige
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54), // WhatsApp green
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.group, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _scenario.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_scenario.members.length + 1} members',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildEchoMeter(),
              _buildTimer(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE5DD),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _buildChatMessage(_messages[index]),
                  ),
                ),
              ),
              if (!_isGameOver) _buildActionButtons(),
            ],
          ),

          if (_showTutorial) _buildTutorialOverlay(),
          if (_showReplyOptions) _buildReplyOptionsModal(),
          if (_isGameOver) _buildResultModal(),
        ],
      ),
    );
  }

  // --- Echo Meter ---
  Widget _buildEchoMeter() {
    final normalizedVolume = _echoVolume / 100;
    Color meterColor;
    if (_echoVolume < 40) {
      meterColor = Colors.green;
    } else if (_echoVolume < 70) {
      meterColor = Colors.orange;
    } else {
      meterColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Echo Volume',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF606060),
                ),
              ),
              Text(
                '${_echoVolume.toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: meterColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: normalizedVolume,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(meterColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Timer ---
  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFFD9FDD3).withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: _timeRemaining < 10 ? Colors.red : const Color(0xFF606060),
          ),
          const SizedBox(width: 6),
          Text(
            '$_timeRemaining seconds',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _timeRemaining < 10 ? Colors.red : const Color(0xFF606060),
            ),
          ),
        ],
      ),
    );
  }

  // --- Chat Message ---
  Widget _buildChatMessage(ChatMessage message) {
    final isPlayer = message.isPlayerMessage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Align(
        alignment: isPlayer ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isPlayer ? const Color(0xFFDCF8C6) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                topRight: const Radius.circular(8),
                bottomLeft: Radius.circular(isPlayer ? 8 : 0),
                bottomRight: Radius.circular(isPlayer ? 0 : 8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isPlayer)
                  Text(
                    message.senderName,
                    style: TextStyle(
                      color: _getSenderColor(message.senderId),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (!isPlayer) const SizedBox(height: 2),
                Text(
                  message.text,
                  style: const TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSenderColor(String senderId) {
    final colors = [
      const Color(0xFF00897B),
      const Color(0xFF6D4C41),
      const Color(0xFF5E35B1),
      const Color(0xFFD81B60),
      const Color(0xFF00ACC1),
    ];
    return colors[senderId.hashCode.abs() % colors.length];
  }

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // --- Action Buttons ---
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.forward,
            label: 'Forward',
            onTap: _handleForward,
            isHighlighted: _tutorialStep == 1 && !_tutorialActionCompleted,
          ),
          _buildActionButton(
            icon: Icons.emoji_emotions,
            label: 'React',
            onTap: _handleReact,
            isHighlighted: _tutorialStep == 2 && !_tutorialActionCompleted,
          ),
          _buildActionButton(
            icon: Icons.message,
            label: 'Reply',
            onTap: _handleReply,
            isHighlighted: _tutorialStep == 3 && !_tutorialActionCompleted,
          ),
          _buildActionButton(
            icon: Icons.notifications_off,
            label: 'Mute',
            onTap: _handleMute,
            isHighlighted: _tutorialStep == 4 && !_tutorialActionCompleted,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFF075E54).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHighlighted ? const Color(0xFF075E54) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: const Color(0xFF075E54)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF606060),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reply Options Modal ---
  Widget _buildReplyOptionsModal() {
    return GestureDetector(
      onTap: () => setState(() => _showReplyOptions = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Your Reply',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303030),
                  ),
                ),
                const SizedBox(height: 16),
                _buildReplyOption('This sounds serious!', 4),
                _buildReplyOption('Can you share the source?', -3),
                _buildReplyOption('Let\'s verify before spreading.', -2),
                _buildReplyOption('This must be true!', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyOption(String text, int echoChange) {
    final isGood = echoChange < 0;
    return GestureDetector(
      onTap: () => _handleReplyOption(text, echoChange),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isGood ? const Color(0xFFD9FDD3) : const Color(0xFFFFE0E0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isGood ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isGood ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: isGood ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF303030),
                ),
              ),
            ),
            Text(
              '${echoChange > 0 ? '+' : ''}$echoChange',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isGood ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Tutorial Overlay ---
  Widget _buildTutorialOverlay() {
    String title, body;
    IconData icon;

    switch (_tutorialStep) {
      case 0:
        title = 'The Echo Room';
        body = 'Rumors spread fast in group chats.\n\nYour goal: Keep the Echo Volume below 100% for 60 seconds.\n\nEvery action affects how the rumor spreads.';
        icon = Icons.group_outlined;
        break;
      case 1:
        title = 'Forward (+3)';
        body = 'Forwarding spreads the message quickly.\n\nTry tapping Forward now.';
        icon = Icons.forward;
        break;
      case 2:
        title = 'React (+1)';
        body = 'Reacting shows engagement and increases visibility.\n\nTry tapping React now.';
        icon = Icons.emoji_emotions;
        break;
      case 3:
        title = 'Reply (Varies)';
        body = 'Your reply can calm or panic the group.\n\nChoose wisely! Try Reply now.';
        icon = Icons.message;
        break;
      default:
        title = 'Mute (-5)';
        body = 'Muting stops your influence and slows the spread.\n\nTry Mute to complete training.';
        icon = Icons.notifications_off;
    }

    return GestureDetector(
      onTap: _tutorialActionCompleted ? _nextTutorialStep : null,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: const Color(0xFF075E54)),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303030),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF606060),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_tutorialActionCompleted)
                  ElevatedButton(
                    onPressed: _nextTutorialStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075E54),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _tutorialStep == 4 ? 'Start Game' : 'Continue',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Result Modal ---
  Widget _buildResultModal() {
    final scenarioXP = _isSuccess ? 200 : 50;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isSuccess ? Icons.check_circle : Icons.warning_amber_rounded,
                size: 64,
                color: _isSuccess ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _isSuccess ? 'Rumor Contained' : 'Rumor Went Viral',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isSuccess ? _scenario.winMessage : _scenario.lossMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF606060),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Scenario XP:', style: TextStyle(fontSize: 14)),
                        Text(
                          '+$scenarioXP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total XP:', style: TextStyle(fontSize: 14)),
                        Text(
                          '$_totalXP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF303030),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _retry,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF075E54)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Color(0xFF075E54))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextScenario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF075E54),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _scenarioIndex < levelEightData.length - 1 ? 'Next Rumor' : 'Finish',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How It Works'),
        content: const Text(
          'Echo Volume shows how viral the rumor is.\n\n'
          '• Forward: +3\n'
          '• React: +1\n'
          '• Panic Reply: +4\n'
          '• Calm Reply: -2\n'
          '• Ask for Source: -3\n'
          '• Mute: -5\n\n'
          'Keep Echo below 100% to win!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
```

## level 8 data
```text
// ===========================================================================
// lib/data/level_eight_data.dart
// ===========================================================================

/// Represents a chat message in the echo room
class ChatMessage {
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isPlayerMessage;

  ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isPlayerMessage = false,
  });
}

/// AI member persona - determines how they behave
enum MemberPersona {
  sharer,      // Forwards without thinking
  panicker,    // Reacts emotionally
  skeptic,     // Questions things
  follower,    // Does what others do
}

/// An AI chat member
class ChatMember {
  final String id;
  final String name;
  final MemberPersona persona;

  ChatMember({
    required this.id,
    required this.name,
    required this.persona,
  });

  /// Returns how likely (0.0-1.0) this member is to engage based on echo level
  double getEngagementProbability(double echoVolume) {
    switch (persona) {
      case MemberPersona.sharer:
        return (echoVolume / 100) * 0.8; // More likely when echo is high
      case MemberPersona.panicker:
        return echoVolume > 60 ? 0.9 : 0.3; // Reacts strongly to high echo
      case MemberPersona.skeptic:
        return echoVolume > 70 ? 0.5 : 0.1; // Questions when viral
      case MemberPersona.follower:
        return (echoVolume / 100) * 0.6; // Moderate engagement
    }
  }

  /// Returns a message this member would send based on their persona
  String getTypicalMessage(double echoVolume) {
    switch (persona) {
      case MemberPersona.sharer:
        return [
          "Forwarding to everyone!",
          "Sharing this now!",
          "Everyone needs to see this!",
          "Spreading the word!",
        ][DateTime.now().millisecond % 4];
      case MemberPersona.panicker:
        return [
          "OMG this is serious!",
          "We need to act NOW!",
          "This is terrible! 😱",
          "What do we do??",
        ][DateTime.now().millisecond % 4];
      case MemberPersona.skeptic:
        return [
          "Source?",
          "Is this verified?",
          "Sounds suspicious...",
          "Where did this come from?",
        ][DateTime.now().millisecond % 4];
      case MemberPersona.follower:
        return [
          "Really??",
          "Is this true?",
          "Should we be worried?",
          "What's happening?",
        ][DateTime.now().millisecond % 4];
    }
  }
}

/// A complete scenario (one rumor simulation)
class EchoScenario {
  final String id;
  final String title;
  final String rumor;
  final String context; // Backstory
  final List<ChatMember> members;
  final List<ChatMessage> initialMessages; // Pre-loaded messages
  final double initialEchoVolume;
  final int durationSeconds;
  final String winMessage;
  final String lossMessage;

  EchoScenario({
    required this.id,
    required this.title,
    required this.rumor,
    required this.context,
    required this.members,
    required this.initialMessages,
    required this.initialEchoVolume,
    required this.durationSeconds,
    required this.winMessage,
    required this.lossMessage,
  });
}

// ===========================================================================
// SCENARIO DATA
// ===========================================================================

final List<EchoScenario> levelEightData = [
  // Scenario 1: Bank Account Freeze
  EchoScenario(
    id: 'lvl8_bank_freeze',
    title: 'Community Updates',
    rumor: 'Urgent! New government rule will freeze bank accounts tonight! Share fast!',
    context: 'A rumor about bank freezes spreads through a community group.',
    initialEchoVolume: 25,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'Sarah', persona: MemberPersona.sharer),
      ChatMember(id: 'm2', name: 'Mike', persona: MemberPersona.panicker),
      ChatMember(id: 'm3', name: 'Jenny', persona: MemberPersona.skeptic),
      ChatMember(id: 'm4', name: 'Tom', persona: MemberPersona.follower),
      ChatMember(id: 'm5', name: 'Lisa', persona: MemberPersona.sharer),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'Sarah',
        text: 'Urgent! New government rule will freeze bank accounts tonight! Share fast!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Mike',
        text: 'What?? Is this real??',
        timestamp: DateTime.now().subtract(const Duration(seconds: 8)),
      ),
    ],
    winMessage: 'You kept calm and prevented panic. The rumor faded away.',
    lossMessage: 'The rumor went viral. Thousands panicked unnecessarily.',
  ),

  // Scenario 2: Health Restriction
  EchoScenario(
    id: 'lvl8_health_restriction',
    title: 'Neighborhood Watch',
    rumor: 'Breaking: City banning all outdoor exercise starting tomorrow. Officials confirm.',
    context: 'A fake health restriction spreads fear in a local community.',
    initialEchoVolume: 30,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'David', persona: MemberPersona.panicker),
      ChatMember(id: 'm2', name: 'Emma', persona: MemberPersona.sharer),
      ChatMember(id: 'm3', name: 'Ryan', persona: MemberPersona.follower),
      ChatMember(id: 'm4', name: 'Olivia', persona: MemberPersona.skeptic),
      ChatMember(id: 'm5', name: 'Chris', persona: MemberPersona.sharer),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'David',
        text: 'Breaking: City banning all outdoor exercise starting tomorrow. Officials confirm.',
        timestamp: DateTime.now().subtract(const Duration(seconds: 12)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Emma',
        text: 'No way! This can\'t be true!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 9)),
      ),
      ChatMessage(
        senderId: 'm5',
        senderName: 'Chris',
        text: 'Forwarding to my running group',
        timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
      ),
    ],
    winMessage: 'You encouraged verification. The fake restriction was debunked.',
    lossMessage: 'False alarm spread city-wide. Gyms flooded with calls.',
  ),

  // Scenario 3: Celebrity Scandal
  EchoScenario(
    id: 'lvl8_celebrity_scandal',
    title: 'Entertainment News',
    rumor: 'EXCLUSIVE: Famous actor arrested at airport! Video proof inside!',
    context: 'Celebrity gossip spreads rapidly through fan groups.',
    initialEchoVolume: 35,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'Alex', persona: MemberPersona.sharer),
      ChatMember(id: 'm2', name: 'Jordan', persona: MemberPersona.sharer),
      ChatMember(id: 'm3', name: 'Taylor', persona: MemberPersona.follower),
      ChatMember(id: 'm4', name: 'Morgan', persona: MemberPersona.panicker),
      ChatMember(id: 'm5', name: 'Casey', persona: MemberPersona.skeptic),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'Alex',
        text: 'EXCLUSIVE: Famous actor arrested at airport! Video proof inside!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 15)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Jordan',
        text: 'OMG sharing everywhere!!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 11)),
      ),
      ChatMessage(
        senderId: 'm4',
        senderName: 'Morgan',
        text: 'I can\'t believe it! 😱',
        timestamp: DateTime.now().subtract(const Duration(seconds: 7)),
      ),
    ],
    winMessage: 'You slowed the gossip. The actor\'s team issued a denial.',
    lossMessage: 'Baseless rumor trended worldwide. Actor\'s reputation damaged.',
  ),

  // Scenario 4: Product Recall
  EchoScenario(
    id: 'lvl8_product_recall',
    title: 'Parent Group',
    rumor: 'URGENT: Popular baby formula contains toxic chemicals. Recall announced!',
    context: 'A fake product recall causes panic among parents.',
    initialEchoVolume: 40,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'Rachel', persona: MemberPersona.panicker),
      ChatMember(id: 'm2', name: 'Steve', persona: MemberPersona.sharer),
      ChatMember(id: 'm3', name: 'Maria', persona: MemberPersona.panicker),
      ChatMember(id: 'm4', name: 'Kevin', persona: MemberPersona.follower),
      ChatMember(id: 'm5', name: 'Nina', persona: MemberPersona.skeptic),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'Rachel',
        text: 'URGENT: Popular baby formula contains toxic chemicals. Recall announced!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 18)),
      ),
      ChatMessage(
        senderId: 'm3',
        senderName: 'Maria',
        text: 'Oh no!! I just bought this yesterday!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 14)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Steve',
        text: 'Sending to all parents I know!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
      ),
      ChatMessage(
        senderId: 'm4',
        senderName: 'Kevin',
        text: 'This is scary...',
        timestamp: DateTime.now().subtract(const Duration(seconds: 6)),
      ),
    ],
    winMessage: 'You asked for sources. The company confirmed no recall exists.',
    lossMessage: 'Panic spread. Stores overwhelmed. Company stock crashed.',
  ),

  // Scenario 5: Weather Emergency
  EchoScenario(
    id: 'lvl8_weather_emergency',
    title: 'Local Area Alert',
    rumor: 'BREAKING: Tsunami warning issued for our coast! Evacuate immediately!',
    context: 'A fake weather emergency spreads in a coastal town.',
    initialEchoVolume: 45,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'Ben', persona: MemberPersona.sharer),
      ChatMember(id: 'm2', name: 'Amy', persona: MemberPersona.panicker),
      ChatMember(id: 'm3', name: 'Lucas', persona: MemberPersona.sharer),
      ChatMember(id: 'm4', name: 'Sophie', persona: MemberPersona.panicker),
      ChatMember(id: 'm5', name: 'Jack', persona: MemberPersona.skeptic),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'Ben',
        text: 'BREAKING: Tsunami warning issued for our coast! Evacuate immediately!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Amy',
        text: 'EVERYONE GET OUT NOW!! 🌊',
        timestamp: DateTime.now().subtract(const Duration(seconds: 16)),
      ),
      ChatMessage(
        senderId: 'm4',
        senderName: 'Sophie',
        text: 'Grabbing my kids!!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 12)),
      ),
      ChatMessage(
        senderId: 'm3',
        senderName: 'Lucas',
        text: 'Forwarding to everyone in town!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 8)),
      ),
    ],
    winMessage: 'You stayed calm. Official channels confirmed no tsunami threat.',
    lossMessage: 'Mass evacuation chaos. Roads gridlocked. False alarm cost millions.',
  ),
];
```