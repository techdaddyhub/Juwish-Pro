import 'dart:async';
import '../../data/repositories/trading_repository_impl.dart';
import '../../domain/entities/trade_entity.dart';
import '../../domain/repositories/trading_repository.dart';

class TradingState {
  final List<TradeEntity> positions;
  final bool isLoading;
  final int selectedLeverage;
  final TradeSide selectedSide;
  final TradeType selectedType;
  final String? lastSuccessMessage;
  final String? errorMessage;

  const TradingState({
    this.positions = const [],
    this.isLoading = false,
    this.selectedLeverage = 10,
    this.selectedSide = TradeSide.buy,
    this.selectedType = TradeType.futures,
    this.lastSuccessMessage,
    this.errorMessage,
  });

  TradingState copyWith({
    List<TradeEntity>? positions,
    bool? isLoading,
    int? selectedLeverage,
    TradeSide? selectedSide,
    TradeType? selectedType,
    String? lastSuccessMessage,
    String? errorMessage,
  }) {
    return TradingState(
      positions: positions ?? this.positions,
      isLoading: isLoading ?? this.isLoading,
      selectedLeverage: selectedLeverage ?? this.selectedLeverage,
      selectedSide: selectedSide ?? this.selectedSide,
      selectedType: selectedType ?? this.selectedType,
      lastSuccessMessage: lastSuccessMessage,
      errorMessage: errorMessage,
    );
  }
}

class TradingBloc {
  final TradingRepository _repository;
  final _stateController = StreamController<TradingState>.broadcast();

  TradingState _state = const TradingState();
  TradingState get state => _state;
  Stream<TradingState> get stream => _stateController.stream;

  TradingBloc({TradingRepository? repository})
      : _repository = repository ?? TradingRepositoryImpl() {
    _init();
  }

  void _emit(TradingState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> _init() async {
    _emit(_state.copyWith(isLoading: true));
    final positions = await _repository.getActivePositions();
    _emit(_state.copyWith(
      positions: positions,
      isLoading: false,
    ));
  }

  void setLeverage(int leverage) {
    _emit(_state.copyWith(selectedLeverage: leverage));
  }

  void setSide(TradeSide side) {
    _emit(_state.copyWith(selectedSide: side));
  }

  void setTradeType(TradeType type) {
    _emit(_state.copyWith(selectedType: type));
  }

  double calculateLiquidationPrice({
    required double entryPrice,
    required TradeSide side,
    required int leverage,
  }) {
    final maintenanceMargin = 0.005; // 0.5%
    if (side == TradeSide.buy) {
      return entryPrice * (1.0 - (1.0 / leverage) + maintenanceMargin);
    } else {
      return entryPrice * (1.0 + (1.0 / leverage) - maintenanceMargin);
    }
  }

  double calculateMarginRequired({
    required double price,
    required double quantity,
    required int leverage,
  }) {
    if (leverage <= 0) return price * quantity;
    return (price * quantity) / leverage;
  }

  Future<bool> placeOrder({
    required String symbol,
    required double price,
    required double quantity,
    double? stopLoss,
    double? takeProfit,
  }) async {
    _emit(_state.copyWith(isLoading: true));
    try {
      final trade = await _repository.placeOrder(
        symbol: symbol,
        type: _state.selectedType,
        side: _state.selectedSide,
        price: price,
        quantity: quantity,
        leverage: _state.selectedLeverage,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
      );

      final updatedPositions = await _repository.getActivePositions();
      _emit(_state.copyWith(
        positions: updatedPositions,
        isLoading: false,
        lastSuccessMessage:
            'Order placed: ${trade?.side.name.toUpperCase()} $symbol @ \$${price.toStringAsFixed(2)}',
      ));
      return true;
    } catch (e) {
      _emit(_state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<bool> closePosition(String symbol) async {
    _emit(_state.copyWith(isLoading: true));
    final success = await _repository.closePosition(symbol);
    final updatedPositions = await _repository.getActivePositions();
    _emit(_state.copyWith(
      positions: updatedPositions,
      isLoading: false,
      lastSuccessMessage: 'Position closed for $symbol',
    ));
    return success;
  }

  void dispose() {
    _stateController.close();
  }
}
