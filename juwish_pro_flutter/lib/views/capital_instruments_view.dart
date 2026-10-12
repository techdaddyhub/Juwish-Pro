import 'package:flutter/material.dart';
import '../models/capital_instrument.dart';
import '../theme/app_theme.dart';
import '../widgets/sparkline_chart.dart';

class CapitalInstrumentsView extends StatefulWidget {
  const CapitalInstrumentsView({super.key});

  @override
  State<CapitalInstrumentsView> createState() => _CapitalInstrumentsViewState();
}

class _CapitalInstrumentsViewState extends State<CapitalInstrumentsView> {
  InstrumentCategory? _selectedCategory;
  final List<CapitalInstrument> _instruments = CapitalInstrument.getCatalog();
  String _searchQuery = '';

  List<CapitalInstrument> get _filteredList {
    return _instruments.where((item) {
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          item.ticker.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showOrderDialog(CapitalInstrument instrument, bool isBuy) {
    double shares = 1.0;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final totalCost = shares * instrument.currentPrice;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isBuy
                                  ? AppTheme.gainGreen.withOpacity(0.15)
                                  : AppTheme.lossRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                              color:
                                  isBuy ? AppTheme.gainGreen : AppTheme.lossRed,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isBuy ? "Buy" : "Sell"} ${instrument.ticker}',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                instrument.name,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppTheme.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Market Price',
                            style: TextStyle(color: AppTheme.textSecondary)),
                        Text(
                          '\$${instrument.currentPrice.toStringAsFixed(instrument.category == InstrumentCategory.forex ? 4 : 2)}',
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity / Units',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppTheme.textSecondary),
                            onPressed: shares > 1
                                ? () => setModalState(() => shares -= 1)
                                : null,
                          ),
                          Text(
                            shares.toStringAsFixed(0),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: AppTheme.gold),
                            onPressed: () => setModalState(() => shares += 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderSubtle, height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Value',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      Text(
                        '\$${totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isBuy ? AppTheme.gainGreen : AppTheme.lossRed,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                isBuy ? AppTheme.gainGreen : AppTheme.lossRed,
                            content: Text(
                              'Successfully executed ${isBuy ? "buy" : "sell"} for $shares ${instrument.ticker} on 2026.dmillers.org',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Confirm ${isBuy ? "Buy" : "Sell"} Order',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: TextField(
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search Stocks, ETFs, Bonds, Forex...',
                        hintStyle: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        prefixIcon: Icon(Icons.search,
                            color: AppTheme.textSecondary, size: 20),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip(label: 'All Assets', category: null),
                        const SizedBox(width: 8),
                        _filterChip(
                            label: 'Stocks',
                            category: InstrumentCategory.stock),
                        const SizedBox(width: 8),
                        _filterChip(
                            label: 'ETFs', category: InstrumentCategory.etf),
                        const SizedBox(width: 8),
                        _filterChip(
                            label: 'Treasury Bonds',
                            category: InstrumentCategory.bond),
                        const SizedBox(width: 8),
                        _filterChip(
                            label: 'Forex Pairs',
                            category: InstrumentCategory.forex),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _filteredList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        // Icon / Badge
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Center(
                            child: Text(
                              item.ticker.substring(
                                  0,
                                  item.ticker.length > 3
                                      ? 3
                                      : item.ticker.length),
                              style: const TextStyle(
                                color: AppTheme.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name and Category
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.ticker,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.borderSubtle,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.categoryLabel,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 9),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11),
                              ),
                              if (item.annualYield != null)
                                Text(
                                  'Annual Yield: ${item.annualYield}% APY',
                                  style: const TextStyle(
                                      color: AppTheme.gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                        ),
                        // Sparkline
                        SizedBox(
                          width: 56,
                          height: 28,
                          child: SparklineChart(
                            data: item.sparkline,
                            color: item.isPositive
                                ? AppTheme.gainGreen
                                : AppTheme.lossRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Price & Buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${item.currentPrice.toStringAsFixed(item.category == InstrumentCategory.forex ? 4 : 2)}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${item.isPositive ? "+" : ""}${item.change24h.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: item.isPositive
                                    ? AppTheme.gainGreen
                                    : AppTheme.lossRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => _showOrderDialog(item, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.gainGreen,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Buy',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _showOrderDialog(item, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lossRed.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          Border.all(color: AppTheme.lossRed),
                                    ),
                                    child: const Text(
                                      'Sell',
                                      style: TextStyle(
                                          color: AppTheme.lossRed,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: _filteredList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
      {required String label, required InstrumentCategory? category}) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.gold : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.gold : AppTheme.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
