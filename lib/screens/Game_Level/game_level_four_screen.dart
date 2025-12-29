import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/data/level_four_data.dart';
import 'package:demo_app/services/user_progress_service.dart';

class GameLevelFourScreen extends StatefulWidget {
  const GameLevelFourScreen({super.key});

  @override
  State<GameLevelFourScreen> createState() => _GameLevelFourScreenState();
}

class _GameLevelFourScreenState extends State<GameLevelFourScreen> {
  int _currentIndex = 0;
  int _score = 0;
  
  // Navigation State
  WifiNetwork? _viewingNetwork; // Network currently being inspected
  bool _showResultFeedback = false; // Showing success/fail screen?
  bool _isSuccess = false; // Did they pick the right one?

  // --- LOGIC ---

  void _openDetails(WifiNetwork network) {
    setState(() {
      _viewingNetwork = network;
    });
  }

  void _closeDetails() {
    setState(() {
      _viewingNetwork = null;
    });
  }

  void _attemptConnection() {
    if (_viewingNetwork == null) return;

    final isSafe = !_viewingNetwork!.isTrap;
    
    setState(() {
      _isSuccess = isSafe;
      if (isSafe) _score += 100;
      _showResultFeedback = true;
      // Note: We keep _viewingNetwork active so we can show reasoning related to it
    });
  }

  void _nextScenario() {
    setState(() {
      _showResultFeedback = false;
      _viewingNetwork = null;
      if (_currentIndex < levelFourData.length - 1) {
        _currentIndex++;
      } else {
        _showSummaryDialog();
      }
    });
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSummaryDialog(),
    );
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    final scenario = levelFourData[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          const CyberBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: _buildHUD(),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      constraints: const BoxConstraints(maxWidth: 400),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade800, width: 8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            // 1. Base Layer: Network List
                            _buildNetworkListScreen(scenario),

                            // 2. Overlay Layer: Details Screen (Android Style)
                            if (_viewingNetwork != null && !_showResultFeedback)
                              _buildDetailsScreen(_viewingNetwork!),

                            // 3. Overlay Layer: Feedback (Success/Fail)
                            if (_showResultFeedback)
                              _buildFeedbackScreen(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!_showResultFeedback && _viewingNetwork == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      scenario.hint,
                      style: const TextStyle(color: Colors.cyanAccent, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
          // Back Button (Only show if not in details view)
          if (_viewingNetwork == null)
            Positioned(
              top: 40,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
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

  // --- SUB-SCREENS ---

  Widget _buildNetworkListScreen(WifiScenario scenario) {
    return Column(
      children: [
        // Fake Android Header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1C1C1E),
          child: Row(
            children: [
              const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              const SizedBox(width: 20),
              const Text(
                "Wi-Fi",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Switch(value: true, onChanged: (v) {}, activeColor: Colors.blue),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.black,
          width: double.infinity,
          child: Text(
            "Available Networks",
            style: TextStyle(color: Colors.blue[200], fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: scenario.networks.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: Colors.white24),
              itemBuilder: (context, index) {
                return _buildWifiTile(scenario.networks[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsScreen(WifiNetwork network) {
    return Container(
      color: const Color(0xFF121212), // Android Dark Mode BG
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            color: const Color(0xFF1F1F1F),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _closeDetails,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    network.ssid,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Details List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Icon Header
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wifi, size: 40, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Info Rows
                _buildDetailRow("Signal strength", _getSignalText(network.signalStrength)),
                _buildDetailRow("Frequency", network.frequency),
                _buildDetailRow("Security", network.securityType),
                _buildDetailRow("Standard", network.standard),
                _buildDetailRow("Privacy", network.privacy),
                _buildDetailRow("IP Address", network.ipAddress),
                _buildDetailRow("Gateway", network.gateway),

                const SizedBox(height: 40),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _closeDetails,
                        child: const Text("FORGET", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _attemptConnection,
                        child: const Text("CONNECT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackScreen() {
    return Container(
      color: Colors.black.withOpacity(0.95),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isSuccess ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 80,
            color: _isSuccess ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(height: 20),
          Text(
            _isSuccess ? "SAFE CONNECTION" : "DANGEROUS NETWORK",
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 24,
              color: _isSuccess ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            _viewingNetwork!.reasoning,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          CyberButton(
            text: "NEXT SCENARIO",
            onPressed: _nextScenario,
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildWifiTile(WifiNetwork network) {
    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: () => _openDetails(network),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.wifi, color: Colors.white, size: 24),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      network.ssid,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    if (!network.isSecure)
                      const Text("Unsecured", style: TextStyle(color: Colors.orange, fontSize: 12)),
                  ],
                ),
              ),
              if (network.isSecure)
                const Icon(Icons.lock, color: Colors.white70, size: 16),
              const SizedBox(width: 10),
              const Icon(Icons.settings, color: Colors.blue, size: 20), // Gear icon for details
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "SCORE: $_score",
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.blueAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDialog() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "MISSION COMPLETE",
                style: TextStyle(fontFamily: 'Orbitron', color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              Text(
                "SCORE: $_score",
                style: const TextStyle(fontFamily: 'Orbitron', color: Colors.blueAccent, fontSize: 30),
              ),
              const SizedBox(height: 30),
              CyberButton(
                text: "RETURN TO BASE",
                onPressed: () async {
                  final service = UserProgressService();
                  await service.saveLevelProgress(4, _score);
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSignalText(int strength) {
    if (strength == 4) return "Excellent";
    if (strength == 3) return "Good";
    if (strength == 2) return "Fair";
    return "Weak";
  }
}