/// JuwishPro - Payment Lifecycle State on BNB Smart Chain
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

/// Represents an active crypto deposit / checkout order on BSC
class CheckoutInvoice {
  final String orderId;
  final String contractAddress;
  final String treasuryAddress;
  final String formattedJwc;
  final double expectedJwcAmount;
  final double jwcPriceUsd;
  final int chainId;
  final String pancakeSwapDeepLink;
  final int requiredConfirmations;
  final DateTime expiresAt;

  const CheckoutInvoice({
    required this.orderId,
    required this.contractAddress,
    required this.treasuryAddress,
    required this.formattedJwc,
    required this.expectedJwcAmount,
    required this.jwcPriceUsd,
    required this.chainId,
    required this.pancakeSwapDeepLink,
    this.requiredConfirmations = 15,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory CheckoutInvoice.defaultJwc({double amount = 1000.0}) {
    return CheckoutInvoice(
      orderId: 'JWC-${DateTime.now().millisecondsSinceEpoch}',
      contractAddress: '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99',
      treasuryAddress: '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99',
      formattedJwc: amount.toStringAsFixed(2),
      expectedJwcAmount: amount,
      jwcPriceUsd: 0.05,
      chainId: 56,
      pancakeSwapDeepLink:
          'https://pancakeswap.finance/swap?outputCurrency=0xfeeef79d2a97d9e1f9bcb8eba8fd9587079c9e99&chainId=56',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }
}
