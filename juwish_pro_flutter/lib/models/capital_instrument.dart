enum InstrumentCategory {
  stock,
  etf,
  bond,
  forex,
}

class CapitalInstrument {
  final String ticker;
  final String name;
  final InstrumentCategory category;
  final double currentPrice;
  final double change24h;
  final double? annualYield;
  final double userHolding;
  final List<double> sparkline;

  const CapitalInstrument({
    required this.ticker,
    required this.name,
    required this.category,
    required this.currentPrice,
    required this.change24h,
    this.annualYield,
    this.userHolding = 0.0,
    required this.sparkline,
  });

  String get categoryLabel {
    switch (category) {
      case InstrumentCategory.stock:
        return 'Stock';
      case InstrumentCategory.etf:
        return 'ETF';
      case InstrumentCategory.bond:
        return 'Treasury Bond';
      case InstrumentCategory.forex:
        return 'Forex Pair';
    }
  }

  bool get isPositive => change24h >= 0;

  static List<CapitalInstrument> getCatalog() {
    return [
      const CapitalInstrument(
        ticker: 'NVDA',
        name: 'NVIDIA Corporation',
        category: InstrumentCategory.stock,
        currentPrice: 134.80,
        change24h: 3.42,
        userHolding: 25.0,
        sparkline: [129.0, 130.5, 131.8, 133.0, 132.4, 134.8],
      ),
      const CapitalInstrument(
        ticker: 'AAPL',
        name: 'Apple Inc.',
        category: InstrumentCategory.stock,
        currentPrice: 228.50,
        change24h: 1.15,
        userHolding: 15.0,
        sparkline: [225.0, 226.2, 225.8, 227.4, 228.1, 228.5],
      ),
      const CapitalInstrument(
        ticker: 'TSLA',
        name: 'Tesla, Inc.',
        category: InstrumentCategory.stock,
        currentPrice: 242.10,
        change24h: -1.82,
        userHolding: 8.0,
        sparkline: [248.0, 246.5, 245.0, 243.2, 241.8, 242.1],
      ),
      const CapitalInstrument(
        ticker: 'SPY',
        name: 'SPDR S&P 500 ETF Trust',
        category: InstrumentCategory.etf,
        currentPrice: 588.60,
        change24h: 0.88,
        userHolding: 10.0,
        sparkline: [583.0, 584.2, 586.0, 587.3, 588.6],
      ),
      const CapitalInstrument(
        ticker: 'QQQ',
        name: 'Invesco QQQ Nasdaq 100',
        category: InstrumentCategory.etf,
        currentPrice: 502.40,
        change24h: 1.45,
        userHolding: 12.0,
        sparkline: [494.0, 497.0, 499.5, 501.0, 502.4],
      ),
      const CapitalInstrument(
        ticker: 'US10Y',
        name: '10-Year US Treasury Note',
        category: InstrumentCategory.bond,
        currentPrice: 98.40,
        change24h: 0.12,
        annualYield: 4.28,
        userHolding: 50.0,
        sparkline: [98.1, 98.2, 98.25, 98.35, 98.4],
      ),
      const CapitalInstrument(
        ticker: 'JWC-BOND',
        name: 'JuwishPro Capital Reserve Bond',
        category: InstrumentCategory.bond,
        currentPrice: 100.00,
        change24h: 0.05,
        annualYield: 9.80,
        userHolding: 200.0,
        sparkline: [99.8, 99.9, 99.95, 100.0, 100.0],
      ),
      const CapitalInstrument(
        ticker: 'EUR/USD',
        name: 'Euro / US Dollar',
        category: InstrumentCategory.forex,
        currentPrice: 1.0875,
        change24h: 0.24,
        userHolding: 10000.0,
        sparkline: [1.084, 1.085, 1.086, 1.087, 1.0875],
      ),
      const CapitalInstrument(
        ticker: 'GBP/USD',
        name: 'British Pound / US Dollar',
        category: InstrumentCategory.forex,
        currentPrice: 1.2960,
        change24h: -0.18,
        userHolding: 5000.0,
        sparkline: [1.300, 1.298, 1.297, 1.2965, 1.296],
      ),
    ];
  }
}

