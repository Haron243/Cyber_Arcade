import 'package:flutter/material.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/info_card.dart';
// import 'package:demo_app/screens/Phishing_Consultant/home_page.dart';

class ConsultantScreen extends StatelessWidget {
  const ConsultantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const CyberBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Custom App Bar
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'IRL TOOLS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, letterSpacing: 4),
                  ),
                  const SizedBox(height: 40),
                  InfoCard(
                    title: 'MAIL ANALYZER',
                    description: 'ANALYZE ANY LINK IN SECONDS, DETECT PHISHING ATTEMPTS, SUSPICIOUS DOMAINS, UNSAFE REDIRECTS, AND ENSURE THE WEBSITE IS TRUSTWORTHY BEFORE VISITING.',
                    onPressed: () {
                     Navigator.pushNamed(context, '/mailAnalyzer');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}