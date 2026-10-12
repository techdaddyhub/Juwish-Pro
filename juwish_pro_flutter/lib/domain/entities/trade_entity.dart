enum TradeType { spot, futures, margin, forex }

enum TradeSide { buy, sell }

class TradeEntity {
  final String symbol;
  final TradeType type;
  final TradeSide side;
  final double entryPrice;
  final double currentPrice;
  final double quantity;
  final int leverage;
  final double marginAmount;
  final double liquidationPrice;
  final double takeProfitPrice;
  final double stopLossPrice;
  final double unrealizedPnl;
  final double unrealizedPnlPercent;
  final DateTime timestamp;

  const TradeEntity({
    required this.symbol,
    required this.type,
    required this.side,
    required this.entryPrice,
    required this.currentPrice,
    required this.quantity,
    this.leverage = 1,
    required this.marginAmount,
    required this.liquidationPrice,
    this.takeProfitPrice = 0.0,
    this.stopLossPrice = 0.0,
    required this.unrealizedPnl,
    required this.unrealizedPnlPercent,
    required this.timestamp,
  });

  bool get isProfitable => unrealizedPnl >= 0;
}
