import 'dart:async';
import 'dart:math'; // Added for random calculations
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/data/level_five_data.dart';
import 'package:demo_app/services/user_progress_service.dart';
import 'package:demo_app/screens/Game_Level/cutscene_screen.dart';

class GameLevelFiveScreen extends StatefulWidget {
  const GameLevelFiveScreen({super.key});

  @override
  State<GameLevelFiveScreen> createState() => _GameLevelFiveScreenState();
}

class _GameLevelFiveScreenState extends State<GameLevelFiveScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;

  // --- AR Camera State ---
  Offset _cameraOffset = Offset.zero; 
  // INCREASED ZOOM: Gives more panning room and makes the QR code larger
  final double _zoomLevel = 2.4; 
  StreamSubscription<GyroscopeEvent>? _gyroSubscription; 
  
  // Store a random pixel offset from the center
  late Offset _randomCenterOffset;
  
  // --- Game State ---
  bool _isScanning = false;
  double _scanProgress = 0.0;
  bool _analysisComplete = false;
  bool _showResult = false;
  bool _isSuccess = false;
  bool _showTutorial = true;

  bool _isCutscenePlaying = true; // for cutscene play checking

  // --- Animation ---
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _generateRandomTarget(); // Generate the first position

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scanLineAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(_scanLineController);

    // REMOVED: _initGyroscope() is no longer here!
    
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
        pageBuilder: (context, animation, secondaryAnimation) => const CutsceneScreen(levelId: 5),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      // WHEN CUTSCENE ENDS: Allow touch interactions and start the Gyroscope!
      setState(() {
        _isCutscenePlaying = false;
      });
      _initGyroscope(); 
    });
  }

  // Generates a point within a safe, reachable radius of the center
  void _generateRandomTarget() {
    final random = Random();
    
    // 1. Generate a random angle (0 to 360 degrees in radians)
    double angle = random.nextDouble() * 2 * pi;
    
    // 2. SAFE RADIUS: Reduced to 100 pixels to ensure it never spawns outside the pan limits
    double radius = sqrt(random.nextDouble()) * 100; 
    
    // 3. Convert polar coordinates to X and Y offsets
    double dx = radius * cos(angle);
    double dy = radius * sin(angle);

    _randomCenterOffset = Offset(dx, dy);
  }

  // NEW HELPER: Handles moving the camera securely within limits for BOTH Gyro and Touch
  void _updateCameraOffset(double deltaX, double deltaY) {
    if (!mounted) return;
    
    final size = MediaQuery.of(context).size;
    final viewportWidth = size.width;
    final viewportHeight = size.height * 0.6; // 60% of screen

    // Calculate Limits based on the zoom
    double limitX = (viewportWidth * _zoomLevel - viewportWidth) / 2;
    double limitY = (viewportHeight * _zoomLevel - viewportHeight) / 2;

    setState(() {
      _cameraOffset = Offset(
        (_cameraOffset.dx + deltaX).clamp(-limitX, limitX),
        (_cameraOffset.dy + deltaY).clamp(-limitY, limitY),
      );
    });

    _checkAlignment(size);
  }

  void _initGyroscope() {
    _gyroSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (_analysisComplete || _showTutorial || !mounted) return;

      // SENSITIVITY
      const double sensitivity = 25.0; 
      
      // Calculate delta from gyro and feed to the shared offset updater
      double dx = event.y * sensitivity;
      double dy = event.x * sensitivity;
      
      _updateCameraOffset(dx, dy);
    });
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _gyroSubscription?.cancel();
    super.dispose();
  }

  // --- LOGIC ---

  void _checkAlignment(Size screenSize) {
    if (_showTutorial || _analysisComplete) return;

    final double viewportHeight = screenSize.height * 0.6;

    // 1. Calculate Image Dimensions
    double imgWidth = screenSize.width * _zoomLevel;
    double imgHeight = viewportHeight * _zoomLevel;
    
    // 2. Calculate QR Position relative to Image Center + Random Offset
    double qrImgX = (imgWidth / 2) + (_randomCenterOffset.dx * _zoomLevel);
    double qrImgY = (imgHeight / 2) + (_randomCenterOffset.dy * _zoomLevel);
    
    // 3. Calculate Image Top-Left relative to Viewport Center
    double imgLeft = (screenSize.width - imgWidth) / 2 + _cameraOffset.dx;
    double imgTop = (viewportHeight - imgHeight) / 2 + _cameraOffset.dy;
    
    // 4. Final Screen Coordinates of the QR Center
    double qrScreenX = imgLeft + qrImgX;
    double qrScreenY = imgTop + qrImgY;
    
    // 5. Viewfinder Center
    double viewCenterX = screenSize.width / 2;
    double viewCenterY = viewportHeight / 2;
    
    // 6. Calculate Distance
    double dist = (Offset(qrScreenX, qrScreenY) - Offset(viewCenterX, viewCenterY)).distance;
    
    // Threshold: 60px radius
    if (dist < 60) {
      _startScanning();
    } else {
      _stopScanning();
    }
  }

  void _startScanning() {
    if (_isScanning || _analysisComplete) return;
    _isScanning = true;

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }
      
      setState(() => _scanProgress += 0.04); 

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

  void _handleDecision(bool userSaysScam) {
    final scenario = levelFiveData[_currentIndex];
    bool isCorrect = (userSaysScam == scenario.isScam);

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
      _cameraOffset = Offset.zero;
      
      _generateRandomTarget(); // Generate new random spot for the next level
      
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

  // --- UI CONSTRUCTION ---

  @override
  Widget build(BuildContext context) {
    final scenario = levelFiveData[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const CyberBackground(),
          
          Column(
            children: [
              // 1. HUD HEADER
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildHUD(),
                ),
              ),

              // 2. AR CAMERA VIEWPORT
              Expanded(
                flex: 6, 
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade800),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black,
                  ),
                  child: LayoutBuilder( 
                    builder: (context, constraints) {
                      // ADDED: GestureDetector to support drag/touch controls
                      return GestureDetector(
                        onPanUpdate: (details) {
                          if (_analysisComplete || _showTutorial || _isCutscenePlaying) return;
                          // Pass touch drag delta directly to our shared movement logic
                          _updateCameraOffset(details.delta.dx, details.delta.dy);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // A. The "World" (Image + QR)
                            Transform.translate(
                              offset: _cameraOffset, 
                              child: Transform.scale(
                                scale: _zoomLevel,
                                child: Stack(
                                  children: [
                                    // Context Image
                                    Positioned.fill(
                                      child: Image.network(
                                        scenario.contextImageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (ctx, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                                        },
                                        errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[900]),
                                      ),
                                    ),
                                    
                                    // QR Sticker (Anchored to Center + Random Offset)
                                    Positioned(
                                      left: (constraints.maxWidth / 2) + _randomCenterOffset.dx - 40,
                                      top: (constraints.maxHeight / 2) + _randomCenterOffset.dy - 40,
                                      child: _buildQrSticker(scenario.qrUrl),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      
                            // B. Viewfinder Overlay
                            ColorFiltered(
                              colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      backgroundBlendMode: BlendMode.dstOut,
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: 220, height: 220,
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      
                            // C. HUD Elements
                            Center(
                              child: Container(
                                width: 220, height: 220,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isScanning ? Colors.greenAccent : Colors.cyanAccent.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  children: [
                                    const Positioned(top: 10, left: 10, child: Icon(Icons.crop_free, color: Colors.white, size: 30)),
                                    const Positioned(bottom: 10, right: 10, child: Icon(Icons.crop_free, color: Colors.white, size: 30)),
                                    
                                    if (_isScanning)
                                      AnimatedBuilder(
                                        animation: _scanLineAnimation,
                                        builder: (context, child) {
                                          return Align(
                                            alignment: Alignment(0, _scanLineAnimation.value * 2 - 1),
                                            child: Container(
                                              height: 2, width: double.infinity,
                                              decoration: const BoxDecoration(
                                                color: Colors.redAccent,
                                                boxShadow: [BoxShadow(color: Colors.red, blurRadius: 5)],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                      
                            // D. Scanning Text
                            if (_isScanning)
                              Positioned(
                                top: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                                  child: Text("ANALYZING... ${(_scanProgress * 100).toInt()}%",
                                    style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Orbitron', fontSize: 12)),
                                ),
                              ),
                              
                            // Overlays
                            if (_analysisComplete && !_showResult)
                               Positioned.fill(child: Container(color: Colors.black.withOpacity(0.9), child: _buildAnalysisReport(scenario))),
                            if (_showResult)
                               Positioned.fill(child: Container(color: Colors.black.withOpacity(0.95), child: _buildResultOverlay(scenario))),
                          ],
                        ),
                      );
                    }
                  ),
                ),
              ),

              // 3. BOTTOM PANEL
              Expanded(
                flex: 3, 
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scenario.title.toUpperCase(), style: const TextStyle(fontFamily: 'Orbitron', fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(scenario.description, style: const TextStyle(color: Colors.white70, height: 1.5)),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(Icons.touch_app, color: Colors.cyanAccent, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "TILT OR DRAG TO AIM CAMERA", 
                            style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 4. TUTORIAL
          if (_showTutorial) _buildTutorial(),
          
          Positioned(top: 50, left: 20, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)))),
        ],
      ),
    );
  }

  // --- SUB WIDGETS ---
  
  Widget _buildQrSticker(String data) {
    return Transform.rotate(
      angle: -0.1,
      child: Container(
        width: 80, height: 80,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: QrImageView(data: data, size: 72),
      ),
    );
  }

  Widget _buildAnalysisReport(QrScenario scenario) {
     final int riskScore = scenario.analysis['riskScore'];
    Color riskColor = riskScore > 50 ? const Color(0xFFF92444) : Colors.greenAccent;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.travel_explore, color: Colors.cyanAccent, size: 40),
          const SizedBox(height: 16),
          const Text("SCAN COMPLETE", style: TextStyle(fontFamily: 'Orbitron', fontSize: 20, color: Colors.white)),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                _buildDataRow("DETECTED URL", scenario.qrUrl),
                const Divider(color: Colors.white10),
                _buildDataRow("THREAT LEVEL", scenario.threatLevel, color: riskColor),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                const Align(alignment: Alignment.centerLeft, child: Text("FINDINGS:", style: TextStyle(color: Colors.grey, fontSize: 10))),
                ...scenario.analysis['findings'].map((f) => 
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 14),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                      ],
                    ),
                  )
                ).toList(),
              ],
            ),
          ),
          
          const Spacer(),
          
          Row(
            children: [
              Expanded(child: CyberButton(text: "BLOCK LINK", onPressed: () => _handleDecision(true))),
              const SizedBox(width: 16),
              Expanded(
                child: TextButton(
                  onPressed: () => _handleDecision(false),
                  child: const Text("OPEN LINK", style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
  
  Widget _buildDataRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        Flexible(child: Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildResultOverlay(QrScenario scenario) {
    bool win = _isSuccess;
    Color color = win ? Colors.greenAccent : const Color(0xFFF92444);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(win ? Icons.verified : Icons.dangerous, size: 80, color: color),
        const SizedBox(height: 20),
        Text(win ? "THREAT NEUTRALIZED" : "SYSTEM COMPROMISED", 
          style: TextStyle(fontFamily: 'Orbitron', fontSize: 22, color: color, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(scenario.scamDetails, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, height: 1.5)),
        ),
        const SizedBox(height: 30),
        CyberButton(text: "CONTINUE", onPressed: _nextScenario),
      ],
    );
  }

  Widget _buildTutorial() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showTutorial = false),
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.threed_rotation, size: 60, color: Colors.cyanAccent),
                const SizedBox(height: 20),
                const Text("SCANNER READY", style: TextStyle(fontFamily: 'Orbitron', fontSize: 24, color: Colors.white)),
                const SizedBox(height: 20),
                Container(
                  width: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                  child: const Column(
                    children: [
                      Text("1. Tilt or drag screen to look around", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 10),
                      Text("2. Frame the QR code in the box", style: TextStyle(color: Colors.white)),
                      SizedBox(height: 10),
                      Text("3. Keep steady to scan", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text("TAP TO START", style: TextStyle(color: Colors.cyanAccent, letterSpacing: 2)),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF92444).withOpacity(0.2),
            border: Border.all(color: const Color(0xFFF92444)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text("TARGETS: ${_currentIndex + 1}/${levelFiveData.length}", style: const TextStyle(fontFamily: 'Orbitron', color: Color(0xFFF92444), fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Text("XP: $_score", style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white, fontSize: 16)),
      ],
    );
  }
}