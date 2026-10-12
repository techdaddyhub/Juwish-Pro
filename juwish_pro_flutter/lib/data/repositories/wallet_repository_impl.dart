import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final List<WalletAsset> _assets = const [
    WalletAsset(
      symbol: 'JWC',
      name: 'JuwishCoin',
      balance: 25000.0,
      priceUsd: 1.4250,
      change24h: 34.80,
      network: 'BSC (BEP-20)',
      isNative: true,
    ),
    WalletAsset(
      symbol: 'USDT',
      name: 'Tether USD',
      balance: 14250.0,
      priceUsd: 1.00,
      change24h: 0.01,
      network: 'TRC-20 / BEP-20',
      isNative: false,
    ),
    WalletAsset(
      symbol: 'BTC',
      name: 'Bitcoin',
      balance: 0.65,
      priceUsd: 65420.0,
      change24h: 3.45,
      network: 'Bitcoin Native',
      isNative: false,
    ),
    WalletAsset(
      symbol: 'ETH',
      name: 'Ethereum',
      balance: 4.80,
      priceUsd: 3512.40,
      change24h: 2.18,
      network: 'ERC-20',
      isNative: false,
    ),
    WalletAsset(
      symbol: 'BNB',
      name: 'BNB Chain',
      balance: 18.50,
      priceUsd: 592.80,
      change24h: 4.12,
      network: 'BEP-20',
      isNative: false,
    ),
  ];

  final List<TransactionRecord> _transactions = [
    TransactionRecord(
      id: 'TX-9014',
      txHash: '0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c',
      type: TransactionType.deposit,
      status: TransactionStatus.settled,
      asset: 'JWC',
      amount: 10000.0,
      amountUsd: 14250.0,
      destination: '0x3aF8795A40129a03975CFFa7Ea37eb5f02D15792',
      network: 'BSC (BEP-20)',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    TransactionRecord(
      id: 'TX-8921',
      txHash: '0x9924ba91d248bcf02a39d891b248aef02c771120',
      type: TransactionType.stakingReward,
      status: TransactionStatus.settled,
      asset: 'JWC',
      amount: 385.20,
      amountUsd: 548.91,
      destination: 'JuwishPro Genesis Vault',
      network: 'Internal Staking',
      createdAt: DateTime.now().subtract(const Duration(hours: 24)),
    ),
    TransactionRecord(
      id: 'TX-8812',
      txHash: '0x551a0293ebcf48192a0149bb8283a00148cba012',
      type: TransactionType.withdrawal,
      status: TransactionStatus.approved,
      asset: 'USDT',
      amount: 2500.0,
      amountUsd: 2500.0,
      destination: 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
      network: 'TRC-20',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionRecord(
      id: 'TX-8740',
      txHash: '0x1288cba029148ccba920147bb02187fca0192801',
      type: TransactionType.tradeProfit,
      status: TransactionStatus.settled,
      asset: 'USDT',
      amount: 1480.0,
      amountUsd: 1480.0,
      destination: 'BTC/USDT 20x Futures Close',
      network: 'Trading Engine',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<WalletAsset>> getWalletAssets() async {
    return List.unmodifiable(_assets);
  }

  @override
  Future<List<TransactionRecord>> getTransactionHistory(
      {String? filterType}) async {
    if (filterType == null || filterType == 'All') {
      return List.unmodifiable(_transactions);
    }
    return _transactions.where((t) {
      return t.type.name.toLowerCase() == filterType.toLowerCase() ||
          t.status.name.toLowerCase() == filterType.toLowerCase();
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> initiateCryptoDeposit({
    required String asset,
    required double amount,
    required String network,
  }) async {
    return {
      'success': true,
      'address': '0x3aF8795A40129a03975CFFa7Ea37eb5f02D15792',
      'asset': asset,
      'amount': amount,
      'network': network,
      'memo': 'JWC-DEPOSIT-${DateTime.now().millisecondsSinceEpoch}',
      'qrData': 'bsc:0x3aF8795A40129a03975CFFa7Ea37eb5f02D15792?amount=$amount',
    };
  }

  @override
  Future<Map<String, dynamic>> requestWithdrawal({
    required String asset,
    required double amount,
    required String destinationAddress,
    required String network,
  }) async {
    final tx = TransactionRecord(
      id: 'TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      txHash:
          '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}0091ba82',
      type: TransactionType.withdrawal,
      status: TransactionStatus.pending,
      asset: asset,
      amount: amount,
      amountUsd: amount * (asset == 'JWC' ? 1.425 : 1.0),
      destination: destinationAddress,
      network: network,
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, tx);
    return {'success': true, 'tx': tx};
  }
}
