enum CallAction {
  listen,      // Just playing audio
  keypadInput, // Waiting for user to press 1, 2, etc.
  otpInput,    // Waiting for 6-digit OTP
  endCall      // Call finished naturally
}

class CallStep {
  final String id;
  final String audioPath;
  final CallAction action;
  
  // Logic: Map input '1' -> nextStepId 'step_2'
  final Map<String, String>? nextSteps; 
  
  // If this step ends the call automatically (e.g. "Thank you, goodbye")
  final bool autoDisconnect;
  final String? endMessage;
  
  // --- ADDED THIS FIELD TO FIX THE ERROR ---
  final bool isWin; 

  CallStep({
    required this.id,
    required this.audioPath,
    this.action = CallAction.listen,
    this.nextSteps,
    this.autoDisconnect = false,
    this.endMessage,
    this.isWin = false, // Default to false
  });
}

class VishingScenario {
  final String id;
  final String callerName;
  final String phoneNumber;
  final bool isScam; // The "Truth" (used for final scoring)
  final String initialStepId;
  final Map<String, CallStep> steps; // All possible steps in this scenario
  final String educationalReasoning;

  VishingScenario({
    required this.id,
    required this.callerName,
    required this.phoneNumber,
    required this.isScam,
    required this.initialStepId,
    required this.steps,
    required this.educationalReasoning,
  });
}

// --- THE DATA ---

final List<VishingScenario> levelThreeData = [
  
  // 1. BANK SCAM (Fake)
  VishingScenario(
    id: 'bank_fake',
    callerName: "Security Dept",
    phoneNumber: "+1 (800) 225-5224",
    isScam: true,
    initialStepId: 'step_1',
    educationalReasoning: "VISHING RED FLAG: Banks NEVER ask you to read back an OTP (One-Time Password) over the phone. That code is for YOU only.",
    steps: {
      'step_1': CallStep(
        id: 'step_1',
        audioPath: 'audio/bank_fake/Audio_1.mp3', //
        action: CallAction.keypadInput,
        nextSteps: {
          '1': 'step_2', 
        },
      ),
      'step_2': CallStep(
        id: 'step_2',
        audioPath: 'audio/bank_fake/Audio_2.mp3', //
        action: CallAction.otpInput, // Triggers the OTP Overlay
        // If user enters OTP here, they FAIL. 
        // If they hang up, they WIN.
      ),
    },
  ),

  // 2. BANK LEGIT (Real)
  VishingScenario(
    id: 'bank_legit',
    callerName: "City Bank",
    phoneNumber: "+1 (555) 019-2834",
    isScam: false,
    initialStepId: 'step_1',
    educationalReasoning: "SAFE: The automated system verified recent activity without asking for sensitive credentials or OTPs.",
    steps: {
      'step_1': CallStep(
        id: 'step_1',
        audioPath: 'audio/bank_legit/Audio_1.mp3', //
        action: CallAction.keypadInput,
        nextSteps: {
          '1': 'step_2_end', 
          '2': 'step_3_more', 
        },
      ),
      'step_2_end': CallStep(
        id: 'step_2_end',
        audioPath: 'audio/bank_legit/Audio_2.mp3', //
        action: CallAction.endCall,
        autoDisconnect: true,
        isWin: true, // <--- IMPORTANT: Completing this legit call is a WIN
        endMessage: "Verification Successful",
      ),
      'step_3_more': CallStep(
        id: 'step_3_more',
        audioPath: 'audio/bank_legit/Audio_3.mp3', //
        action: CallAction.keypadInput,
        nextSteps: {
          '1': 'step_4_final',
        },
      ),
      'step_4_final': CallStep(
        id: 'step_4_final',
        audioPath: 'audio/bank_legit/Audio_4.mp3', //
        action: CallAction.endCall,
        autoDisconnect: true,
        isWin: true, // <--- IMPORTANT: Completing this legit call is a WIN
        endMessage: "Report Filed Successfully",
      ),
    },
  ),
];