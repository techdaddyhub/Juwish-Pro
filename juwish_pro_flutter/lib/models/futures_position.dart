class FuturesPosition {
  final String id;
  final String symbol;
  final bool isLong;
  final int leverage;
  final double entryPrice;
  final double markPrice;
  final double size;
  final double margin;
  final double? takeProfit;
  final double? stopLoss;
  final double liquidationPrice;

  const FuturesPosition({
    required this.id,
    required this.symbol,
    required this.isLong,
    required this.leverage,
    required this.entryPrice,
    required this.markPrice,
    required this.size,
    required this.margin,
    this.takeProfit,
    this.stopLoss,
    required this.liquidationPrice,
  });

  double get unrealizedPnl {
    if (isLong) {
      return (markPrice - entryPrice) * size;
    } else {
      return (entryPrice - markPrice) * size;
    }
  }

  double get returnOnEquityPercent {
    if (margin == 0) return 0.0;
    return (unrealizedPnl / margin) * 100.0;
  }

  bool get isInProfit => unrealizedPnl >= 0;

  static List<FuturesPosition> getMockPositions() {
    return [
      const FuturesPosition(
        id: 'POS-JWC-8921',
        symbol: 'JWC/USDT',
        isLong: true,
        leverage: 20,
        entryPrice: 0.0810,
        markPrice: 0.0842,
        size: 500000.0,
        margin: 2025.0,
        takeProfit: 0.1000,
        stopLoss: 0.0750,
        liquidationPrice: 0.0769,
      ),
      const FuturesPosition(
        id: 'POS-BTC-3391',
        symbol: 'BTC/USDT',
        isLong: true,
        leverage: 50,
        entryPrice: 94800.0,
        markPrice: 96420.0,
        size: 0.85,
        margin: 1611.6,
        takeProfit: 100000.0,
        stopLoss: 93000.0,
        liquidationPrice: 92904.0,
      ),
      const FuturesPosition(
        id: 'POS-ETH-1102',
        symbol: 'ETH/USDT',
        isLong: false,
        leverage: 25,
        entryPrice: 3340.0,
        markPrice: 3280.0,
        size: 5.0,
        margin: 668.0,
        takeProfit: 3150.0,
        stopLoss: 3420.0,
        liquidationPrice: 3473.6,
      ),
    ];
  }
}

