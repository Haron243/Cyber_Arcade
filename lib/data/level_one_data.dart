class WebsiteCard {
  final String url;
  final bool isPhishing;
  final String reasoning; // Added this so users learn WHY

  WebsiteCard({
    required this.url,
    required this.isPhishing,
    required this.reasoning, 
  });
}

final List<WebsiteCard> levelOneData = [
  // 1. Google (Legit)
  WebsiteCard(
    url: 'www.google.com',
    isPhishing: false,
    reasoning: "LEGIT: This is the official domain. No misspellings or extra dashes.",
  ),
  // 2. Google Phishing
  WebsiteCard(
    url: 'www.goo6le-login.com',
    isPhishing: true,
    reasoning: "PHISHING: Notice the '6' replacing the 'g'. This is a 'Typosquatting' attack.",
  ),
  // 3. Amazon (Legit)
  WebsiteCard(
    url: 'www.amazon.com',
    isPhishing: false,
    reasoning: "LEGIT: Short, correct, and familiar. This is the official Amazon address.",
  ),
  // 4. Amazon Phishing
  WebsiteCard(
    url: 'www.amazon-support-returns.net',
    isPhishing: true,
    reasoning: "PHISHING: Amazon does not use dash-separated domains like 'amazon-support'. They use 'amazon.com'.",
  ),
  // 5. PayPal (Legit)
  WebsiteCard(
    url: 'www.paypal.com',
    isPhishing: false,
    reasoning: "LEGIT: The official domain for financial transactions.",
  ),
  // 6. PayPal Phishing
  WebsiteCard(
    url: 'www.paypa1-secure.com',
    isPhishing: true,
    reasoning: "PHISHING: The letter 'l' has been replaced by the number '1'. Always check spelling!",
  ),
  // 7. Microsoft (Legit)
  WebsiteCard(
    url: 'www.microsoft.com',
    isPhishing: false,
    reasoning: "LEGIT: Official Microsoft domain.",
  ),
  // 8. Microsoft Phishing
  WebsiteCard(
    url: 'www.mscs-security-verify.org',
    isPhishing: true,
    reasoning: "PHISHING: 'mscs' is nonsense, and major tech companies rarely use .org for login pages.",
  ),
  // 9. Facebook (Legit)
  WebsiteCard(
    url: 'www.facebook.com',
    isPhishing: false,
    reasoning: "LEGIT: The correct social media domain.",
  ),
  // 10. Facebook Phishing
  WebsiteCard(
    url: 'www.faceb00k-login.com',
    isPhishing: true,
    reasoning: "PHISHING: Zeros '00' replacing 'oo' is a common trick. Don't fall for it!",
  ),
];