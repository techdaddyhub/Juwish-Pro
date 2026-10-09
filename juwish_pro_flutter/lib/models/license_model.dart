import 'dart:convert';

/// CleanInbox Pro - Cryptographically Signed License Model
/// 
/// Issued upon confirmed BSC on-chain transfer of JuwishCoin (JWC).
/// Signed with server Ed25519 private key and verifiable offline by client.
class CleanInboxLicense {
  final String licenseId;
  final String customerId;
  final String customerEmail;
  final String tier; // 'starter' | 'pro' | 'enterprise'
  final int dailyLimit; // 500 | 2000 | 5000
  final String duration; // '1_week' | '2_weeks' | '1_month'
  final String paymentMethod;
  final String paymentTx; // BSC transaction hash (0x...)
  final String paymentNetwork; // 'BNB Smart Chain (BSC)'
  final String tokenContract; // 0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99
  final DateTime issuedAt;
  final DateTime expiresAt;
  final List<String> features;
  final String signature; // Ed25519 signature in hex
  final String signatureAlgorithm;

  const CleanInboxLicense({
    required this.licenseId,
    required this.customerId,
    required this.customerEmail,
    required this.tier,
    required this.dailyLimit,
    required this.duration,
    required this.paymentMethod,
    required this.paymentTx,
    required this.paymentNetwork,
    required this.tokenContract,
    required this.issuedAt,
    required this.expiresAt,
    required this.features,
    required this.signature,
    this.signatureAlgorithm = 'Ed25519',
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get daysRemaining {
    final diff = expiresAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  String get tierDisplayName {
    switch (tier.toLowerCase()) {
      case 'starter':
        return 'Starter (500 checks/day)';
      case 'pro':
        return 'Pro (2,000 checks/day)';
      case 'enterprise':
        return 'Enterprise (5,000 checks/day)';
      default:
        return tier.toUpperCase();
    }
  }

  factory CleanInboxLicense.fromJson(Map<String, dynamic> json) {
    return CleanInboxLicense(
      licenseId: json['license_id'] as String,
      customerId: json['customer_id'] as String? ?? 'CIP-DESKTOP-CLIENT',
      customerEmail: json['customer_email'] as String? ?? 'user@cleaninboxpro.com',
      tier: json['tier'] as String,
      dailyLimit: (json['daily_limit'] as num?)?.toInt() ?? 2000,
      duration: json['duration'] as String,
      paymentMethod: json['payment_method'] as String? ?? 'JWC_BSC_BEP20',
      paymentTx: json['payment_tx'] as String,
      paymentNetwork: json['payment_network'] as String? ?? 'BNB Smart Chain (BSC)',
      tokenContract: json['token_contract'] as String? ?? '0xfeeef79d2a97d9e1f9bcb8eba8fd9587079c9e99',
      issuedAt: json['issued_at_iso'] != null
          ? DateTime.parse(json['issued_at_iso'] as String)
          : DateTime.fromMillisecondsSinceEpoch(((json['issued_at'] as num) * 1000).toInt()),
      expiresAt: json['expires_at_iso'] != null
          ? DateTime.parse(json['expires_at_iso'] as String)
          : DateTime.fromMillisecondsSinceEpoch(((json['expires_at'] as num) * 1000).toInt()),
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      signature: json['signature'] as String,
      signatureAlgorithm: json['signature_algorithm'] as String? ?? 'Ed25519',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'license_id': licenseId,
      'customer_id': customerId,
      'customer_email': customerEmail,
      'tier': tier,
      'daily_limit': dailyLimit,
      'duration': duration,
      'payment_method': paymentMethod,
      'payment_tx': paymentTx,
      'payment_network': paymentNetwork,
      'token_contract': tokenContract,
      'issued_at': (issuedAt.millisecondsSinceEpoch / 1000).round(),
      'issued_at_iso': issuedAt.toIso8601String(),
      'expires_at': (expiresAt.millisecondsSinceEpoch / 1000).round(),
      'expires_at_iso': expiresAt.toIso8601String(),
      'features': features,
      'signature': signature,
      'signature_algorithm': signatureAlgorithm,
    };
  }

  /// Exports license to formatted JSON file contents
  String exportJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

