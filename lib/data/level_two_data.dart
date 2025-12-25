// File: lib/data/level_two_data.dart

class Scenario {
  final int id;
  final String title;
  final String type; // 'Email', 'Website', 'Social Media/SMS'
  final String scenarioDescription;
  final String urlOrSender;
  final bool isPhishing;
  final String educationalReasoning;

  Scenario({
    required this.id,
    required this.title,
    required this.type,
    required this.scenarioDescription,
    required this.urlOrSender,
    required this.isPhishing,
    required this.educationalReasoning,
  });
}

final List<Scenario> levelTwoData = [
  Scenario(
    id: 201,
    title: "Netflix: Payment Failed",
    type: "Email",
    scenarioDescription:
        "We were unable to process your payment for the current billing cycle. Your subscription has been placed on hold. To continue watching your favorite shows without interruption, please update your payment method immediately via the secure link below.",
    urlOrSender: "support@netflix-verify-billing.com",
    isPhishing: true,
    educationalReasoning:
        "URGENCY ATTACK: While the branding looks real, the sender domain 'netflix-verify-billing.com' is a spoof. Real emails come from 'netflix.com'.",
  ),
  Scenario(
    id: 202,
    title: "Privacy Policy Update",
    type: "Email",
    scenarioDescription:
        "We are making some changes to our Terms of Service and Privacy Policy to be more transparent about how we process your data. These changes will go into effect on November 1st. No action is required on your part.",
    urlOrSender: "no-reply@spotify.com",
    isPhishing: false,
    educationalReasoning:
        "LEGITIMATE: The sender address matches the official domain exactly, and critically, the email does NOT demand immediate action or login.",
  ),
  Scenario(
    id: 203,
    title: "SMS: Package Delivery",
    type: "Social Media/SMS",
    scenarioDescription:
        "USPS Notice: Your package US-9211 could not be delivered due to an incomplete address. Please confirm your details within 12 hours to avoid return to sender: http://smsc.li/post-help",
    urlOrSender: "USPS-Alerts",
    isPhishing: true,
    educationalReasoning:
        "SMISHING: The urgency ('within 12 hours') is a pressure tactic. The link uses a generic shortener ('smsc.li') instead of 'usps.com'.",
  ),
  Scenario(
    id: 204,
    title: "OneDrive: Document Shared",
    type: "Email",
    scenarioDescription:
        "Human Resources has shared a secure file with you: 'Q3_Executive_Bonuses.xlsx'. This document is password protected. Click below to sign in with your corporate credentials to view the file content.",
    urlOrSender: "notifications@microsoft-sharepoint-secure.com",
    isPhishing: true,
    educationalReasoning:
        "CREDENTIAL HARVESTING: The domain 'microsoft-sharepoint-secure.com' is fake. Legitimate OneDrive notifications come from standard Microsoft domains.",
  ),
  Scenario(
    id: 205,
    title: "LinkedIn: Search Appearance",
    type: "Email",
    scenarioDescription:
        "You appeared in 12 searches this week. See who is looking at your profile and discover new opportunities. Login to your account to view your dashboard.",
    urlOrSender: "messages-noreply@linkedin.com",
    isPhishing: false,
    educationalReasoning:
        "LEGITIMATE: This is a standard engagement email. The sender domain is correct and it doesn't ask for sensitive financial info directly.",
  ),
  Scenario(
    id: 206,
    title: "Bank: Unusual Activity",
    type: "Email",
    scenarioDescription:
        "Chase Fraud Alert: We declined a transaction of \$254.00 at Best Buy on 10/24. If this was you, reply YES. If not, no action is needed; the transaction was blocked. You can view your account status at chase.com.",
    urlOrSender: "fraud-alerts@chase.com",
    isPhishing: false,
    educationalReasoning:
        "LEGITIMATE: The sender is verified. Critically, the email instructs you to go to the website manually rather than clicking a suspicious button.",
  ),
  Scenario(
    id: 207,
    title: "Instagram: Copyright Violation",
    type: "Social Media/SMS",
    scenarioDescription:
        "Hello User, we have detected a copyright violation in your recent post. Your account will be deleted in 24 hours unless you verify your ownership and appeal the strike here: https://meta-help-portal-support.net/appeal",
    urlOrSender: "Meta_Support_Team",
    isPhishing: true,
    educationalReasoning:
        "SOCIAL PHISHING: 'meta-help-portal-support.net' is a long, convoluted fake domain designed to look official to panic you.",
  ),
];