import 'package:demo_app/screens/Home_Page/home_screen.dart';
import 'package:demo_app/screens/Phishing_Consultant/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
// authentication
import 'package:demo_app/screens/Auth_Page/auth_check_screen.dart';
import 'package:demo_app/screens/Auth_Page/login_screen.dart';
import 'package:demo_app/screens/Auth_Page/register_screen.dart';
// levels
import 'package:demo_app/screens/Game_Level/game_level_one_screen.dart';
import 'package:demo_app/screens/Game_Level/game_level_two_screen.dart';
import 'package:demo_app/screens/Game_Level/game_level_three_screen.dart';
import 'package:demo_app/screens/Game_Level/game_level_four_screen.dart';
import 'package:demo_app/screens/Game_Level/game_level_five_screen.dart';
import 'package:demo_app/screens/Game_Level/game_level_six_screen.dart';
import 'package:demo_app/screens/Game_Level/game_level_seven_screen.dart';
import 'package:demo_app/screens/Game_Level/game_level_eight_screen.dart';
import 'package:demo_app/screens/Game_Level/level_selection_screen.dart';
// For the API Key
import 'package:demo_app/const.dart'; 

// importing firebase folders
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- AUDIO SERVICE IMPORT ---
import 'package:demo_app/services/audio_service.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase using the generated file
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize the Gemini API
  Gemini.init(apiKey: GEMINI_API_KEY);

  // Start the background music globally as soon as the app initializes!
  AudioService().startBGM();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Arcade',
      debugShowCheckedModeBanner: false,
      // Keep the detailed theme from your Cyber Arcade app
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFFF92444),
        fontFamily: 'Orbitron',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          headlineLarge: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold, color: Color(0xFFF92444)),
          titleLarge: TextStyle(fontFamily: 'Orbitron', color: Colors.white),
        ),
      ),
      // Use the routes table for all navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheckScreen(),
        '/mailAnalyzer': (context) => const HomePage(), // consultant main screen
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(), // The main app screen
        '/levelSelection': (context) => const LevelSelectionScreen(),
        '/gameLevelOne': (context) => const GameLevelOneScreen(),
        '/gameLevelTwo': (context) => const GameLevelTwoScreen(),
        '/gameLevelThree': (context) => const GameLevelThreeScreen(),
        '/gameLevelFour': (context) => const GameLevelFourScreen(),
        '/gameLevelFive': (context) => const GameLevelFiveScreen(),
        '/gameLevelSix': (context) => const GameLevelSixScreen(),
        '/gameLevelSeven': (context) => const GameLevelSevenScreen(),
        '/gameLevelEight': (context) => const GameLevelEightScreen(),

      },
    );
  }
}