// File: lib/screens/auth_check_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_app/services/auth_service.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show your cool loading animation while Firebase checks
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF92444)),
            ),
          );
        }

        // Delay navigation slightly so the widget tree can finish building
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.hasData) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });

        // Background while navigating
        return const Scaffold(backgroundColor: Colors.black);
      },
    );
  }
}