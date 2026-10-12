enum TransactionType {
  deposit,
  withdrawal,
  tradeProfit,
  stakingReward,
  transfer
}

enum TransactionStatus { pending, approved, settled, rejected }

class TransactionRecord {
  final String id;
  final String txHash;
  final TransactionType type;
  final TransactionStatus status;
  final String asset;
  final double amount;
  final double amountUsd;
  final String destination;
  final String network;
  final DateTime createdAt;

  const TransactionRecord({
    required this.id,
    required this.txHash,
    required this.type,
    required this.status,
    required this.asset,
    required this.amount,
    required this.amountUsd,
    required this.destination,
    required this.network,
    required this.createdAt,
  });
}

class WalletAsset {
  final String symbol;
  final String name;
  final double balance;
  final double priceUsd;
  final double change24h;
  final String network;
  final bool isNative;

  const WalletAsset({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.priceUsd,
    required this.change24h,
    required this.network,
    this.isNative = false,
  });

  double get valueUsd => balance * priceUsd;
}
