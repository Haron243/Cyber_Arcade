// File: lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:demo_app/services/auth_service.dart';
import 'package:demo_app/widgets/Home_Page/cyber_background.dart';
import 'package:demo_app/widgets/Home_Page/cyber_button.dart';
import 'package:demo_app/widgets/Home_Page/custom_glitch_text.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  String _errorMessage = '';

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    final success = await _authService.registerUser(
      _emailController.text,
      _passwordController.text,
    );
    if (success) {
      // Navigate to login after successful registration
      Navigator.pop(context); 
    } else {
      setState(() => _errorMessage = 'Registration failed. Try again.');
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
                  const CustomGlitchText(text: 'REGISTER', fontSize: 40),
                  const SizedBox(height: 40),
                  _buildTextField(controller: _emailController, hint: 'EMAIL'),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _passwordController, hint: 'PASSWORD', obscure: true),
                  const SizedBox(height: 20),
                  _buildTextField(controller: _confirmPasswordController, hint: 'CONFIRM PASSWORD', obscure: true),
                  const SizedBox(height: 20),
                   if (_errorMessage.isNotEmpty)
                    Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  const SizedBox(height: 30),
                  CyberButton(text: 'CREATE ACCOUNT', onPressed: _register),
                   const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '< BACK TO LOGIN',
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