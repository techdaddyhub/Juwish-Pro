class MarketPair {
  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final String name;
  final double lastPrice;
  final double change24hPercent;
  final double high24h;
  final double low24h;
  final double volume24h;
  final List<double> sparkline;
  final bool isJwc;
  final String category;

  const MarketPair({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.name,
    required this.lastPrice,
    required this.change24hPercent,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.sparkline,
    this.isJwc = false,
    this.category = 'Spot',
  });

  bool get isBullish => change24hPercent >= 0;

  String get formattedPrice {
    if (lastPrice >= 1000) {
      return '\$${lastPrice.toStringAsFixed(2)}';
    } else if (lastPrice >= 1) {
      return '\$${lastPrice.toStringAsFixed(4)}';
    } else {
      return '\$${lastPrice.toStringAsFixed(6)}';
    }
  }

  String get formattedChange {
    final prefix = isBullish ? '+' : '';
    return '$prefix${change24hPercent.toStringAsFixed(2)}%';
  }
}
