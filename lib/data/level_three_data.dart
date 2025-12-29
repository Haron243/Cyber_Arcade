class AudioScenario {
  final int id;
  final String callerName;
  final String phoneNumber;
  final String audioAssetPath; // e.g., 'audio/scam_1.mp3'
  final bool isScam;
  final String educationalReasoning;

  AudioScenario({
    required this.id,
    required this.callerName,
    required this.phoneNumber,
    required this.audioAssetPath,
    required this.isScam,
    required this.educationalReasoning,
  });
}

final List<AudioScenario> levelThreeData = [
  AudioScenario(
    id: 301,
    callerName: "Unknown Caller",
    phoneNumber: "+1 (800) 555-0199",
    audioAssetPath: "audio/spam_call_1.mp3", // Make sure this file exists in assets/audio/
    isScam: true,
    educationalReasoning: "VISHING: The IRS will never call you to demand immediate payment via gift cards or wire transfer. This aggressive tone is a major red flag.",
  ),
  // Add more scenarios...
];