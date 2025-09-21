import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/widgets/Home_Page/custom_glitch_text.dart';
import 'package:demo_app/widgets/Home_Page/cyber_frame.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: const _CustomDrawer(),
      body: Stack(
        children: [
          // Background Layer (safe)
          const CyberBackground(),

          // Main Content Layer (safe)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const CircleAvatar(
                        backgroundColor: Color(0xFF6CFBFE),
                        radius: 18,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.person, color: Color(0xFF6CFBFE)),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const CustomGlitchText(text: 'CYBER ARCADE'),
                  const SizedBox(height: 8),
                  Text(
                    'GAMIFIED PHISHING AWARENESS',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 50),
                  CyberButton(
                    text: 'CONTINUE',
                    onPressed: () {},
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'V.1.0.1 // SECURITY\n©2025 CYBER PHISHING AWARENESS GAME\nDO NOT DISTRIBUTE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 8,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // THE FIX: This IgnorePointer makes the CyberFrame visible,
          // but allows all clicks and swipes to pass through it.
          const IgnorePointer(
            child: CyberFrame(),
          ),
        ],
      ),
    );
  }
}

// _CustomDrawer class remains the same.
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
              _drawerItem(context, 'CONSULTANT', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/consultant');
              }),
              _drawerItem(context, 'NEW GAME', () {}),
              _drawerItem(context, 'SETTINGS', () {}),
              _drawerItem(context, 'PROGRESS', () {}),
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