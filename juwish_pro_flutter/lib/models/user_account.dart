class UserAccount {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final double fiatBalance;
  final double jwcBalance;
  final double btcBalance;
  final double ethBalance;
  final double usdtBalance;
  final String kycStatus; // 'unverified', 'pending', 'approved'
  final String referralCode;
  final bool twoFactorEnabled;

  const UserAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.fiatBalance,
    required this.jwcBalance,
    required this.btcBalance,
    required this.ethBalance,
    required this.usdtBalance,
    required this.kycStatus,
    required this.referralCode,
    this.twoFactorEnabled = true,
  });

  String get fullName => '$firstName $lastName'.trim();

  double get totalNetWorthUsd {
    const double jwcPrice = 0.0842;
    const double btcPrice = 96420.0;
    const double ethPrice = 3280.0;
    return fiatBalance +
        (jwcBalance * jwcPrice) +
        (btcBalance * btcPrice) +
        (ethBalance * ethPrice) +
        usdtBalance;
  }

  factory UserAccount.mockAdmin() {
    return const UserAccount(
      id: 1,
      firstName: 'Admin',
      lastName: 'JuwishPro',
      email: 'admin@juwish.pro',
      fiatBalance: 24850.00,
      jwcBalance: 1250000.0,
      btcBalance: 1.45,
      ethBalance: 12.80,
      usdtBalance: 18450.00,
      kycStatus: 'approved',
      referralCode: 'JWC-MAGEN-DAVID-2026',
      twoFactorEnabled: true,
    );
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as int? ?? 1,
      firstName: json['first_name'] as String? ?? 'User',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fiatBalance: (json['fiat_balance'] as num?)?.toDouble() ?? 0.0,
      jwcBalance: (json['jwc_balance'] as num?)?.toDouble() ?? 0.0,
      btcBalance: (json['btc_balance'] as num?)?.toDouble() ?? 0.0,
      ethBalance: (json['eth_balance'] as num?)?.toDouble() ?? 0.0,
      usdtBalance: (json['usdt_balance'] as num?)?.toDouble() ?? 0.0,
      kycStatus: json['kyc_status'] as String? ?? 'unverified',
      referralCode: json['referral_code'] as String? ?? 'JWC-REF',
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'fiat_balance': fiatBalance,
      'jwc_balance': jwcBalance,
      'btc_balance': btcBalance,
      'eth_balance': ethBalance,
      'usdt_balance': usdtBalance,
      'kyc_status': kycStatus,
      'referral_code': referralCode,
      'two_factor_enabled': twoFactorEnabled,
    };
  }
}

