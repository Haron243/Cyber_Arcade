// File: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // CHANGED: Use the singleton instance instead of the unnamed constructor
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Stream for listening to auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if a user is currently logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // Register a new user with Firebase
  Future<bool> registerUser(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print('User registered in Firebase: $email');
      return true;
    } catch (e) {
      print('Firebase Registration Error: $e');
      return false;
    }
  }

  // Log in an existing user with Firebase
  Future<bool> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Firebase Login successful for: $email');
      return true;
    } catch (e) {
      print('Firebase Login Error: $e');
      return false;
    }
  }

  // NEW: Google Sign-In Logic (Updated for google_sign_in v7+)
  Future<bool> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return false; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // CHANGED: We removed the accessToken parameter completely.
      // Firebase only requires the idToken to verify the user's identity!
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      print('Google Sign-In successful');
      return true;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return false;
    }
  }

  // Log out the current user
  Future<void> logoutUser() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore errors here if the user wasn't originally signed in via Google
    }
    await _auth.signOut();
    print('User logged out from Firebase');
  }
}