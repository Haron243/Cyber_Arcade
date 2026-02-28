// ===========================================================================
// lib/data/level_eight_data.dart
// ===========================================================================

/// Represents a chat message in the echo room
class ChatMessage {
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isPlayerMessage;

  ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isPlayerMessage = false,
  });
}

/// AI member persona - determines how they behave
enum MemberPersona {
  sharer,      // Forwards without thinking
  panicker,    // Reacts emotionally
  skeptic,     // Questions things
  follower,    // Does what others do
}

/// An AI chat member
class ChatMember {
  final String id;
  final String name;
  final MemberPersona persona;

  ChatMember({
    required this.id,
    required this.name,
    required this.persona,
  });

  /// Returns how likely (0.0-1.0) this member is to engage based on echo level
  double getEngagementProbability(double echoVolume) {
    switch (persona) {
      case MemberPersona.sharer:
        return (echoVolume / 100) * 0.8; // More likely when echo is high
      case MemberPersona.panicker:
        return echoVolume > 60 ? 0.9 : 0.3; // Reacts strongly to high echo
      case MemberPersona.skeptic:
        return echoVolume > 70 ? 0.5 : 0.1; // Questions when viral
      case MemberPersona.follower:
        return (echoVolume / 100) * 0.6; // Moderate engagement
    }
  }

  /// Returns a message this member would send based on their persona
  String getTypicalMessage(double echoVolume) {
    switch (persona) {
      case MemberPersona.sharer:
        return [
          "Forwarding to everyone!",
          "Sharing this now!",
          "Everyone needs to see this!",
          "Spreading the word!",
        ][DateTime.now().millisecond % 4];
      case MemberPersona.panicker:
        return [
          "OMG this is serious!",
          "We need to act NOW!",
          "This is terrible! 😱",
          "What do we do??",
        ][DateTime.now().millisecond % 4];
      case MemberPersona.skeptic:
        return [
          "Source?",
          "Is this verified?",
          "Sounds suspicious...",
          "Where did this come from?",
        ][DateTime.now().millisecond % 4];
      case MemberPersona.follower:
        return [
          "Really??",
          "Is this true?",
          "Should we be worried?",
          "What's happening?",
        ][DateTime.now().millisecond % 4];
    }
  }
}

/// A complete scenario (one rumor simulation)
class EchoScenario {
  final String id;
  final String title;
  final String rumor;
  final String context; // Backstory
  final List<ChatMember> members;
  final List<ChatMessage> initialMessages; // Pre-loaded messages
  final double initialEchoVolume;
  final int durationSeconds;
  final String winMessage;
  final String lossMessage;

  EchoScenario({
    required this.id,
    required this.title,
    required this.rumor,
    required this.context,
    required this.members,
    required this.initialMessages,
    required this.initialEchoVolume,
    required this.durationSeconds,
    required this.winMessage,
    required this.lossMessage,
  });
}

// ===========================================================================
// SCENARIO DATA
// ===========================================================================

final List<EchoScenario> levelEightData = [
  // Scenario 1: Bank Account Freeze
  EchoScenario(
    id: 'lvl8_bank_freeze',
    title: 'Community Updates',
    rumor: 'Urgent! New government rule will freeze bank accounts tonight! Share fast!',
    context: 'A rumor about bank freezes spreads through a community group.',
    initialEchoVolume: 25,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'Sarah', persona: MemberPersona.sharer),
      ChatMember(id: 'm2', name: 'Mike', persona: MemberPersona.panicker),
      ChatMember(id: 'm3', name: 'Jenny', persona: MemberPersona.skeptic),
      ChatMember(id: 'm4', name: 'Tom', persona: MemberPersona.follower),
      ChatMember(id: 'm5', name: 'Lisa', persona: MemberPersona.sharer),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'Sarah',
        text: 'Urgent! New government rule will freeze bank accounts tonight! Share fast!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Mike',
        text: 'What?? Is this real??',
        timestamp: DateTime.now().subtract(const Duration(seconds: 8)),
      ),
    ],
    winMessage: 'You kept calm and prevented panic. The rumor faded away.',
    lossMessage: 'The rumor went viral. Thousands panicked unnecessarily.',
  ),

  // Scenario 2: Health Restriction
  EchoScenario(
    id: 'lvl8_health_restriction',
    title: 'Neighborhood Watch',
    rumor: 'Breaking: City banning all outdoor exercise starting tomorrow. Officials confirm.',
    context: 'A fake health restriction spreads fear in a local community.',
    initialEchoVolume: 30,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'David', persona: MemberPersona.panicker),
      ChatMember(id: 'm2', name: 'Emma', persona: MemberPersona.sharer),
      ChatMember(id: 'm3', name: 'Ryan', persona: MemberPersona.follower),
      ChatMember(id: 'm4', name: 'Olivia', persona: MemberPersona.skeptic),
      ChatMember(id: 'm5', name: 'Chris', persona: MemberPersona.sharer),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'David',
        text: 'Breaking: City banning all outdoor exercise starting tomorrow. Officials confirm.',
        timestamp: DateTime.now().subtract(const Duration(seconds: 12)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Emma',
        text: 'No way! This can\'t be true!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 9)),
      ),
      ChatMessage(
        senderId: 'm5',
        senderName: 'Chris',
        text: 'Forwarding to my running group',
        timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
      ),
    ],
    winMessage: 'You encouraged verification. The fake restriction was debunked.',
    lossMessage: 'False alarm spread city-wide. Gyms flooded with calls.',
  ),

  // Scenario 3: Celebrity Scandal
  EchoScenario(
    id: 'lvl8_celebrity_scandal',
    title: 'Entertainment News',
    rumor: 'EXCLUSIVE: Famous actor arrested at airport! Video proof inside!',
    context: 'Celebrity gossip spreads rapidly through fan groups.',
    initialEchoVolume: 35,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'Alex', persona: MemberPersona.sharer),
      ChatMember(id: 'm2', name: 'Jordan', persona: MemberPersona.sharer),
      ChatMember(id: 'm3', name: 'Taylor', persona: MemberPersona.follower),
      ChatMember(id: 'm4', name: 'Morgan', persona: MemberPersona.panicker),
      ChatMember(id: 'm5', name: 'Casey', persona: MemberPersona.skeptic),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'Alex',
        text: 'EXCLUSIVE: Famous actor arrested at airport! Video proof inside!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 15)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Jordan',
        text: 'OMG sharing everywhere!!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 11)),
      ),
      ChatMessage(
        senderId: 'm4',
        senderName: 'Morgan',
        text: 'I can\'t believe it! 😱',
        timestamp: DateTime.now().subtract(const Duration(seconds: 7)),
      ),
    ],
    winMessage: 'You slowed the gossip. The actor\'s team issued a denial.',
    lossMessage: 'Baseless rumor trended worldwide. Actor\'s reputation damaged.',
  ),

  // Scenario 4: Product Recall
  EchoScenario(
    id: 'lvl8_product_recall',
    title: 'Parent Group',
    rumor: 'URGENT: Popular baby formula contains toxic chemicals. Recall announced!',
    context: 'A fake product recall causes panic among parents.',
    initialEchoVolume: 40,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'Rachel', persona: MemberPersona.panicker),
      ChatMember(id: 'm2', name: 'Steve', persona: MemberPersona.sharer),
      ChatMember(id: 'm3', name: 'Maria', persona: MemberPersona.panicker),
      ChatMember(id: 'm4', name: 'Kevin', persona: MemberPersona.follower),
      ChatMember(id: 'm5', name: 'Nina', persona: MemberPersona.skeptic),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'Rachel',
        text: 'URGENT: Popular baby formula contains toxic chemicals. Recall announced!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 18)),
      ),
      ChatMessage(
        senderId: 'm3',
        senderName: 'Maria',
        text: 'Oh no!! I just bought this yesterday!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 14)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Steve',
        text: 'Sending to all parents I know!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
      ),
      ChatMessage(
        senderId: 'm4',
        senderName: 'Kevin',
        text: 'This is scary...',
        timestamp: DateTime.now().subtract(const Duration(seconds: 6)),
      ),
    ],
    winMessage: 'You asked for sources. The company confirmed no recall exists.',
    lossMessage: 'Panic spread. Stores overwhelmed. Company stock crashed.',
  ),

  // Scenario 5: Weather Emergency
  EchoScenario(
    id: 'lvl8_weather_emergency',
    title: 'Local Area Alert',
    rumor: 'BREAKING: Tsunami warning issued for our coast! Evacuate immediately!',
    context: 'A fake weather emergency spreads in a coastal town.',
    initialEchoVolume: 45,
    durationSeconds: 60,
    members: [
      ChatMember(id: 'm1', name: 'Ben', persona: MemberPersona.sharer),
      ChatMember(id: 'm2', name: 'Amy', persona: MemberPersona.panicker),
      ChatMember(id: 'm3', name: 'Lucas', persona: MemberPersona.sharer),
      ChatMember(id: 'm4', name: 'Sophie', persona: MemberPersona.panicker),
      ChatMember(id: 'm5', name: 'Jack', persona: MemberPersona.skeptic),
    ],
    initialMessages: [
      ChatMessage(
        senderId: 'm1',
        senderName: 'Ben',
        text: 'BREAKING: Tsunami warning issued for our coast! Evacuate immediately!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
      ),
      ChatMessage(
        senderId: 'm2',
        senderName: 'Amy',
        text: 'EVERYONE GET OUT NOW!! 🌊',
        timestamp: DateTime.now().subtract(const Duration(seconds: 16)),
      ),
      ChatMessage(
        senderId: 'm4',
        senderName: 'Sophie',
        text: 'Grabbing my kids!!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 12)),
      ),
      ChatMessage(
        senderId: 'm3',
        senderName: 'Lucas',
        text: 'Forwarding to everyone in town!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 8)),
      ),
    ],
    winMessage: 'You stayed calm. Official channels confirmed no tsunami threat.',
    lossMessage: 'Mass evacuation chaos. Roads gridlocked. False alarm cost millions.',
  ),
];