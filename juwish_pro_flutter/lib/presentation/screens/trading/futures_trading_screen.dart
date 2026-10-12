import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/trade_entity.dart';
import '../../../theme/app_theme.dart';
import '../../blocs/market_bloc.dart';
import '../../blocs/trading_bloc.dart';
import '../../widgets/candlestick_chart_widget.dart';

class FuturesTradingScreen extends StatefulWidget {
  final TradingBloc tradingBloc;
  final MarketBloc marketBloc;

  const FuturesTradingScreen({
    super.key,
    required this.tradingBloc,
    required this.marketBloc,
  });

  @override
  State<FuturesTradingScreen> createState() => _FuturesTradingScreenState();
}

class _FuturesTradingScreenState extends State<FuturesTradingScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: '1000');
  final TextEditingController _tpController = TextEditingController();
  final TextEditingController _slController = TextEditingController();

  TradeSide _side = TradeSide.buy;
  int _leverage = 10;
  String _selectedPair = 'JWC/USDT';

  @override
  void dispose() {
    _amountController.dispose();
    _tpController.dispose();
    _slController.dispose();
    super.dispose();
  }

  void _onLeverageChanged(double val) {
    setState(() {
      _leverage = val.toInt();
    });
    widget.tradingBloc.setLeverage(_leverage);
  }

  void _executeOrder(double currentPrice) async {
    final amount = double.tryParse(_amountController.text) ?? 1000.0;
    final tp = double.tryParse(_tpController.text);
    final sl = double.tryParse(_slController.text);

    HapticFeedback.heavyImpact();
    final success = await widget.tradingBloc.placeOrder(
      symbol: _selectedPair,
      price: currentPrice,
      quantity: amount / currentPrice,
      stopLoss: sl,
      takeProfit: tp,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${_side.name.toUpperCase()} $_selectedPair @ ${_leverage}x Leverage executed successfully!'),
          backgroundColor: _side == TradeSide.buy
              ? AppTheme.greenBullish
              : AppTheme.redBearish,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MarketState>(
      stream: widget.marketBloc.stream,
      initialData: widget.marketBloc.state,
      builder: (context, marketSnapshot) {
        final marketState = marketSnapshot.data ?? const MarketState();
        final activeTicker = marketState.tickers.firstWhere(
          (t) => t.symbol == _selectedPair,
          orElse: () => marketState.tickers.isNotEmpty
              ? marketState.tickers.first
              : const MarketTicker(
                  symbol: 'JWC/USDT',
                  price: 1.425,
                  change24h: 34.8,
                  high24h: 1.58,
                  low24h: 1.04,
                  volume24h: 28400000,
                  isJwc: true),
        );

        return StreamBuilder<TradingState>(
          stream: widget.tradingBloc.stream,
          initialData: widget.tradingBloc.state,
          builder: (context, tradingSnapshot) {
            final tradingState = tradingSnapshot.data ?? const TradingState();

            final double notional =
                double.tryParse(_amountController.text) ?? 1000.0;
            final double marginReq = notional / _leverage;
            final double liqPrice =
                widget.tradingBloc.calculateLiquidationPrice(
              entryPrice: activeTicker.price,
              side: _side,
              leverage: _leverage,
            );

            return Scaffold(
              backgroundColor: AppTheme.nightObsidian,
              appBar: AppBar(
                title: Text('Futures Trading (${activeTicker.symbol})'),
                backgroundColor: AppTheme.nightObsidian,
                elevation: 0,
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.currency_exchange,
                        color: AppTheme.gold),
                    color: AppTheme.surfaceCharcoal,
                    onSelected: (val) {
                      setState(() => _selectedPair = val);
                    },
                    itemBuilder: (ctx) {
                      return marketState.tickers.map((t) {
                        return PopupMenuItem(
                            value: t.symbol,
                            child: Text(t.symbol,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary)));
                      }).toList();
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activeTicker.price < 5
                              ? '\$${activeTicker.price.toStringAsFixed(4)}'
                              : AppFormatters.formatUsd(activeTicker.price),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: activeTicker.change24h >= 0
                                ? AppTheme.greenBullish
                                : AppTheme.redBearish,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: activeTicker.change24h >= 0
                                ? AppTheme.greenBullish.withOpacity(0.15)
                                : AppTheme.redBearish.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppFormatters.formatPercentage(
                                activeTicker.change24h),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: activeTicker.change24h >= 0
                                  ? AppTheme.greenBullish
                                  : AppTheme.redBearish,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Interactive Candlestick Chart
                    CandlestickChartWidget(
                      symbol: activeTicker.symbol,
                      basePrice: activeTicker.price,
                      isJwc: activeTicker.isJwc,
                      height: 250,
                    ),

                    const SizedBox(height: 16),

                    // Side selector: Long (Buy) vs Short (Sell)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _side == TradeSide.buy
                                  ? AppTheme.greenBullish
                                  : AppTheme.surfaceCharcoal,
                              foregroundColor: AppTheme.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() => _side = TradeSide.buy);
                              widget.tradingBloc.setSide(TradeSide.buy);
                            },
                            child: const Text('LONG (BUY)',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _side == TradeSide.sell
                                  ? AppTheme.redBearish
                                  : AppTheme.surfaceCharcoal,
                              foregroundColor: AppTheme.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() => _side = TradeSide.sell);
                              widget.tradingBloc.setSide(TradeSide.sell);
                            },
                            child: const Text('SHORT (SELL)',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Leverage Slider (1x to 125x)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCharcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderHighlight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Adjust Leverage',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13)),
                              Text(
                                '${_leverage}x',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.gold),
                              ),
                            ],
                          ),
                          Slider(
                            value: _leverage.toDouble(),
                            min: 1,
                            max: 125,
                            divisions: 124,
                            activeColor: AppTheme.gold,
                            inactiveColor: AppTheme.nightObsidian,
                            onChanged: _onLeverageChanged,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [1, 25, 50, 75, 100, 125].map((lvl) {
                              return GestureDetector(
                                onTap: () => _onLeverageChanged(lvl.toDouble()),
                                child: Text(
                                  '${lvl}x',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: _leverage == lvl
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _leverage == lvl
                                        ? AppTheme.gold
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Order inputs
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Order Size (USDT Notional)',
                        labelStyle:
                            const TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceCharcoal,
                        prefixText: '\$ ',
                        prefixStyle: const TextStyle(color: AppTheme.gold),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppTheme.borderHighlight),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // TP / SL inputs
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tpController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Take Profit (\$)',
                              labelStyle: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                              filled: true,
                              fillColor: AppTheme.surfaceCharcoal,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppTheme.borderHighlight),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _slController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Stop Loss (\$)',
                              labelStyle: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                              filled: true,
                              fillColor: AppTheme.surfaceCharcoal,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppTheme.borderHighlight),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Risk metrics card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCharcoal,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderHighlight),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow('Required Margin',
                              AppFormatters.formatUsd(marginReq)),
                          const Divider(color: AppTheme.borderHighlight),
                          _buildStatRow(
                            'Est. Liquidation Price',
                            liqPrice < 5
                                ? '\$${liqPrice.toStringAsFixed(4)}'
                                : AppFormatters.formatUsd(liqPrice),
                            highlight: true,
                          ),
                          const Divider(color: AppTheme.borderHighlight),
                          _buildStatRow('Maker / Taker Fee', '0.02% / 0.04%'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Submit Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _side == TradeSide.buy
                              ? AppTheme.greenBullish
                              : AppTheme.redBearish,
                          foregroundColor: AppTheme.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _executeOrder(activeTicker.price),
                        child: Text(
                          'Open ${_side.name.toUpperCase()} $_selectedPair (${_leverage}x)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Active Positions List
                    const Text(
                      'Open Futures Positions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (tradingState.positions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: const Text('No open futures positions',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tradingState.positions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final pos = tradingState.positions[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCharcoal,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppTheme.borderHighlight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: pos.side == TradeSide.buy
                                                ? AppTheme.greenBullish
                                                    .withOpacity(0.2)
                                                : AppTheme.redBearish
                                                    .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${pos.side.name.toUpperCase()} ${pos.leverage}x',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: pos.side == TradeSide.buy
                                                  ? AppTheme.greenBullish
                                                  : AppTheme.redBearish,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(pos.symbol,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary)),
                                      ],
                                    ),
                                    Text(
                                      '${pos.unrealizedPnl >= 0 ? '+' : ''}${AppFormatters.formatUsd(pos.unrealizedPnl)} (${pos.unrealizedPnlPercent}%)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: pos.isProfitable
                                            ? AppTheme.greenBullish
                                            : AppTheme.redBearish,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildMiniStat(
                                        'Entry Price',
                                        pos.entryPrice < 5
                                            ? '\$${pos.entryPrice.toStringAsFixed(4)}'
                                            : AppFormatters.formatUsd(
                                                pos.entryPrice)),
                                    _buildMiniStat(
                                        'Mark Price',
                                        pos.currentPrice < 5
                                            ? '\$${pos.currentPrice.toStringAsFixed(4)}'
                                            : AppFormatters.formatUsd(
                                                pos.currentPrice)),
                                    _buildMiniStat(
                                        'Liq. Price',
                                        pos.liquidationPrice < 5
                                            ? '\$${pos.liquidationPrice.toStringAsFixed(4)}'
                                            : AppFormatters.formatUsd(
                                                pos.liquidationPrice)),
                                    _buildMiniStat(
                                        'Margin',
                                        AppFormatters.formatUsd(
                                            pos.marginAmount)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: AppTheme.redBearish),
                                      foregroundColor: AppTheme.redBearish,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      widget.tradingBloc
                                          .closePosition(pos.symbol);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Position ${pos.symbol} closed')),
                                      );
                                    },
                                    child: const Text('Market Close Position',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: highlight ? AppTheme.redBearish : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}
