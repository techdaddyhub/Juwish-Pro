import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/market_pair.dart';
import '../services/market_data_service.dart';
import '../widgets/sparkline_chart.dart';

class MarketsTab extends StatefulWidget {
  final void Function(MarketPair pair) onSelectPair;

  const MarketsTab({
    super.key,
    required this.onSelectPair,
  });

  @override
  State<MarketsTab> createState() => _MarketsTabState();
}

class _MarketsTabState extends State<MarketsTab>
    with AutomaticKeepAliveClientMixin {
  final MarketDataService _dataService = MarketDataService();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const ['All', 'JWC', 'Spot', 'Futures'];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filtered = _dataService.filterPairs(
      category: _selectedCategory,
      query: _searchQuery,
    );

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceCharcoal,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Search coin or pair (e.g. JWC, BTC)...',
                hintStyle: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.textSecondary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppTheme.textSecondary, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            ),
          ),
        ),

        // Category filter tabs
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(cat == 'JWC' ? '✡ JWC Pairs' : cat),
                selected: isSelected,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.black : AppTheme.textSecondary,
                ),
                selectedColor: AppTheme.gold,
                backgroundColor: AppTheme.surfaceCharcoal,
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.gold
                      : AppTheme.borderSubtle,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = cat);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Name / Vol',
                  style:
                      TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              Text('Chart',
                  style:
                      TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              Text('Last Price / 24h',
                  style:
                      TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            ],
          ),
        ),
        const Divider(color: AppTheme.borderSubtle, height: 1),

        // Markets List View (Fast lazy scrolling)
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No markets found matching query',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppTheme.borderSubtle, height: 1),
                  itemBuilder: (context, index) {
                    final pair = filtered[index];
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onSelectPair(pair);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Symbol & Name
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        pair.symbol,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (pair.isJwc) ...[
                                        const SizedBox(width: 4),
                                        const Text('✡',
                                            style: TextStyle(
                                                color: AppTheme.gold,
                                                fontSize: 11)),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Vol \$${(pair.volume24h / 1000000).toStringAsFixed(1)}M',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Sparkline
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: SparklineChart(
                                  data: pair.sparkline,
                                  color: pair.isBullish
                                      ? AppTheme.greenBullish
                                      : AppTheme.redBearish,
                                  width: 64,
                                  height: 24,
                                ),
                              ),
                            ),

                            // Price & 24h Change
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    pair.formattedPrice,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: pair.isBullish
                                          ? AppTheme.greenGlow
                                          : AppTheme.redGlow,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      pair.formattedChange,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        color: pair.isBullish
                                            ? AppTheme.greenBullish
                                            : AppTheme.redBearish,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
