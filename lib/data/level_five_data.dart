import 'dart:ui'; // <--- ADD THIS LINE to fix the "Offset" error
class QrScenario {
  final String id;
  final String title;
  final String description;
  final String contextImageUrl; // Using Network URL for now
  final String qrUrl;
  final bool isScam;
  final String threatLevel; // Low, Medium, High, Critical
  final String scamDetails;
  final Map<String, dynamic> analysis; // Holds the "Risk Score" and "Findings"
  final Offset targetPosition; // Relative position (0.0 to 1.0)

  QrScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.contextImageUrl,
    required this.qrUrl,
    required this.isScam,
    required this.threatLevel,
    required this.scamDetails,
    required this.analysis,
    required this.targetPosition,
  });
}

final List<QrScenario> levelFiveData = [
  QrScenario(
    id: 'level-1-parking',
    title: 'City Parking Meter',
    description: 'A new QR sticker is pasted over the original metal plate.',
    contextImageUrl: 'https://images.unsplash.com/photo-1590615370581-265ae198083b?q=80&w=2070',
    qrUrl: 'https://pay-city-parking.co.us',
    isScam: true,
    threatLevel: 'High',
    scamDetails: 'The domain "pay-city-parking.co.us" is a spoof. Official city meters use .gov domains.',
    targetPosition: const Offset(0.5, 0.65),
    analysis: {
      "riskScore": 92,
      "findings": [
        "Suspicious sticker placement",
        "Cross-border redirect (.ru)",
        "Non-government domain"
      ],
      "verdict": "SCAM"
    },
  ),
  QrScenario(
    id: 'level-2-cafe',
    title: 'The Digital Menu',
    description: 'A QR code embedded in a wooden block on a cafe table.',
    contextImageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=2047',
    qrUrl: 'https://bistro-deluxe-menus.com',
    isScam: false,
    threatLevel: 'Low',
    scamDetails: 'Legitimate use case. The URL matches the establishment and uses HTTPS.',
    targetPosition: const Offset(0.5, 0.55),
    analysis: {
      "riskScore": 12,
      "findings": [
        "Domain matches location",
        "Valid SSL Certificate",
        "No redirects found"
      ],
      "verdict": "SAFE"
    },
  ),
  QrScenario(
    id: 'level-3-bike',
    title: 'Ride Share Unlock',
    description: 'A bright yellow sticker on a bike handlebar saying "Scan to Unlock Fast".',
    contextImageUrl: 'https://images.unsplash.com/photo-1626555737128-6a56e5414595?q=80&w=2070',
    qrUrl: 'http://city-bike-unlock.net',
    isScam: true,
    threatLevel: 'Critical',
    scamDetails: 'Uses insecure HTTP and attempts to download a malicious APK file.',
    targetPosition: const Offset(0.45, 0.40),
    analysis: {
      "riskScore": 98,
      "findings": [
        "Insecure Protocol (HTTP)",
        "Direct .APK download detected",
        "Urgency cues ('Unlock Fast')"
      ],
      "verdict": "SCAM"
    },
  ),
];