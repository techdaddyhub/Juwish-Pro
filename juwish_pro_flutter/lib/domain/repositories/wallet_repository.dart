import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletAsset>> getWalletAssets();
  Future<List<TransactionRecord>> getTransactionHistory({String? filterType});
  Future<Map<String, dynamic>> initiateCryptoDeposit({
    required String asset,
    required double amount,
    required String network,
  });
  Future<Map<String, dynamic>> requestWithdrawal({
    required String asset,
    required double amount,
    required String destinationAddress,
    required String network,
  });
}
