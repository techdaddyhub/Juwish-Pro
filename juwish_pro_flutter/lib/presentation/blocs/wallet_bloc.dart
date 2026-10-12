import 'dart:async';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletState {
  final List<WalletAsset> assets;
  final List<TransactionRecord> transactions;
  final String activeFilter;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? activeDepositSession;

  const WalletState({
    this.assets = const [],
    this.transactions = const [],
    this.activeFilter = 'All',
    this.isLoading = true,
    this.errorMessage,
    this.activeDepositSession,
  });

  double get totalPortfolioUsd {
    return assets.fold(0.0, (sum, a) => sum + a.valueUsd);
  }

  double get jwcBalance {
    final jwc = assets.firstWhere((a) => a.symbol == 'JWC',
        orElse: () => const WalletAsset(
              symbol: 'JWC',
              name: 'JuwishCoin',
              balance: 0.0,
              priceUsd: 1.425,
              change24h: 0.0,
              network: 'BSC',
              isNative: true,
            ));
    return jwc.balance;
  }

  WalletState copyWith({
    List<WalletAsset>? assets,
    List<TransactionRecord>? transactions,
    String? activeFilter,
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? activeDepositSession,
  }) {
    return WalletState(
      assets: assets ?? this.assets,
      transactions: transactions ?? this.transactions,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeDepositSession: activeDepositSession ?? this.activeDepositSession,
    );
  }
}

class WalletBloc {
  final WalletRepository _repository;
  final _stateController = StreamController<WalletState>.broadcast();

  WalletState _state = const WalletState();
  WalletState get state => _state;
  Stream<WalletState> get stream => _stateController.stream;

  WalletBloc({WalletRepository? repository})
      : _repository = repository ?? WalletRepositoryImpl() {
    _init();
  }

  void _emit(WalletState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _init() async {
    _emit(_state.copyWith(isLoading: true));
    final assets = await _repository.getWalletAssets();
    final txs = await _repository.getTransactionHistory();
    _emit(_state.copyWith(
      assets: assets,
      transactions: txs,
      isLoading: false,
    ));
  }

  Future<void> filterTransactions(String filter) async {
    _emit(_state.copyWith(isLoading: true, activeFilter: filter));
    final txs = await _repository.getTransactionHistory(
      filterType: filter == 'All' ? null : filter,
    );
    _emit(_state.copyWith(
      transactions: txs,
      isLoading: false,
    ));
  }

  Future<Map<String, dynamic>> generateDepositAddress({
    required String asset,
    required double amount,
    required String network,
  }) async {
    _emit(_state.copyWith(isLoading: true));
    final session = await _repository.initiateCryptoDeposit(
      asset: asset,
      amount: amount,
      network: network,
    );
    _emit(_state.copyWith(
      isLoading: false,
      activeDepositSession: session,
    ));
    return session;
  }

  Future<bool> submitWithdrawal({
    required String asset,
    required double amount,
    required String destinationAddress,
    required String network,
  }) async {
    _emit(_state.copyWith(isLoading: true));
    try {
      final res = await _repository.requestWithdrawal(
        asset: asset,
        amount: amount,
        destinationAddress: destinationAddress,
        network: network,
      );
      if (res['success'] == true) {
        final txs = await _repository.getTransactionHistory(
          filterType: _state.activeFilter == 'All' ? null : _state.activeFilter,
        );
        _emit(_state.copyWith(
          transactions: txs,
          isLoading: false,
        ));
        return true;
      }
      _emit(_state.copyWith(isLoading: false));
      return false;
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  void dispose() {
    _stateController.close();
  }
}
