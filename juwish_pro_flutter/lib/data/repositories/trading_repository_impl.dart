import '../../domain/entities/trade_entity.dart';
import '../../domain/repositories/trading_repository.dart';
import '../datasources/remote_datasource.dart';

class TradingRepositoryImpl implements TradingRepository {
  final RemoteDataSource _remote;
  final List<TradeEntity> _activePositions = [];

  TradingRepositoryImpl({RemoteDataSource? remote})
      : _remote = remote ?? RemoteDataSource() {
    _activePositions.addAll([
      TradeEntity(
        symbol: 'JWC/USDT',
        type: TradeType.futures,
        side: TradeSide.buy,
        entryPrice: 1.2500,
        currentPrice: 1.4250,
        quantity: 5000,
        leverage: 10,
        marginAmount: 625.0,
        liquidationPrice: 0.9500,
        takeProfitPrice: 1.8500,
        stopLossPrice: 1.1000,
        unrealizedPnl: 875.0,
        unrealizedPnlPercent: 140.0,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      TradeEntity(
        symbol: 'BTC/USDT',
        type: TradeType.futures,
        side: TradeSide.buy,
        entryPrice: 63800.0,
        currentPrice: 65420.0,
        quantity: 0.25,
        leverage: 20,
        marginAmount: 797.5,
        liquidationPrice: 60500.0,
        takeProfitPrice: 70000.0,
        stopLossPrice: 62000.0,
        unrealizedPnl: 405.0,
        unrealizedPnlPercent: 50.78,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ]);
  }

  @override
  Future<List<TradeEntity>> getActivePositions() async {
    return List.unmodifiable(_activePositions);
  }

  @override
  Future<TradeEntity?> placeOrder({
    required String symbol,
    required TradeType type,
    required TradeSide side,
    required double price,
    required double quantity,
    required int leverage,
    double? stopLoss,
    double? takeProfit,
  }) async {
    final margin = (price * quantity) / leverage;
    final liq = side == TradeSide.buy
        ? price * (1 - (1.0 / leverage) * 0.9)
        : price * (1 + (1.0 / leverage) * 0.9);

    final position = TradeEntity(
      symbol: symbol,
      type: type,
      side: side,
      entryPrice: price,
      currentPrice: price,
      quantity: quantity,
      leverage: leverage,
      marginAmount: margin,
      liquidationPrice: liq,
      takeProfitPrice: takeProfit ?? (price * 1.2),
      stopLossPrice: stopLoss ?? (price * 0.9),
      unrealizedPnl: 0.0,
      unrealizedPnlPercent: 0.0,
      timestamp: DateTime.now(),
    );

    _activePositions.insert(0, position);
    return position;
  }

  @override
  Future<bool> closePosition(String symbol) async {
    _activePositions.removeWhere((p) => p.symbol == symbol);
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getMarketTickers() async {
    final live = await _remote.getTickers();
    if (live.isNotEmpty) {
      return List<Map<String, dynamic>>.from(live);
    }
    return [
      {
        'symbol': 'JWC/USDT',
        'price': 1.4250,
        'change_24h': 34.80,
        'high_24h': 1.5800,
        'low_24h': 1.0420,
        'volume_24h': 28410920.0,
        'is_jwc': true,
      },
      {
        'symbol': 'BTC/USDT',
        'price': 65420.0,
        'change_24h': 3.45,
        'high_24h': 66100.0,
        'low_24h': 63800.0,
        'volume_24h': 1420800000.0,
        'is_jwc': false,
      },
    ];
  }
}
