import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/data/level_five_data.dart';
import 'package:demo_app/services/user_progress_service.dart';

class GameLevelFiveScreen extends StatefulWidget {
  const GameLevelFiveScreen({super.key});

  @override
  State<GameLevelFiveScreen> createState() => _GameLevelFiveScreenState();
}

class _GameLevelFiveScreenState extends State<GameLevelFiveScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;

  // Scanner State
  Offset _lensPosition = const Offset(100, 100); // Initial lens position
  double _scanProgress = 0.0;
  bool _isScanning = false;
  bool _analysisComplete = false;
  bool _showResult = false;
  bool _isSuccess = false;

  // Layout info for collision detection
  final double _containerHeight = 500; // Fixed height for the interaction area
  late double _containerWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _containerWidth = MediaQuery.of(context).size.width - 40; // Screen width minus padding
  }

  // --- LOGIC ---

  double get _scannerAreaHeight => MediaQuery.of(context).size.height * 0.55;

  void _updateLensPosition(DragUpdateDetails details) {
    if (_analysisComplete) return; // Stop moving if done

    setState(() {
      // Keep lens within bounds
      double newX = (_lensPosition.dx + details.delta.dx).clamp(0.0, _containerWidth);
      double newY = (_lensPosition.dy + details.delta.dy).clamp(0.0, _scannerAreaHeight);
      _lensPosition = Offset(newX, newY);
    });

    _checkCollision();
  }

  void _checkCollision() {
    final scenario = levelFiveData[_currentIndex];
    
    // Convert relative target (0.0-1.0) to absolute pixels
    double targetX = scenario.targetPosition.dx * _containerWidth;
    double targetY = scenario.targetPosition.dy * _scannerAreaHeight;

    // Calculate distance between Lens Center and Target Center
    // Assuming Lens is 150x150, Target is ~100x100
    double dist = (Offset(targetX, targetY) - _lensPosition).distance;

    if (dist < 40) { // Tolerance radius
      _startScanning();
    } else {
      _stopScanning();
    }
  }

  void _startScanning() {
    if (_isScanning || _analysisComplete) return;
    _isScanning = true;

    // Simulate scanning progress
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _scanProgress += 0.05;
      });

      if (_scanProgress >= 1.0) {
        timer.cancel();
        setState(() {
          _isScanning = false;
          _analysisComplete = true;
        });
      }
    });
  }

  void _stopScanning() {
    if (_isScanning) {
      setState(() {
        _isScanning = false;
        _scanProgress = 0.0;
      });
    }
  }

  void _handleDecision(bool userBlocked) {
    final scenario = levelFiveData[_currentIndex];
    bool isCorrect = (userBlocked == scenario.isScam);

    setState(() {
      _isSuccess = isCorrect;
      if (isCorrect) _score += 100;
      _showResult = true;
    });
  }

  void _nextScenario() {
    setState(() {
      _showResult = false;
      _analysisComplete = false;
      _scanProgress = 0.0;
      _lensPosition = const Offset(100, 100); // Reset lens
      if (_currentIndex < levelFiveData.length - 1) {
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
    final scenario = levelFiveData[_currentIndex];

    // This keeps it perfectly sized on all phones.
    final double screenHeight = MediaQuery.of(context).size.height;
    final double scannerHeight = screenHeight * 0.55;

    return Scaffold(
      body: Stack(
        children: [
          const CyberBackground(),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildHUD(),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          // 1. INSTRUCTION
                          if (!_analysisComplete)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                "DRAG LENS TO SCAN TARGET",
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  color: Colors.cyanAccent,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),

                          // 2. INTERACTIVE SCANNER AREA
                          Container(
                            height: scannerHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.grey.shade800),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // A. Background Image (The Context)
                                  Positioned.fill(
                                    child: Image.network(
                                      scenario.contextImageUrl,
                                      fit: BoxFit.cover,
                                      color: Colors.black.withOpacity(0.4),
                                      colorBlendMode: BlendMode.darken,
                                      loadingBuilder: (c, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                    ),
                                  ),

                                  // B. The Hidden QR Sticker
                                  Positioned(
                                    left: (scenario.targetPosition.dx * _containerWidth) - 50, // Center it
                                    top: (scenario.targetPosition.dy * _containerHeight) - 50,
                                    child: Transform.rotate(
                                      angle: -0.1, // Slight tilt like React code
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5)],
                                        ),
                                        child: QrImageView(
                                          data: scenario.qrUrl,
                                          size: 90,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // C. The Draggable Lens
                                  if (!_analysisComplete)
                                    Positioned(
                                      left: _lensPosition.dx - 75, // Center lens (150 width / 2)
                                      top: _lensPosition.dy - 75,
                                      child: GestureDetector(
                                        onPanUpdate: _updateLensPosition,
                                        child: _buildScannerLens(),
                                      ),
                                    ),

                                  // D. Success Overlay (Analysis Complete)
                                  if (_analysisComplete && !_showResult)
                                    Container(
                                      color: Colors.black.withOpacity(0.85),
                                      child: _buildAnalysisReport(scenario),
                                    ),
                                    
                                  // E. Result Overlay (Win/Loss)
                                  if (_showResult)
                                    Container(
                                      color: Colors.black.withOpacity(0.95),
                                      child: _buildResultOverlay(scenario),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          
                          // 3. MISSION BRIEF
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: Colors.cyanAccent, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      scenario.title.toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  scenario.description,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
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
          
          // Back Button
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

  // --- WIDGET COMPONENTS ---

  Widget _buildScannerLens() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.cyanAccent.withOpacity(0.1),
        border: Border.all(color: _isScanning ? Colors.greenAccent : Colors.cyanAccent, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (_isScanning ? Colors.greenAccent : Colors.cyanAccent).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner Markers
          const Positioned(top: 5, left: 5, child: Icon(Icons.crop_free, color: Colors.white, size: 20)),
          const Positioned(bottom: 5, right: 5, child: Icon(Icons.crop_free, color: Colors.white, size: 20)),
          
          if (!_isScanning)
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white70, size: 40),
                Text("DRAG ME", style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),

          if (_isScanning)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: _scanProgress,
                  color: Colors.greenAccent,
                  backgroundColor: Colors.white10,
                ),
                const SizedBox(height: 5),
                Text(
                  "${(_scanProgress * 100).toInt()}%",
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisReport(QrScenario scenario) {
    // Porting the React RiskMeter and Analysis UI
    final int riskScore = scenario.analysis['riskScore'];
    Color riskColor = riskScore > 50 ? Colors.redAccent : Colors.greenAccent;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.cyanAccent, size: 50),
          const SizedBox(height: 10),
          const Text("SCAN COMPLETE", style: TextStyle(fontFamily: 'Orbitron', color: Colors.cyanAccent, fontSize: 20)),
          const SizedBox(height: 20),
          
          // Risk Meter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("THREAT ANALYTICS", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(scenario.analysis['verdict'], style: TextStyle(color: riskColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: riskScore / 100,
                color: riskColor,
                backgroundColor: Colors.grey[800],
                minHeight: 8,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Findings List
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (String finding in scenario.analysis['findings'])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.yellow[700], size: 14),
                        const SizedBox(width: 8),
                        Expanded(child: Text(finding, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Decision Buttons
          Row(
            children: [
              Expanded(
                child: CyberButton(
                  text: "BLOCK",
                  onPressed: () => _handleDecision(true), // User says Block
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => _handleDecision(false), // User says Open
                  child: const Text("OPEN LINK", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultOverlay(QrScenario scenario) {
    Color color = _isSuccess ? Colors.greenAccent : Colors.redAccent;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_isSuccess ? Icons.check_circle : Icons.error, color: color, size: 60),
          const SizedBox(height: 20),
          Text(
            _isSuccess ? "ASSESSMENT CORRECT" : "SYSTEM COMPROMISED",
            style: TextStyle(fontFamily: 'Orbitron', color: color, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            scenario.scamDetails,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 30),
          CyberButton(text: "NEXT LEVEL", onPressed: _nextScenario),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
          ),
          child: Text(
            "LVL 05 // ${_currentIndex + 1}/${levelFiveData.length}",
            style: const TextStyle(fontFamily: 'Orbitron', color: Colors.cyanAccent, fontSize: 12),
          ),
        ),
        const SizedBox(width: 10),
        Text("SCORE: $_score", style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
            border: Border.all(color: Colors.cyanAccent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("TRAINING COMPLETE", style: TextStyle(fontFamily: 'Orbitron', color: Colors.white, fontSize: 22)),
              const SizedBox(height: 20),
              Text("FINAL SCORE: $_score", style: const TextStyle(fontFamily: 'Orbitron', color: Colors.cyanAccent, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              CyberButton(
                text: "RETURN TO BASE",
                onPressed: () async {
                  final service = UserProgressService();
                  await service.saveLevelProgress(5, _score);
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
}