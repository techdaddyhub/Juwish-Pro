import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_theme.dart';
import '../../blocs/market_bloc.dart';
import '../../widgets/candlestick_chart_widget.dart';

class CryptoJwcScreen extends StatefulWidget {
  final MarketBloc marketBloc;

  const CryptoJwcScreen({super.key, required this.marketBloc});

  @override
  State<CryptoJwcScreen> createState() => _CryptoJwcScreenState();
}

class _CryptoJwcScreenState extends State<CryptoJwcScreen> {
  final TextEditingController _swapAmountController =
      TextEditingController(text: '500');
  String _swapFrom = 'JWC';
  String _swapTo = 'USDT';

  @override
  void dispose() {
    _swapAmountController.dispose();
    super.dispose();
  }

  void _executeSwap(double jwcPrice) {
    final amount = double.tryParse(_swapAmountController.text) ?? 500.0;
    double received = 0.0;
    if (_swapFrom == 'JWC' && _swapTo == 'USDT') {
      received = amount * jwcPrice;
    } else if (_swapFrom == 'USDT' && _swapTo == 'JWC') {
      received = amount / jwcPrice;
    } else {
      received = amount * (jwcPrice / 592.8); // JWC to BNB
    }

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Instant Swap Successful: $amount $_swapFrom converted to ${received.toStringAsFixed(4)} $_swapTo at \$${jwcPrice.toStringAsFixed(4)}'),
        backgroundColor: AppTheme.greenBullish,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MarketState>(
      stream: widget.marketBloc.stream,
      initialData: widget.marketBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const MarketState();
        final jwcTicker = state.tickers.firstWhere(
          (t) => t.isJwc,
          orElse: () => const MarketTicker(
            symbol: 'JWC/USDT',
            price: 1.4250,
            change24h: 34.80,
            high24h: 1.5800,
            low24h: 1.0420,
            volume24h: 28410920.0,
            isJwc: true,
          ),
        );

        return Scaffold(
          backgroundColor: AppTheme.nightObsidian,
          appBar: AppBar(
            title: const Text('Crypto & Native JWC Token'),
            backgroundColor: AppTheme.nightObsidian,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // JWC Spotlight Hero Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.gold.withOpacity(0.2),
                        AppTheme.surfaceCharcoal,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/logo-square.png',
                                width: 38,
                                height: 38,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.stars,
                                    color: AppTheme.gold,
                                    size: 38),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'JuwishCoin (JWC)',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Native Ecosystem Token • BEP-20',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.greenBullish.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${jwcTicker.change24h}% 24H',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.greenBullish,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${jwcTicker.price.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'USDT',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.textSecondary),
                          ),
                          const Spacer(),
                          const Text(
                            '24h Vol: \$28.4M',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Interactive JWC Candlestick Chart
                CandlestickChartWidget(
                  symbol: 'JWC/USDT',
                  basePrice: jwcTicker.price,
                  isJwc: true,
                  height: 270,
                ),

                const SizedBox(height: 16),

                // Native JWC Swap & Transfer Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCharcoal,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderHighlight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Instant JWC DEX Swap',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Slippage: 0.1% • Zero Gas',
                            style:
                                TextStyle(fontSize: 11, color: AppTheme.gold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.nightObsidian,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderHighlight),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _swapAmountController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0.00',
                                  hintStyle:
                                      TextStyle(color: AppTheme.textSecondary),
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              value: _swapFrom,
                              dropdownColor: AppTheme.nightObsidian,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold),
                              items: ['JWC', 'USDT']
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _swapFrom = val;
                                    _swapTo = val == 'JWC' ? 'USDT' : 'JWC';
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.swap_vert,
                              color: AppTheme.gold, size: 28),
                          onPressed: () {
                            setState(() {
                              final temp = _swapFrom;
                              _swapFrom = _swapTo;
                              _swapTo = temp;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.nightObsidian,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderHighlight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _swapFrom == 'JWC'
                                  ? '\$${((double.tryParse(_swapAmountController.text) ?? 500) * jwcTicker.price).toStringAsFixed(2)}'
                                  : '${((double.tryParse(_swapAmountController.text) ?? 500) / jwcTicker.price).toStringAsFixed(2)} JWC',
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Text(_swapTo,
                                style: const TextStyle(
                                    color: AppTheme.gold,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.gold,
                            foregroundColor: AppTheme.nightObsidian,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _executeSwap(jwcTicker.price),
                          child: const Text('Execute Instant Swap',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Other crypto market tickers
                const Text(
                  'Major Crypto Assets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.tickers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final ticker = state.tickers[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCharcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ticker.isJwc
                              ? AppTheme.gold.withOpacity(0.5)
                              : AppTheme.borderHighlight,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: ticker.isJwc
                                ? AppTheme.gold.withOpacity(0.2)
                                : AppTheme.borderHighlight,
                            child: Text(
                              ticker.symbol.split('/').first,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ticker.isJwc
                                    ? AppTheme.gold
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ticker.symbol,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary)),
                                Text(
                                    'Vol: \$${(ticker.volume24h / 1000000).toStringAsFixed(1)}M',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                ticker.price < 5
                                    ? '\$${ticker.price.toStringAsFixed(4)}'
                                    : AppFormatters.formatUsd(ticker.price),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary),
                              ),
                              Text(
                                AppFormatters.formatPercentage(
                                    ticker.change24h),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: ticker.change24h >= 0
                                      ? AppTheme.greenBullish
                                      : AppTheme.redBearish,
                                ),
                              ),
                            ],
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
  }
}
