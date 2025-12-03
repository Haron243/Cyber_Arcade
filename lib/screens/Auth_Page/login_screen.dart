// File: lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:demo_app/services/auth_service.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/widgets/Home_Page/custom_glitch_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String _errorMessage = '';

  void _login() async {
    final success = await _authService.loginUser(
      _emailController.text,
      _passwordController.text,
    );
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Invalid credentials. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const CyberBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomGlitchText(text: 'LOGIN', fontSize: 40),
                  const SizedBox(height: 40),
                  _buildTextField(controller: _emailController, hint: 'EMAIL'),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _passwordController, hint: 'PASSWORD', obscure: true),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  const SizedBox(height: 30),
                  CyberButton(text: 'ENTER', onPressed: _login),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'NO ACCOUNT? > REGISTER',
                      style: TextStyle(color: Colors.white70, fontFamily: 'Orbitron'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontFamily: 'Orbitron'),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFF92444))),
      ),
    );
  }
}