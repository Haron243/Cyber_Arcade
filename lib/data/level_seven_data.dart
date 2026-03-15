// ===========================================================================
// lib/data/level_seven_data.dart
// ===========================================================================

/// Represents a single inspection check that can be performed on an app.
class VettingCheck {
  final String id;
  final String name;
  final String icon; // emoji or icon identifier
  final int cost;
  final String clueText;
  
  /// How much this clue contributes to suspicion (0.0 = safe, 1.0 = very risky).
  /// Multiple checks' weights are averaged to compute overall suspicion.
  final double suspicionWeight;

  VettingCheck({
    required this.id,
    required this.name,
    required this.icon,
    required this.cost,
    required this.clueText,
    required this.suspicionWeight,
  });
}

/// An app waiting for approval in the app store queue.
class VettingApp {
  final String id;
  final String name;
  final String category;
  final double starRating;
  final String downloads;
  
  /// Ground truth: is this app actually malicious?
  final bool isRisky;
  
  /// Available checks for this app.
  final List<VettingCheck> checks;

  VettingApp({
    required this.id,
    required this.name,
    required this.category,
    required this.starRating,
    required this.downloads,
    required this.isRisky,
    required this.checks,
  });
}

/// A complete scenario (one round of the game).
class VettingScenario {
  final String id;
  final String title;
  final String context;
  final int initialTokens;
  final List<VettingApp> apps;

  VettingScenario({
    required this.id,
    required this.title,
    required this.context,
    required this.initialTokens,
    required this.apps,
  });
}

// ===========================================================================
// SCENARIO DATA
// ===========================================================================

final List<VettingScenario> levelSevenData = [
  // -------------------------------------------------------------------------
  // SCENARIO 1: Tutorial / Easy
  // 5 apps, 12 tokens, 2 risky
  // -------------------------------------------------------------------------
  VettingScenario(
    id: 'lvl7_01',
    title: "Morning Shift",
    context: "You have 12 vetting tokens. New apps are waiting. Choose wisely — you can't check everything.",
    initialTokens: 12,
    apps: [
      // --- SAFE APP 1 ---
      VettingApp(
        id: 'flashlight_pro',
        name: 'Flashlight Pro',
        category: 'Tools',
        starRating: 4.6,
        downloads: '10K+',
        isRisky: false,
        checks: [
          VettingCheck(
            id: 'dev_info',
            name: 'Developer Info',
            icon: '💳',
            cost: 2,
            clueText: 'Established developer (4 years, 12 apps)',
            suspicionWeight: 0.1,
          ),
          VettingCheck(
            id: 'permissions',
            name: 'App Permissions',
            icon: '🔐',
            cost: 2,
            clueText: 'Requests: Camera, Flashlight',
            suspicionWeight: 0.2,
          ),
          VettingCheck(
            id: 'reviews',
            name: 'User Reviews',
            icon: '⭐',
            cost: 2,
            clueText: 'Mostly positive, detailed reviews',
            suspicionWeight: 0.1,
          ),
          VettingCheck(
            id: 'behavior',
            name: 'App Behavior',
            icon: '📊',
            cost: 3,
            clueText: 'Standard background activity',
            suspicionWeight: 0.0,
          ),
        ],
      ),

      // --- RISKY APP 1 ---
      VettingApp(
        id: 'speed_booster',
        name: 'Speed Booster',
        category: 'Utility',
        starRating: 4.9, // fake high rating
        downloads: '100K+',
        isRisky: true,
        checks: [
          VettingCheck(
            id: 'dev_info',
            name: 'Developer Info',
            icon: '💳',
            cost: 2,
            clueText: 'New developer (registered 4 days ago)',
            suspicionWeight: 0.8,
          ),
          VettingCheck(
            id: 'permissions',
            name: 'App Permissions',
            icon: '🔐',
            cost: 2,
            clueText: 'Requests: Contacts, SMS, Storage, Location',
            suspicionWeight: 0.9,
          ),
          VettingCheck(
            id: 'reviews',
            name: 'User Reviews',
            icon: '⭐',
            cost: 2,
            clueText: 'Many short reviews posted on the same day',
            suspicionWeight: 0.7,
          ),
          VettingCheck(
            id: 'behavior',
            name: 'App Behavior',
            icon: '📊',
            cost: 3,
            clueText: 'High network activity in background',
            suspicionWeight: 1.0,
          ),
        ],
      ),

      // --- SAFE APP 2 ---
      VettingApp(
        id: 'calculator_plus',
        name: 'Calculator+',
        category: 'Productivity',
        starRating: 4.4,
        downloads: '50K+',
        isRisky: false,
        checks: [
          VettingCheck(
            id: 'dev_info',
            name: 'Developer Info',
            icon: '💳',
            cost: 2,
            clueText: 'Established developer (2 years, 5 apps)',
            suspicionWeight: 0.2,
          ),
          VettingCheck(
            id: 'permissions',
            name: 'App Permissions',
            icon: '🔐',
            cost: 2,
            clueText: 'Requests: Storage (for saving calculations)',
            suspicionWeight: 0.1,
          ),
          VettingCheck(
            id: 'reviews',
            name: 'User Reviews',
            icon: '⭐',
            cost: 2,
            clueText: 'Positive reviews, some feature requests',
            suspicionWeight: 0.0,
          ),
          VettingCheck(
            id: 'behavior',
            name: 'App Behavior',
            icon: '📊',
            cost: 3,
            clueText: 'No network activity, offline-only',
            suspicionWeight: 0.0,
          ),
        ],
      ),

      // --- RISKY APP 2 ---
      VettingApp(
        id: 'quick_loan',
        name: 'Quick Loan App',
        category: 'Finance',
        starRating: 4.1,
        downloads: '5K+',
        isRisky: true,
        checks: [
          VettingCheck(
            id: 'dev_info',
            name: 'Developer Info',
            icon: '💳',
            cost: 2,
            clueText: 'Developer registered 1 week ago',
            suspicionWeight: 0.7,
          ),
          VettingCheck(
            id: 'permissions',
            name: 'App Permissions',
            icon: '🔐',
            cost: 2,
            clueText: 'Requests: Contacts, SMS, Call logs, Camera, Location',
            suspicionWeight: 1.0,
          ),
          VettingCheck(
            id: 'reviews',
            name: 'User Reviews',
            icon: '⭐',
            cost: 2,
            clueText: 'Mixed reviews, some complaints about spam calls',
            suspicionWeight: 0.8,
          ),
          VettingCheck(
            id: 'behavior',
            name: 'App Behavior',
            icon: '📊',
            cost: 3,
            clueText: 'Sends data to unknown servers',
            suspicionWeight: 1.0,
          ),
        ],
      ),

      // --- SAFE APP 3 ---
      VettingApp(
        id: 'weather_today',
        name: 'Weather Today',
        category: 'Weather',
        starRating: 4.7,
        downloads: '200K+',
        isRisky: false,
        checks: [
          VettingCheck(
            id: 'dev_info',
            name: 'Developer Info',
            icon: '💳',
            cost: 2,
            clueText: 'Well-known developer (6 years, 20+ apps)',
            suspicionWeight: 0.0,
          ),
          VettingCheck(
            id: 'permissions',
            name: 'App Permissions',
            icon: '🔐',
            cost: 2,
            clueText: 'Requests: Location (for local weather)',
            suspicionWeight: 0.1,
          ),
          VettingCheck(
            id: 'reviews',
            name: 'User Reviews',
            icon: '⭐',
            cost: 2,
            clueText: 'Highly rated, consistent positive feedback',
            suspicionWeight: 0.0,
          ),
          VettingCheck(
            id: 'behavior',
            name: 'App Behavior',
            icon: '📊',
            cost: 3,
            clueText: 'Connects to official weather API only',
            suspicionWeight: 0.0,
          ),
        ],
      ),
    ],
  ),

  // -------------------------------------------------------------------------
  // SCENARIO 2: Medium Difficulty
  // 7 apps, 14 tokens, 3 risky
  // -------------------------------------------------------------------------
  VettingScenario(
    id: 'lvl7_02',
    title: "Busy Day",
    context: "Higher volume today. 14 tokens for 7 apps. Prioritize carefully.",
    initialTokens: 14,
    apps: [
      VettingApp(
        id: 'note_keeper',
        name: 'Note Keeper',
        category: 'Productivity',
        starRating: 4.5,
        downloads: '30K+',
        isRisky: false,
        checks: [
          VettingCheck(id: 'dev_info', name: 'Developer Info', icon: '💳', cost: 2, clueText: 'Established (3 years)', suspicionWeight: 0.1),
          VettingCheck(id: 'permissions', name: 'App Permissions', icon: '🔐', cost: 2, clueText: 'Storage, Camera', suspicionWeight: 0.2),
          VettingCheck(id: 'reviews', name: 'User Reviews', icon: '⭐', cost: 2, clueText: 'Good feedback', suspicionWeight: 0.1),
          VettingCheck(id: 'behavior', name: 'App Behavior', icon: '📊', cost: 3, clueText: 'Minimal background use', suspicionWeight: 0.1),
        ],
      ),
      VettingApp(
        id: 'fake_vpn',
        name: 'Free VPN Master',
        category: 'Tools',
        starRating: 4.8,
        downloads: '500K+',
        isRisky: true,
        checks: [
          VettingCheck(id: 'dev_info', name: 'Developer Info', icon: '💳', cost: 2, clueText: 'New developer (5 days)', suspicionWeight: 0.9),
          VettingCheck(id: 'permissions', name: 'App Permissions', icon: '🔐', cost: 2, clueText: 'ALL permissions requested', suspicionWeight: 1.0),
          VettingCheck(id: 'reviews', name: 'User Reviews', icon: '⭐', cost: 2, clueText: 'Fake reviews detected', suspicionWeight: 0.9),
          VettingCheck(id: 'behavior', name: 'App Behavior', icon: '📊', cost: 3, clueText: 'Connects to suspicious IPs', suspicionWeight: 1.0),
        ],
      ),
      VettingApp(
        id: 'music_player',
        name: 'Simple Music',
        category: 'Media',
        starRating: 4.3,
        downloads: '20K+',
        isRisky: false,
        checks: [
          VettingCheck(id: 'dev_info', name: 'Developer Info', icon: '💳', cost: 2, clueText: 'Indie developer (1 year)', suspicionWeight: 0.3),
          VettingCheck(id: 'permissions', name: 'App Permissions', icon: '🔐', cost: 2, clueText: 'Storage, Audio', suspicionWeight: 0.2),
          VettingCheck(id: 'reviews', name: 'User Reviews', icon: '⭐', cost: 2, clueText: 'Organic reviews', suspicionWeight: 0.1),
          VettingCheck(id: 'behavior', name: 'App Behavior', icon: '📊', cost: 3, clueText: 'Standard media player', suspicionWeight: 0.0),
        ],
      ),
      VettingApp(
        id: 'data_miner',
        name: 'Photo Editor Pro',
        category: 'Photo',
        starRating: 4.2,
        downloads: '15K+',
        isRisky: true,
        checks: [
          VettingCheck(id: 'dev_info', name: 'Developer Info', icon: '💳', cost: 2, clueText: 'Developer registered 2 days ago', suspicionWeight: 0.9),
          VettingCheck(id: 'permissions', name: 'App Permissions', icon: '🔐', cost: 2, clueText: 'Camera, Gallery, Contacts, Location', suspicionWeight: 0.8),
          VettingCheck(id: 'reviews', name: 'User Reviews', icon: '⭐', cost: 2, clueText: 'Suspiciously similar reviews', suspicionWeight: 0.7),
          VettingCheck(id: 'behavior', name: 'App Behavior', icon: '📊', cost: 3, clueText: 'Uploads photos to unknown server', suspicionWeight: 1.0),
        ],
      ),
      VettingApp(
        id: 'fitness_tracker',
        name: 'Daily Steps',
        category: 'Health',
        starRating: 4.6,
        downloads: '80K+',
        isRisky: false,
        checks: [
          VettingCheck(id: 'dev_info', name: 'Developer Info', icon: '💳', cost: 2, clueText: 'Known health app developer', suspicionWeight: 0.0),
          VettingCheck(id: 'permissions', name: 'App Permissions', icon: '🔐', cost: 2, clueText: 'Activity sensors, Location', suspicionWeight: 0.2),
          VettingCheck(id: 'reviews', name: 'User Reviews', icon: '⭐', cost: 2, clueText: 'Trusted by users', suspicionWeight: 0.0),
          VettingCheck(id: 'behavior', name: 'App Behavior', icon: '📊', cost: 3, clueText: 'Standard health tracking', suspicionWeight: 0.0),
        ],
      ),
      VettingApp(
        id: 'battery_saver_scam',
        name: 'Battery Saver Ultra',
        category: 'Tools',
        starRating: 4.7,
        downloads: '250K+',
        isRisky: true,
        checks: [
          VettingCheck(id: 'dev_info', name: 'Developer Info', icon: '💳', cost: 2, clueText: 'New developer (1 week)', suspicionWeight: 0.7),
          VettingCheck(id: 'permissions', name: 'App Permissions', icon: '🔐', cost: 2, clueText: 'SMS, Contacts, Storage, Phone state', suspicionWeight: 0.9),
          VettingCheck(id: 'reviews', name: 'User Reviews', icon: '⭐', cost: 2, clueText: 'Reviews posted in bursts', suspicionWeight: 0.7),
          VettingCheck(id: 'behavior', name: 'App Behavior', icon: '📊', cost: 3, clueText: 'Background SMS sending detected', suspicionWeight: 1.0),
        ],
      ),
      VettingApp(
        id: 'alarm_clock',
        name: 'Alarm Clock',
        category: 'Productivity',
        starRating: 4.4,
        downloads: '40K+',
        isRisky: false,
        checks: [
          VettingCheck(id: 'dev_info', name: 'Developer Info', icon: '💳', cost: 2, clueText: 'Verified developer (5 years)', suspicionWeight: 0.0),
          VettingCheck(id: 'permissions', name: 'App Permissions', icon: '🔐', cost: 2, clueText: 'Notifications only', suspicionWeight: 0.0),
          VettingCheck(id: 'reviews', name: 'User Reviews', icon: '⭐', cost: 2, clueText: 'Reliable, no complaints', suspicionWeight: 0.0),
          VettingCheck(id: 'behavior', name: 'App Behavior', icon: '📊', cost: 3, clueText: 'Offline functionality', suspicionWeight: 0.0),
        ],
      ),
    ],
  ),
];