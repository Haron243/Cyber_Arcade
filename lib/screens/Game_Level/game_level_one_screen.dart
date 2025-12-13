import 'dart:ui';
import 'package:flutter/material.dart';
// **NEW:** Import AuthService for the logout button in the drawer
import 'package:demo_app/services/auth_service.dart';

// Data model for our website cards
class WebsiteCard {
  final String url;
  final bool isPhishing;

  WebsiteCard({required this.url, required this.isPhishing});
}

//  Converted to a StatefulWidget to manage the drawer's state
class GameLevelOneScreen extends StatefulWidget {
  const GameLevelOneScreen({super.key});

  @override
  State<GameLevelOneScreen> createState() => _GameLevelOneScreenState();
}

class _GameLevelOneScreenState extends State<GameLevelOneScreen> {
  // key to control the Scaffold and open the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Game data
  final List<WebsiteCard> _cards = [
    WebsiteCard(url: 'www.Goo6le.com', isPhishing: true),
    WebsiteCard(url: 'www.amazon.com', isPhishing: false),
    WebsiteCard(url: 'www.facebook.com', isPhishing: false),
    WebsiteCard(url: 'www.micros0ft.com', isPhishing: true),
  ];

  // Game state variables
  int _currentIndex = 0;
  bool? _isCorrect;

  void _makeChoice() {
    setState(() {
      final selectedCard = _cards[_currentIndex];
      _isCorrect = !selectedCard.isPhishing;
    });
  }

  void _handleNextAction() {
    setState(() {
      if (_isCorrect!) {
        print("Navigating to next level (not implemented)");
        _isCorrect = null;
      } else {
        _isCorrect = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Added key and drawer properties to the Scaffold
    return Scaffold(
      key: _scaffoldKey,
      drawer: const _CustomDrawer(),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/game_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 20,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Image.asset(_getCharacterImage()),
          ),
          if (_isCorrect == null) _buildGamePanel(),
          if (_isCorrect != null) _buildResultOverlay(),

          // Hamburger menu icon in the top-left corner (3 horizontal lines)
          Positioned(
            top: 40,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  String _getCharacterImage() {
    if (_isCorrect == null) return 'assets/images/character_neutral.png';
    return _isCorrect!
        ? 'assets/images/character_happy.png'
        : 'assets/images/character_stressed.png';
  }

  Widget _buildGamePanel() {
    return Align(
      alignment: const Alignment(0.5, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.65,
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.4)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'CHOOSE THE LEGIT WEBSITE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Orbitron', color: Colors.red, fontSize: 16,
                    ),
                  ),
                  _buildCardStack(),
                  _gameButton('LEGIT', _makeChoice),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    return SizedBox(
      height: 180,
      width: MediaQuery.of(context).size.width * 0.5,
      child: PageView.builder(
        itemCount: _cards.length,
        controller: PageController(viewportFraction: 0.85),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _currentIndex == index ? 1.0 : 0.85,
            child: Card(
              color: Colors.grey[200],
              child: Center(
                child: Text(
                  _cards[index].url,
                  style: const TextStyle(
                    color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultOverlay() {
    final isSuccess = _isCorrect!;
    return Align(
      alignment: const Alignment(0.5, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.65,
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.4)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'CHOOSE THE LEGIT WEBSITE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Orbitron', color: Colors.red, fontSize: 16,
                    ),
                  ),
                  Card(
                    color: isSuccess ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Text(
                        _cards[_currentIndex].url,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _gameButton(
                    isSuccess ? 'NEXT' : 'RETRY', _handleNextAction,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gameButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Colors.red[400]!),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Orbitron', color: Colors.white, fontSize: 16,
        ),
      ),
    );
  }
}

// Copied the drawer widget from home_screen.dart
class _CustomDrawer extends StatelessWidget {
  const _CustomDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 50),
              ListTile(
                leading: const Icon(Icons.arrow_back, color: Colors.white),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 30),
              _drawerItem(context, 'HOME', () {
                Navigator.pop(context); // Close drawer
                Navigator.pushReplacementNamed(context, '/home'); // Go to home
              }),
              _drawerItem(context, 'CONSULTANT', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/consultant');
              }),
              _drawerItem(context, 'LOGOUT', () {
                AuthService().logoutUser();
                Navigator.pushReplacementNamed(context, '/login');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2, fontSize: 20),
      ),
      onTap: onTap,
    );
  }
}