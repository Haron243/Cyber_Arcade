// File: lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';

  // Check if a user is currently logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Register a new user
  Future<bool> registerUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    // In a real app, you'd check if the email is already taken.
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    print('User registered: $email');
    return true;
  }

  // Log in an existing user
  Future<bool> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_emailKey);
    final storedPassword = prefs.getString(_passwordKey);

    if (email == storedEmail && password == storedPassword) {
      await prefs.setBool(_isLoggedInKey, true);
      print('Login successful for: $email');
      return true;
    }
    print('Login failed for: $email');
    return false;
  }

  // Log out the current user
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    print('User logged out');
  }
}