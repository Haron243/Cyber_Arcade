// ===========================================================================
// lib/data/cutscene_data.dart
// ===========================================================================

class DialogLine {
  final String speakerName;
  final String text;
  final String characterImagePath;

  DialogLine({
    required this.speakerName,
    required this.text,
    required this.characterImagePath,
  });
}

// Standardized asset paths matching your exact filenames
const String poseAwkward = "assets/images/cutscenes/guide_awkward_welcome.png";
const String poseCheckingPhone = "assets/images/cutscenes/guide_checking_phone.png";
const String poseConfident = "assets/images/cutscenes/guide_confident.png";
const String poseHey = "assets/images/cutscenes/guide_hey.png";
const String poseLaughing = "assets/images/cutscenes/guide_laughing_inside.png";
const String poseNeutral = "assets/images/cutscenes/guide_neutral.png";
const String poseRelief = "assets/images/cutscenes/guide_relief.png";
const String poseSmile = "assets/images/cutscenes/guide_smile.png"; // Matched your exact spelling
const String poseStress = "assets/images/cutscenes/guide_stress.png";
const String poseSure = "assets/images/cutscenes/guide_sure.png";
const String poseThinking = "assets/images/cutscenes/guide_thinking.png";
const String poseWelcome = "assets/images/cutscenes/guide_welcome.png";

final Map<int, List<DialogLine>> levelCutscenes = {
  // --- LEVEL 1: URL Phishing ---
  1: [
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Welcome to the Agency for Cyber Readiness. I am your AI consultant, and I'll be guiding your training.",
      characterImagePath: poseWelcome, 
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Your first task is simple: URL Forensics. Cybercriminals often use deceptive domains to steal credentials.",
      characterImagePath: poseThinking,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Analyze the incoming links. Look out for clever misspellings and verify their security. Good luck, agent.",
      characterImagePath: poseConfident,
    ),
  ],

  // --- LEVEL 2: Email Phishing ---
  2: [
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Excellent work on the URLs. Now we escalate to targeted email attacks.",
      characterImagePath: poseSmile,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Social engineering relies on urgency and fear. Scammers will try to panic you into clicking malicious attachments.",
      characterImagePath: poseStress,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Inspect the sender addresses carefully. Do not let their threats cloud your judgment.",
      characterImagePath: poseSure,
    ),
  ],

  // --- LEVEL 3: Vishing (Voice Phishing) ---
  3: [
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Incoming alert. We are intercepting live audio feeds. The threat is now active voice phishing, or 'Vishing'.",
      characterImagePath: poseCheckingPhone, // Great use of the checking phone asset!
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Attackers are impersonating bank officials and tech support to extract OTPs directly from victims.",
      characterImagePath: poseThinking,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Listen to the calls carefully. Identify the scammers and drop the call before they compromise the system.",
      characterImagePath: poseConfident,
    ),
  ],

  // --- LEVEL 4: Evil Twin Wi-Fi ---
  4: [
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Agent, public networks are a battlefield. We've detected rogue access points in the vicinity.",
      characterImagePath: poseStress,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "This is an 'Evil Twin' attack. Hackers broadcast fake Wi-Fi names to intercept traffic from unsuspecting users.",
      characterImagePath: poseNeutral,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Scan the network list. Avoid open, unsecured networks masquerading as legitimate hotspots.",
      characterImagePath: poseSure,
    ),
  ],

  // --- LEVEL 5: Quishing (QR Phishing) ---
  5: [
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Physical perimeter breached. We are tracking malicious QR code stickers placed over legitimate public services.",
      characterImagePath: poseStress,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "We call this 'Quishing'. Scanning these codes bypasses digital filters and directly infects mobile hardware.",
      characterImagePath: poseThinking,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Your scanner is ready. Tilt your device or drag the screen to locate the QR codes in the environment and analyze them.",
      characterImagePath: poseConfident,
    ),
  ],

  // --- LEVEL 6: Payment Tracing ---
  6: [
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "A breach has occurred, and funds are moving. We need you to 'Follow the Money'.",
      characterImagePath: poseCheckingPhone,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Hackers use complex node networks to launder stolen assets. You must map the flow of these unauthorized redirects.",
      characterImagePath: poseNeutral,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Trace the connections between the compromised accounts and flag the fraudulent nodes.",
      characterImagePath: poseSmile,
    ),
  ],

  // --- LEVEL 7: App Vetting ---
  7: [
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Supply chain security is our next priority. Malware is being disguised as legitimate software in the app store.",
      characterImagePath: poseStress,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "You are the gatekeeper. You have limited vetting tokens to investigate suspicious applications.",
      characterImagePath: poseNeutral,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Check their permissions, developer history, and network behavior. Do not let malware reach the public.",
      characterImagePath: poseConfident,
    ),
  ],

  // --- LEVEL 8: The Echo Room ---
  8: [
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Agent, the final test isn't about code... it's about human psychology. A massive disinformation campaign has launched.",
      characterImagePath: poseAwkward,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Panic spreads faster than any virus. You are entering a live chat simulation where unverified rumors are going viral.",
      characterImagePath: poseStress,
    ),
    DialogLine(
      speakerName: "ARC COMMAND",
      text: "Manage the 'Echo Volume'. Your calm interventions and requests for verification are your only weapons to stop the panic.",
      characterImagePath: poseRelief,
    ),
  ],
};