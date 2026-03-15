// File: lib/services/user_progress_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static final Map<int, int> _unlockRequirements = {
    2: 500, 3: 600, 4: 100, 5: 200, 6: 400, 7: 300, 8: 90,
  };

  static const int levelOneThreshold = 500; 

  /// Save the score for a specific level to Firestore
  Future<void> saveLevelProgress(int level, int earnedXP) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('levels')
        .doc('level_$level');

    int currentXP = await getLevelXP(level);
    
    // High Score System: Only save if better
    if (earnedXP > currentXP) {
      await docRef.set({
        'level': level,
        'xp': earnedXP,
        'lastPlayed': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update total overall XP profile
      await _firestore.collection('users').doc(user.uid).set({
        'totalXp': FieldValue.increment(earnedXP - currentXP),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// Get the current XP for a level from Firestore
  Future<int> getLevelXP(int level) async {
    final User? user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('levels')
          .doc('level_$level')
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['xp'] ?? 0;
      }
    } catch (e) {
      print("Error fetching XP: $e");
    }
    return 0;
  }

  /// Check if a level is unlocked
  Future<bool> isLevelUnlocked(int level) async {
    if (level <= 1) return true;

    int previousLevel = level - 1;
    int requiredXP = _unlockRequirements[level] ?? 999999;
    int previousLevelXP = await getLevelXP(previousLevel);

    return previousLevelXP >= requiredXP;
  }
}