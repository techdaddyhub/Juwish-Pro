import '../entities/trade_entity.dart';

abstract class TradingRepository {
  Future<List<TradeEntity>> getActivePositions();
  Future<TradeEntity?> placeOrder({
    required String symbol,
    required TradeType type,
    required TradeSide side,
    required double price,
    required double quantity,
    required int leverage,
    double? stopLoss,
    double? takeProfit,
  });
  Future<bool> closePosition(String symbol);
  Future<List<Map<String, dynamic>>> getMarketTickers();
}
