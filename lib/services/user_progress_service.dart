// File: lib/services/user_progress_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserProgressService {
  // CONFIGURATION: setting xp requirements for unlocking levels
  
  static final Map<int, int> _unlockRequirements = {
    2: 500, 
    3: 600, 
    4: 100
  };

  // Helper to get threshold for UI
  static const int levelOneThreshold = 500; // Keep for backward compatibility if needed

  /// Save the score for a specific level.
  Future<void> saveLevelProgress(int level, int earnedXP) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'level_${level}_xp'; // Dynamic key generation

    int currentXP = prefs.getInt(key) ?? 0;
    
    // High Score System: Only save if better
    if (earnedXP > currentXP) {
      await prefs.setInt(key, earnedXP);
    }
  }

  /// Get the current XP for a level
  Future<int> getLevelXP(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level_${level}_xp') ?? 0;
  }

  /// Check if a level is unlocked
  Future<bool> isLevelUnlocked(int level) async {
    // Level 1 is always open
    if (level <= 1) return true;

    // To unlock Level [level], you need enough XP in Level [level - 1]
    int previousLevel = level - 1;
    
    // Get the requirement defined in our map. Default to 999999 (impossible) if missing.
    int requiredXP = _unlockRequirements[level] ?? 999999;

    int previousLevelXP = await getLevelXP(previousLevel);

    return previousLevelXP >= requiredXP;
  }
}