import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_theme.dart';

class ForexPair {
  final String symbol;
  final double bid;
  final double ask;
  final double spreadPips;
  final double change24h;

  const ForexPair({
    required this.symbol,
    required this.bid,
    required this.ask,
    required this.spreadPips,
    required this.change24h,
  });
}

class ForexTradingScreen extends StatefulWidget {
  const ForexTradingScreen({super.key});

  @override
  State<ForexTradingScreen> createState() => _ForexTradingScreenState();
}

class _ForexTradingScreenState extends State<ForexTradingScreen> {
  final List<ForexPair> _pairs = const [
    ForexPair(
        symbol: 'EUR/USD',
        bid: 1.0842,
        ask: 1.0844,
        spreadPips: 0.2,
        change24h: 0.15),
    ForexPair(
        symbol: 'GBP/USD',
        bid: 1.2985,
        ask: 1.2988,
        spreadPips: 0.3,
        change24h: -0.22),
    ForexPair(
        symbol: 'USD/JPY',
        bid: 149.20,
        ask: 149.23,
        spreadPips: 0.3,
        change24h: 0.48),
    ForexPair(
        symbol: 'USD/CHF',
        bid: 0.8650,
        ask: 0.8654,
        spreadPips: 0.4,
        change24h: -0.05),
    ForexPair(
        symbol: 'AUD/USD',
        bid: 0.6680,
        ask: 0.6683,
        spreadPips: 0.3,
        change24h: 0.32),
    ForexPair(
        symbol: 'USD/CAD',
        bid: 1.3820,
        ask: 1.3824,
        spreadPips: 0.4,
        change24h: -0.12),
  ];

  late ForexPair _selected;
  final TextEditingController _amountController =
      TextEditingController(text: '10000'); // Standard mini lot

  @override
  void initState() {
    super.initState();
    _selected = _pairs.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _executeForexTrade(bool isBuy) {
    final amount = double.tryParse(_amountController.text) ?? 10000.0;
    final rate = isBuy ? _selected.ask : _selected.bid;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${isBuy ? "BUY" : "SELL"} ${_selected.symbol} executed for \$${amount.toStringAsFixed(0)} @ ${rate.toStringAsFixed(4)} (Spread: ${_selected.spreadPips} pips)'),
        backgroundColor: isBuy ? AppTheme.greenBullish : AppTheme.redBearish,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      appBar: AppBar(
        title: const Text('Forex & Currency Pairs'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Pair Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selected.symbol,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Spread: ${_selected.spreadPips} pips',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.nightObsidian,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.redBearish.withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SELL (BID)',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.redBearish,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                _selected.bid.toStringAsFixed(4),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.nightObsidian,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.greenBullish.withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BUY (ASK)',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.greenBullish,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                _selected.ask.toStringAsFixed(4),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Execution inputs
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
                  const Text('Lot Size & Order Conversion',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 6),
                  const Text(
                      'Institutional interbank liquidity via ECN/STP engine.',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Contract Size (Units / Base Currency)',
                      labelStyle:
                          const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.nightObsidian,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppTheme.borderHighlight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.redBearish,
                            foregroundColor: AppTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _executeForexTrade(false),
                          child: Text(
                              'SELL ${_selected.bid.toStringAsFixed(4)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.greenBullish,
                            foregroundColor: AppTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _executeForexTrade(true),
                          child: Text('BUY ${_selected.ask.toStringAsFixed(4)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Market pairs list
            const Text('Institutional Currencies',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pairs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pair = _pairs[index];
                final isSelected = pair.symbol == _selected.symbol;
                return InkWell(
                  onTap: () => setState(() => _selected = pair),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.surfaceCharcoal
                          : AppTheme.surfaceCharcoal.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? AppTheme.gold
                              : AppTheme.borderHighlight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pair.symbol,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                    fontSize: 14)),
                            Text('Spread: ${pair.spreadPips} pips',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                '${pair.bid.toStringAsFixed(4)} / ${pair.ask.toStringAsFixed(4)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                    fontSize: 13)),
                            Text(
                              AppFormatters.formatPercentage(pair.change24h),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: pair.change24h >= 0
                                    ? AppTheme.greenBullish
                                    : AppTheme.redBearish,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
