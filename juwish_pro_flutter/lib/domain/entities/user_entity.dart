class UserEntity {
  final int id;
  final String name;
  final String email;
  final String role;
  final String kycStatus;
  final double jwcBalance;
  final double usdBalance;
  final String referralCode;
  final bool twoFactorEnabled;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.kycStatus,
    required this.jwcBalance,
    required this.usdBalance,
    required this.referralCode,
    this.twoFactorEnabled = false,
    this.avatarUrl,
  });

  bool get isKycApproved => kycStatus.toLowerCase() == 'approved';
  bool get isAdmin =>
      role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin';
}
