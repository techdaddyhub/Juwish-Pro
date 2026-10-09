/// Payment lifecycle state on BNB Smart Chain
enum PaymentStatus {
  idle,
  creatingInvoice,
  awaitingPayment,
  txDetected,
  confirming,
  confirmed,
  expired,
  error
}

/// Represents an active crypto checkout order on BSC
class CheckoutInvoice {
  final String orderId;
  final String tier;
  final String duration;
  final int dailyLimit;
  final double priceUsd;
  final double expectedJwcAmount;
  final String formattedJwc;
  final double jwcPriceUsd;
  final String treasuryAddress;
  final String contractAddress;
  final int chainId;
  final String pancakeSwapDeepLink;
  final int requiredConfirmations;
  final DateTime expiresAt;

  const CheckoutInvoice({
    required this.orderId,
    required this.tier,
    required this.duration,
    required this.dailyLimit,
    required this.priceUsd,
    required this.expectedJwcAmount,
    required this.formattedJwc,
    required this.jwcPriceUsd,
    required this.treasuryAddress,
    required this.contractAddress,
    required this.chainId,
    required this.pancakeSwapDeepLink,
    required this.requiredConfirmations,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  factory CheckoutInvoice.fromJson(Map<String, dynamic> json) {
    return CheckoutInvoice(
      orderId: json['orderId'] as String,
      tier: json['tier'] as String,
      duration: json['duration'] as String,
      dailyLimit: (json['dailyLimit'] as num?)?.toInt() ?? 2000,
      priceUsd: (json['priceUsd'] as num).toDouble(),
      expectedJwcAmount: (json['expectedJwcAmount'] as num).toDouble(),
      formattedJwc: json['formattedJwc'] as String? ?? '${json['expectedJwcAmount']} JWC',
      jwcPriceUsd: (json['jwcPriceUsd'] as num).toDouble(),
      treasuryAddress: json['treasuryAddress'] as String,
      contractAddress: json['contractAddress'] as String,
      chainId: (json['chainId'] as num?)?.toInt() ?? 56,
      pancakeSwapDeepLink: json['pancakeSwapDeepLink'] as String,
      requiredConfirmations: (json['requiredConfirmations'] as num?)?.toInt() ?? 15,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] as int),
    );
  }

  /// Generates EIP-681 / BEP-20 formatted payment URI for crypto wallets
  String toWalletQrUri() {
    // EIP-681 standard for token transfer:
    // ethereum:<token_contract>@<chain_id>/transfer?address=<recipient>&uint256=<amount_in_wei>
    final rawAmountBigInt = BigInt.from(expectedJwcAmount * 1e18);
    return 'ethereum:$contractAddress@$chainId/transfer?address=$treasuryAddress&uint256=$rawAmountBigInt';
  }
}

