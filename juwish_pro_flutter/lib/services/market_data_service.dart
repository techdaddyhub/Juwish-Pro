import '../models/market_pair.dart';

class MarketDataService {
  static final MarketDataService _instance = MarketDataService._internal();
  factory MarketDataService() => _instance;
  MarketDataService._internal();

  final List<MarketPair> _pairs = const [
    MarketPair(
      symbol: 'JWC/USDT',
      baseAsset: 'JWC',
      quoteAsset: 'USDT',
      name: 'JuwishCoin (BEP-20)',
      lastPrice: 1.4250,
      change24hPercent: 34.80,
      high24h: 1.5800,
      low24h: 1.0420,
      volume24h: 28410920.0,
      sparkline: [1.04, 1.12, 1.10, 1.25, 1.22, 1.35, 1.30, 1.42, 1.425],
      isJwc: true,
      category: 'JWC',
    ),
    MarketPair(
      symbol: 'JWC/BNB',
      baseAsset: 'JWC',
      quoteAsset: 'BNB',
      name: 'JuwishCoin / BNB',
      lastPrice: 0.00243,
      change24hPercent: 28.50,
      high24h: 0.00265,
      low24h: 0.00185,
      volume24h: 8940300.0,
      sparkline: [0.0019, 0.0020, 0.0022, 0.0021, 0.0023, 0.00243],
      isJwc: true,
      category: 'JWC',
    ),
    MarketPair(
      symbol: 'BTC/USDT',
      baseAsset: 'BTC',
      quoteAsset: 'USDT',
      name: 'Bitcoin',
      lastPrice: 65420.00,
      change24hPercent: 3.45,
      high24h: 66100.00,
      low24h: 63800.00,
      volume24h: 1420800000.0,
      sparkline: [63800, 64100, 64500, 64200, 65000, 65200, 65420],
      isJwc: false,
      category: 'Spot',
    ),
    MarketPair(
      symbol: 'ETH/USDT',
      baseAsset: 'ETH',
      quoteAsset: 'USDT',
      name: 'Ethereum',
      lastPrice: 3512.40,
      change24hPercent: 2.18,
      high24h: 3580.00,
      low24h: 3420.00,
      volume24h: 820400000.0,
      sparkline: [3420, 3440, 3480, 3460, 3500, 3512.4],
      isJwc: false,
      category: 'Spot',
    ),
    MarketPair(
      symbol: 'BNB/USDT',
      baseAsset: 'BNB',
      quoteAsset: 'USDT',
      name: 'BNB Smart Chain',
      lastPrice: 592.80,
      change24hPercent: 4.12,
      high24h: 598.00,
      low24h: 568.50,
      volume24h: 310500000.0,
      sparkline: [568.5, 574.0, 582.0, 579.0, 588.0, 592.8],
      isJwc: false,
      category: 'Spot',
    ),
    MarketPair(
      symbol: 'SOL/USDT',
      baseAsset: 'SOL',
      quoteAsset: 'USDT',
      name: 'Solana',
      lastPrice: 154.20,
      change24hPercent: -1.25,
      high24h: 159.00,
      low24h: 151.80,
      volume24h: 490200000.0,
      sparkline: [157.0, 159.0, 156.0, 154.0, 153.0, 154.2],
      isJwc: false,
      category: 'Futures',
    ),
    MarketPair(
      symbol: 'XRP/USDT',
      baseAsset: 'XRP',
      quoteAsset: 'USDT',
      name: 'Ripple',
      lastPrice: 0.5840,
      change24hPercent: 0.85,
      high24h: 0.5920,
      low24h: 0.5750,
      volume24h: 195000000.0,
      sparkline: [0.575, 0.578, 0.581, 0.579, 0.583, 0.584],
      isJwc: false,
      category: 'Spot',
    ),
  ];

  List<MarketPair> getAllPairs() => List.unmodifiable(_pairs);

  List<MarketPair> filterPairs({String category = 'All', String query = ''}) {
    return _pairs.where((p) {
      final matchesCategory = category == 'All' ||
          (category == 'JWC' && p.isJwc) ||
          p.category.toLowerCase() == category.toLowerCase();

      final matchesQuery = query.isEmpty ||
          p.symbol.toLowerCase().contains(query.toLowerCase()) ||
          p.name.toLowerCase().contains(query.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();
  }
}
