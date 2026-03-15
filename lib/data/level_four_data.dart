class WifiNetwork {
  final String ssid;
  final int signalStrength; // 1 to 4 bars
  final bool isSecure; // Has Lock Icon?
  final bool isTrap; // Is this the Evil Twin?
  final String reasoning;

  // Inner details
  final String securityType; // e.g., "WPA3-Personal", "None"
  final String frequency;    // e.g., "5 GHz", "2.4 GHz"
  final String standard;     // e.g., "Wi-Fi 6 (802.11ax)"
  final String privacy;      // e.g., "Randomized MAC"
  final String ipAddress;    // e.g., "192.168.1.15" or "Unavailable"
  final String gateway;      // e.g., "192.168.1.1"

  WifiNetwork({
    required this.ssid,
    required this.signalStrength,
    required this.isSecure,
    required this.isTrap,
    required this.reasoning,
    required this.securityType,
    required this.frequency,
    required this.standard,
    required this.privacy,
    this.ipAddress = "Unavailable",
    this.gateway = "Unavailable",
  });
}

class WifiScenario {
  final int id;
  final String locationName;
  final String hint;
  final List<WifiNetwork> networks;

  WifiScenario({
    required this.id,
    required this.locationName,
    required this.hint,
    required this.networks,
  });
}

final List<WifiScenario> levelFourData = [
  // SCENARIO 1: AIRPORT
  WifiScenario(
    id: 401,
    locationName: "International Airport",
    hint: "Analyze the security protocols before connecting.",
    networks: [
      WifiNetwork(
        ssid: "Airport_Free_HighSpeed",
        signalStrength: 4,
        isSecure: false,
        isTrap: true,
        reasoning: "EVIL TWIN: The details reveal 'Security: None'. An official airport network would never be unencrypted.",
        securityType: "None",
        frequency: "2.4 GHz",
        standard: "Wi-Fi 4 (802.11n)",
        privacy: "Device MAC",
        ipAddress: "10.0.0.5",
        gateway: "10.0.0.1",
      ),
      WifiNetwork(
        ssid: "Airport_Official_Secure",
        signalStrength: 3,
        isSecure: true,
        isTrap: false,
        reasoning: "SAFE: It uses WPA3 Enterprise security and modern Wi-Fi 6 standards.",
        securityType: "WPA3-Enterprise",
        frequency: "5 GHz",
        standard: "Wi-Fi 6 (802.11ax)",
        privacy: "Randomized MAC",
      ),
      WifiNetwork(
        ssid: "HP-Printer-Network",
        signalStrength: 1,
        isSecure: true,
        isTrap: false,
        reasoning: "SAFE (But Useless): Just a printer.",
        securityType: "WPA2-Personal",
        frequency: "2.4 GHz",
        standard: "Wi-Fi 4 (802.11n)",
        privacy: "Device MAC",
      ),
    ],
  ),

  // SCENARIO 2: COFFEE SHOP
  WifiScenario(
    id: 402,
    locationName: "Starbucks Café",
    hint: "Check the frequency and standards.",
    networks: [
      WifiNetwork(
        ssid: "Starbucks_Guest_WiFi",
        signalStrength: 3,
        isSecure: true,
        isTrap: false,
        reasoning: "SAFE: Uses standard WPA2 encryption and 5 GHz frequency.",
        securityType: "WPA2-Personal",
        frequency: "5 GHz",
        standard: "Wi-Fi 5 (802.11ac)",
        privacy: "Randomized MAC",
      ),
      WifiNetwork(
        ssid: "Starbucks_Free_VIP",
        signalStrength: 4,
        isSecure: false,
        isTrap: true,
        reasoning: "TRAP: 'Open' security is the red flag. Also, 'VIP' is common bait.",
        securityType: "None", // The giveaway
        frequency: "2.4 GHz",
        standard: "Wi-Fi 4 (802.11n)",
        privacy: "Device MAC",
      ),
    ],
  ),
];