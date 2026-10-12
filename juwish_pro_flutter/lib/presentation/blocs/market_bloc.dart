import 'dart:async';
import 'dart:math';
import '../../data/repositories/trading_repository_impl.dart';
import '../../domain/repositories/trading_repository.dart';

class MarketTicker {
  final String symbol;
  final double price;
  final double change24h;
  final double high24h;
  final double low24h;
  final double volume24h;
  final bool isJwc;

  const MarketTicker({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    this.isJwc = false,
  });

  MarketTicker copyWith({
    double? price,
    double? change24h,
    double? high24h,
    double? low24h,
    double? volume24h,
  }) {
    return MarketTicker(
      symbol: symbol,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume24h: volume24h ?? this.volume24h,
      isJwc: isJwc,
    );
  }
}

class MarketState {
  final List<MarketTicker> tickers;
  final MarketTicker? activeTicker;
  final bool isLoading;

  const MarketState({
    this.tickers = const [],
    this.activeTicker,
    this.isLoading = true,
  });

  MarketState copyWith({
    List<MarketTicker>? tickers,
    MarketTicker? activeTicker,
    bool? isLoading,
  }) {
    return MarketState(
      tickers: tickers ?? this.tickers,
      activeTicker: activeTicker ?? this.activeTicker,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MarketBloc {
  final TradingRepository _repository;
  final _stateController = StreamController<MarketState>.broadcast();
  Timer? _tickerTimer;

  MarketState _state = const MarketState();
  MarketState get state => _state;
  Stream<MarketState> get stream => _stateController.stream;

  MarketBloc({TradingRepository? repository})
      : _repository = repository ?? TradingRepositoryImpl() {
    _init();
  }

  void _emit(MarketState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _init() async {
    final rawTickers = await _repository.getMarketTickers();
    final List<MarketTicker> list = [];

    if (rawTickers.isNotEmpty) {
      for (final item in rawTickers) {
        list.add(MarketTicker(
          symbol: item['symbol']?.toString() ?? 'JWC/USDT',
          price: (item['price'] as num?)?.toDouble() ?? 1.4250,
          change24h: (item['change_24h'] as num?)?.toDouble() ?? 34.8,
          high24h: (item['high_24h'] as num?)?.toDouble() ?? 1.58,
          low24h: (item['low_24h'] as num?)?.toDouble() ?? 1.04,
          volume24h: (item['volume_24h'] as num?)?.toDouble() ?? 28400000.0,
          isJwc: item['symbol']?.toString().contains('JWC') ?? false,
        ));
      }
    } else {
      list.addAll([
        const MarketTicker(
          symbol: 'JWC/USDT',
          price: 1.4250,
          change24h: 34.80,
          high24h: 1.5800,
          low24h: 1.0420,
          volume24h: 28410920.0,
          isJwc: true,
        ),
        const MarketTicker(
          symbol: 'BTC/USDT',
          price: 65420.0,
          change24h: 3.45,
          high24h: 66100.0,
          low24h: 63800.0,
          volume24h: 1420800000.0,
        ),
        const MarketTicker(
          symbol: 'ETH/USDT',
          price: 3512.40,
          change24h: 2.18,
          high24h: 3580.0,
          low24h: 3410.0,
          volume24h: 890400000.0,
        ),
        const MarketTicker(
          symbol: 'SOL/USDT',
          price: 148.60,
          change24h: 8.92,
          high24h: 154.20,
          low24h: 136.50,
          volume24h: 420500000.0,
        ),
        const MarketTicker(
          symbol: 'BNB/USDT',
          price: 592.80,
          change24h: 4.12,
          high24h: 604.0,
          low24h: 578.0,
          volume24h: 310200000.0,
        ),
      ]);
    }

    _emit(_state.copyWith(
      tickers: list,
      activeTicker: list.isNotEmpty ? list.first : null,
      isLoading: false,
    ));

    _startLiveStream();
  }

  void _startLiveStream() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final random = Random();
      final updatedList = _state.tickers.map((t) {
        if (t.isJwc) {
          // Native JWC micro fluctuation around $1.425 base
          final delta = (random.nextDouble() - 0.45) * 0.008;
          final newPrice = (t.price + delta).clamp(1.20, 1.95);
          return t.copyWith(price: double.parse(newPrice.toStringAsFixed(4)));
        } else {
          final factor = 1.0 + (random.nextDouble() - 0.48) * 0.004;
          return t.copyWith(
              price: double.parse((t.price * factor).toStringAsFixed(2)));
        }
      }).toList();

      MarketTicker? newActive;
      if (_state.activeTicker != null) {
        newActive = updatedList.firstWhere(
          (t) => t.symbol == _state.activeTicker!.symbol,
          orElse: () => updatedList.first,
        );
      }

      _emit(_state.copyWith(
        tickers: updatedList,
        activeTicker: newActive ?? (_state.activeTicker),
      ));
    });
  }

  void selectTicker(String symbol) {
    final ticker = _state.tickers.firstWhere(
      (t) => t.symbol == symbol,
      orElse: () => _state.tickers.first,
    );
    _emit(_state.copyWith(activeTicker: ticker));
  }

  void dispose() {
    _tickerTimer?.cancel();
    _stateController.close();
  }
}
