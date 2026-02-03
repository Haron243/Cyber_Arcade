enum NodeType { source, intermediate, target }

class GameNode {
  final String id;
  final String label;
  final String type; // 'wallet','bank','link','app','merchant','browser','person','warning'
  final String inspectHint;
  final NodeType nodeType;

  /// Layout coordinates (0.0–1.0 relative to parent).
  /// (0.5, 0.5) = centre of the canvas.
  final double x;
  final double y;

  GameNode({
    required this.id,
    required this.label,
    required this.type,
    required this.inspectHint,
    required this.nodeType,
    required this.x,
    required this.y,
  });
}

class PaymentScenario {
  final String id;
  final String goal;
  final String difficulty;

  /// One-line framing shown BELOW the goal pill.
  /// Tells the player WHY they are acting — without spoiling the trap.
  final String context;

  final List<GameNode> nodes;

  /// Dangerous edges.  Key = "fromId->toId".
  /// If the player's path contains this edge the money leaks.
  final Map<String, String> badPaths;

  PaymentScenario({
    required this.id,
    required this.goal,
    required this.difficulty,
    required this.context,
    required this.nodes,
    required this.badPaths,
  });
}

// ---------------------------------------------------------------------------
// SCENARIO DATA
// ---------------------------------------------------------------------------

final List<PaymentScenario> levelSixData = [
  // -----------------------------------------------------------------------
  // SCENARIO 1 – UTILITY BILL  (Rookie)
  // Teach: use the official app, not a search-ad link.
  // Good path  : wallet → official_app → power_grid   ✅
  // Bad paths  : anything through search_ad / fake_site / scammer
  //              OR skipping straight to power_grid (no verified channel)
  // -----------------------------------------------------------------------
  PaymentScenario(
    id: 'lvl4_01',
    goal: "Pay ₹850 Electricity Bill",
    difficulty: "Rookie",
    context: "Your electricity bill is due today. Route the payment safely.",
    badPaths: {
      'wallet->power_grid':
          "Payment unprocessed — no verified channel used",
      'wallet->search_ad': "Ad leads to an unverified site",
      'search_ad->fake_site': "Phishing portal opened",
      'fake_site->scammer': "Money redirected to unknown account",
    },
    nodes: [
      // SOURCE
      GameNode(
        id: 'wallet',
        label: 'My Wallet',
        type: 'wallet',
        nodeType: NodeType.source,
        inspectHint: "Your device wallet",
        x: 0.5,
        y: 0.10,
      ),
      // TARGET
      GameNode(
        id: 'power_grid',
        label: 'Power Corp',
        type: 'merchant',
        nodeType: NodeType.target,
        inspectHint: "Verified Biller",
        x: 0.5,
        y: 0.85,
      ),
      // GOOD intermediate
      GameNode(
        id: 'official_app',
        label: 'Official App',
        type: 'app',
        nodeType: NodeType.intermediate,
        inspectHint: "Verified Publisher: Power Corp",
        x: 0.25,
        y: 0.45,
      ),
      // BAD intermediates  (y-values spread so labels don't collide)
      GameNode(
        id: 'search_ad',
        label: 'Search Ad',
        type: 'link',
        nodeType: NodeType.intermediate,
        inspectHint: "Sponsored Result (Unverified)",
        x: 0.75,
        y: 0.28, // was 0.35 — moved up
      ),
      GameNode(
        id: 'fake_site',
        label: 'Quick-Bill.com',
        type: 'browser',
        nodeType: NodeType.intermediate,
        inspectHint: "Created 2 days ago",
        x: 0.75,
        y: 0.52, // was 0.60 — tighter mid-gap
      ),
      GameNode(
        id: 'scammer',
        label: 'Unknown Acct',
        type: 'warning',
        nodeType: NodeType.intermediate,
        inspectHint: "Personal Bank Account",
        x: 0.88, // was 0.9 — slight inward shift
        y: 0.76, // was 0.80
      ),
    ],
  ),

  // -----------------------------------------------------------------------
  // SCENARIO 2 – MARKETPLACE BUY  (Advanced)
  // Teach: pay through the app's escrow, never scan a seller's QR.
  // Good path  : wallet → app_escrow → seller   ✅
  // Bad paths  : wallet → qr_code (scanning sends money)
  //              OR wallet → seller directly (no buyer protection)
  // -----------------------------------------------------------------------
  PaymentScenario(
    id: 'lvl4_02',
    goal: "Buy Camera (₹15,000)",
    difficulty: "Advanced",
    context: "A seller on a marketplace wants you to pay. Choose how.",
    badPaths: {
      'wallet->seller':
          "No buyer protection — payment cannot be recovered",
      'wallet->qr_code': "Scanning this QR sends money out",
      'qr_code->scammer_wallet': "Funds diverted to wrong account",
    },
    nodes: [
      GameNode(
        id: 'wallet',
        label: 'UPI App',
        type: 'wallet',
        nodeType: NodeType.source,
        inspectHint: "Linked to your Bank",
        x: 0.5,
        y: 0.10,
      ),
      GameNode(
        id: 'seller',
        label: 'Seller (Rahul)',
        type: 'person',
        nodeType: NodeType.target,
        inspectHint: "Marketplace User",
        x: 0.5,
        y: 0.90,
      ),
      // BAD
      GameNode(
        id: 'qr_code',
        label: 'Sent QR Code',
        type: 'link',
        nodeType: NodeType.intermediate,
        inspectHint: "QRs are for paying, not receiving",
        x: 0.75,
        y: 0.38,
      ),
      GameNode(
        id: 'scammer_wallet',
        label: 'Rahul (Personal)',
        type: 'warning',
        nodeType: NodeType.intermediate,
        inspectHint: "Unverified UPI ID",
        x: 0.78,
        y: 0.68,
      ),
      // GOOD
      GameNode(
        id: 'app_escrow',
        label: 'App Payment',
        type: 'app',
        nodeType: NodeType.intermediate,
        inspectHint: "Held until delivery confirmed",
        x: 0.25,
        y: 0.50,
      ),
    ],
  ),

  // -----------------------------------------------------------------------
  // SCENARIO 3 – KYC UPDATE  (Master)
  // Teach: ignore urgent SMS links; update through the official app/site.
  // Good path  : wallet → net_banking → bank_db   ✅
  // Bad paths  : anything through sms_link / fake_form / hacker
  //              OR wallet → bank_db directly (no authenticated channel)
  // -----------------------------------------------------------------------
  PaymentScenario(
    id: 'lvl4_03',
    goal: "Update KYC Details",
    difficulty: "Master",
    context: 'You received an SMS: "Your account will be blocked."',
    badPaths: {
      'wallet->bank_db':
          "Unverified route — details cannot reach the bank securely",
      'wallet->sms_link': "Link opened from an unknown number",
      'sms_link->fake_form': "Your details are being harvested",
      'fake_form->hacker': "Identity information stolen",
    },
    nodes: [
      // SOURCE  — label & type fixed to match payment mental-model
      GameNode(
        id: 'wallet',
        label: 'My Phone',
        type: 'person',
        nodeType: NodeType.source,
        inspectHint: "Where you start",
        x: 0.5,
        y: 0.10,
      ),
      // TARGET
      GameNode(
        id: 'bank_db',
        label: 'Bank Database',
        type: 'bank',
        nodeType: NodeType.target,
        inspectHint: "Secure Server",
        x: 0.5,
        y: 0.90,
      ),
      // BAD  (y spread out)
      GameNode(
        id: 'sms_link',
        label: 'SMS: "Urgent!"',
        type: 'link',
        nodeType: NodeType.intermediate,
        inspectHint: "Sent from a personal mobile number",
        x: 0.78,
        y: 0.26, // was 0.30
      ),
      GameNode(
        id: 'fake_form',
        label: 'kfc-update.com',
        type: 'browser',
        nodeType: NodeType.intermediate,
        inspectHint: "Not an official bank domain",
        x: 0.78,
        y: 0.52, // was 0.60
      ),
      GameNode(
        id: 'hacker',
        label: 'Unknown Device',
        type: 'warning',
        nodeType: NodeType.intermediate,
        inspectHint: "Remote Location",
        x: 0.88,
        y: 0.76, // was 0.85
      ),
      // GOOD
      GameNode(
        id: 'net_banking',
        label: 'Net Banking',
        type: 'bank',
        nodeType: NodeType.intermediate,
        inspectHint: "https://bank.com (SSL verified)",
        x: 0.22,
        y: 0.50,
      ),
    ],
  ),
];