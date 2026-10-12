import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/candlestick_chart_widget.dart';

class StockItem {
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double dividendYield;
  final String peRatio;
  final String marketCap;
  final bool allowsFractional;

  const StockItem({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.dividendYield,
    required this.peRatio,
    required this.marketCap,
    this.allowsFractional = true,
  });
}

class StocksEtfsScreen extends StatefulWidget {
  const StocksEtfsScreen({super.key});

  @override
  State<StocksEtfsScreen> createState() => _StocksEtfsScreenState();
}

class _StocksEtfsScreenState extends State<StocksEtfsScreen> {
  final List<StockItem> _stocks = const [
    StockItem(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      price: 232.80,
      change24h: 1.84,
      dividendYield: 0.54,
      peRatio: '34.2x',
      marketCap: '\$3.56T',
    ),
    StockItem(
      symbol: 'NVDA',
      name: 'NVIDIA Corporation',
      price: 134.50,
      change24h: 4.22,
      dividendYield: 0.03,
      peRatio: '58.1x',
      marketCap: '\$3.29T',
    ),
    StockItem(
      symbol: 'MSFT',
      name: 'Microsoft Corp.',
      price: 428.15,
      change24h: 0.95,
      dividendYield: 0.72,
      peRatio: '35.6x',
      marketCap: '\$3.18T',
    ),
    StockItem(
      symbol: 'SPY',
      name: 'SPDR S&P 500 ETF Trust',
      price: 585.40,
      change24h: 0.68,
      dividendYield: 1.25,
      peRatio: '27.4x',
      marketCap: '\$580B',
    ),
    StockItem(
      symbol: 'QQQ',
      name: 'Invesco QQQ Trust (Nasdaq 100)',
      price: 494.10,
      change24h: 1.15,
      dividendYield: 0.60,
      peRatio: '31.8x',
      marketCap: '\$295B',
    ),
    StockItem(
      symbol: 'TSLA',
      name: 'Tesla, Inc.',
      price: 248.90,
      change24h: -1.45,
      dividendYield: 0.00,
      peRatio: '68.4x',
      marketCap: '\$780B',
    ),
  ];

  late StockItem _selectedStock;
  final TextEditingController _amountController =
      TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _selectedStock = _stocks.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showOrderRoutingDialog() {
    final double amount = double.tryParse(_amountController.text) ?? 100.0;
    final double shares = amount / _selectedStock.price;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.nightObsidian,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Route Order: ${_selectedStock.symbol}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.greenBullish.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Direct DMA Route',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.greenBullish,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderHighlight),
                ),
                child: Column(
                  children: [
                    _buildRow('Selected Instrument',
                        '${_selectedStock.name} (${_selectedStock.symbol})'),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow('Execution Price',
                        AppFormatters.formatUsd(_selectedStock.price)),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow(
                        'Investment Amount', AppFormatters.formatUsd(amount)),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow('Allocated Shares',
                        '${shares.toStringAsFixed(4)} shares'),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow(
                        'Est. Annual Dividend',
                        AppFormatters.formatUsd(
                            amount * (_selectedStock.dividendYield / 100))),
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
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Order filled: ${shares.toStringAsFixed(4)} ${_selectedStock.symbol} via JuwishPro DMA routing'),
                        backgroundColor: AppTheme.greenBullish,
                      ),
                    );
                  },
                  child: const Text(
                    'Confirm & Route Order to Exchange',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      appBar: AppBar(
        title: const Text('Stocks & ETFs Hub'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected stock summary
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedStock.symbol,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            _selectedStock.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppFormatters.formatUsd(_selectedStock.price),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                            ),
                          ),
                          Text(
                            AppFormatters.formatPercentage(
                                _selectedStock.change24h),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _selectedStock.change24h >= 0
                                  ? AppTheme.greenBullish
                                  : AppTheme.redBearish,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniBadge(
                          'Div Yield', '${_selectedStock.dividendYield}%'),
                      _buildMiniBadge('P/E Ratio', _selectedStock.peRatio),
                      _buildMiniBadge('Market Cap', _selectedStock.marketCap),
                      _buildMiniBadge('Fractional', 'Yes (0.001)'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Performance Candlestick Chart
            CandlestickChartWidget(
              symbol: _selectedStock.symbol,
              basePrice: _selectedStock.price,
              height: 260,
            ),

            const SizedBox(height: 16),

            // Fractional Share Order Routing Box
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
                  const Text(
                    'Fractional Shares & Order Routing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Invest in top institutional equities starting from just \$1.00 with zero commission.',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'Investment Amount (\$)',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.nightObsidian,
                            prefixText: '\$ ',
                            prefixStyle: const TextStyle(color: AppTheme.gold),
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
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: AppTheme.nightObsidian,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _showOrderRoutingDialog,
                        child: const Text('Execute Order',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Instrument Selector Table
            const Text(
              'Trending Equities & ETFs',
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
              itemCount: _stocks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _stocks[index];
                final isSelected = item.symbol == _selectedStock.symbol;
                return InkWell(
                  onTap: () => setState(() => _selectedStock = item),
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
                            : AppTheme.borderHighlight,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.gold.withOpacity(0.15),
                          child: Text(
                            item.symbol
                                .substring(0, min(2, item.symbol.length)),
                            style: const TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.symbol,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary)),
                              Text(item.name,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(AppFormatters.formatUsd(item.price),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary)),
                            Text(
                              AppFormatters.formatPercentage(item.change24h),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.change24h >= 0
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

  Widget _buildMiniBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.nightObsidian,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderHighlight),
      ),
      child: Column(
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
      ),
    );
  }
}
