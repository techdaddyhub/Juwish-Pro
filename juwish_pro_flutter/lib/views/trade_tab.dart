import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/market_pair.dart';
import '../services/market_data_service.dart';

class TradeTab extends StatefulWidget {
  final MarketPair? initialPair;
  final double jwcBalance;
  final void Function(double newJwcBalance) onBalanceUpdated;

  const TradeTab({
    super.key,
    this.initialPair,
    required this.jwcBalance,
    required this.onBalanceUpdated,
  });

  @override
  State<TradeTab> createState() => _TradeTabState();
}

class _TradeTabState extends State<TradeTab>
    with AutomaticKeepAliveClientMixin {
  late MarketPair _currentPair;
  final MarketDataService _dataService = MarketDataService();

  bool _isBuy = true;
  bool _isLimit = false;
  late TextEditingController _priceController;
  final TextEditingController _amountController = TextEditingController();

  // Simulated live order book
  final List<(double price, double amount)> _asks = const [
    (1.4310, 4200.0),
    (1.4290, 8910.0),
    (1.4270, 15400.0),
    (1.4260, 22100.0),
  ];

  final List<(double price, double amount)> _bids = const [
    (1.4240, 18500.0),
    (1.4220, 29000.0),
    (1.4200, 41200.0),
    (1.4180, 56000.0),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentPair = widget.initialPair ?? _dataService.getAllPairs().first;
    _priceController =
        TextEditingController(text: _currentPair.lastPrice.toString());
  }

  @override
  void didUpdateWidget(covariant TradeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPair != null &&
        widget.initialPair!.symbol != _currentPair.symbol) {
      setState(() {
        _currentPair = widget.initialPair!;
        _priceController.text = _currentPair.lastPrice.toString();
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _selectAllocation(int percentage) {
    HapticFeedback.selectionClick();
    final maxAmount =
        _isBuy ? 1000.0 / _currentPair.lastPrice : widget.jwcBalance;
    final calculated = maxAmount * (percentage / 100.0);
    _amountController.text = calculated.toStringAsFixed(2);
  }

  void _executeOrder() {
    HapticFeedback.mediumImpact();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.redBearish,
          content: Text('Please enter a valid amount'),
        ),
      );
      return;
    }

    if (!_isBuy && amount > widget.jwcBalance && _currentPair.isJwc) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.redBearish,
          content: Text('Insufficient JWC balance!'),
        ),
      );
      return;
    }

    // Execute order immediately
    final updatedBalance =
        _isBuy ? widget.jwcBalance + amount : widget.jwcBalance - amount;

    widget.onBalanceUpdated(updatedBalance);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isBuy ? AppTheme.greenBullish : AppTheme.gold,
        content: Text(
          '${_isBuy ? "Bought" : "Sold"} ${amount.toStringAsFixed(2)} ${_currentPair.baseAsset} at ${_currentPair.formattedPrice}!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    _amountController.clear();
  }

  void _openPairPicker() {
    HapticFeedback.selectionClick();
    final all = _dataService.getAllPairs();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Select Trading Pair',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const Divider(color: AppTheme.borderSubtle, height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: all.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppTheme.borderSubtle, height: 1),
                  itemBuilder: (context, index) {
                    final p = all[index];
                    return ListTile(
                      title: Text(p.symbol,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(p.name,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                      trailing: Text(p.formattedPrice,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentPair = p;
                          _priceController.text = p.lastPrice.toString();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pair Selector Header
              _buildHeaderRow(),
              const SizedBox(height: 16),

              // Responsive Order Book & Form Area
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildOrderBook()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildOrderForm()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildOrderBook(),
                    const SizedBox(height: 16),
                    _buildOrderForm(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCharcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: _openPairPicker,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Text(
                  _currentPair.symbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (_currentPair.isJwc) ...[
                  const SizedBox(width: 4),
                  const Text('✡',
                      style: TextStyle(color: AppTheme.gold, fontSize: 14)),
                ],
                const Icon(Icons.arrow_drop_down, color: AppTheme.gold),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currentPair.formattedPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _currentPair.formattedChange,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: _currentPair.isBullish
                      ? AppTheme.greenBullish
                      : AppTheme.redBearish,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBook() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCharcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Order Book',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              Text('Price / Size',
                  style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            ],
          ),
          const SizedBox(height: 10),

          // Asks (Sells in Red)
          ..._asks.reversed.map((ask) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ask.$1.toStringAsFixed(4),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: AppTheme.redBearish,
                    ),
                  ),
                  Text(
                    ask.$2.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(color: AppTheme.borderSubtle, height: 1),
          ),

          // Current Center Price
          Center(
            child: Text(
              _currentPair.formattedPrice,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                color: _currentPair.isBullish
                    ? AppTheme.greenBullish
                    : AppTheme.redBearish,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(color: AppTheme.borderSubtle, height: 1),
          ),

          // Bids (Buys in Green)
          ..._bids.map((bid) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bid.$1.toStringAsFixed(4),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: AppTheme.greenBullish,
                    ),
                  ),
                  Text(
                    bid.$2.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCharcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buy / Sell Switcher Tabs
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isBuy = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isBuy ? AppTheme.greenBullish : AppTheme.borderSubtle,
                    foregroundColor:
                        _isBuy ? Colors.black : AppTheme.textSecondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Buy',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isBuy = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_isBuy ? AppTheme.redBearish : AppTheme.borderSubtle,
                    foregroundColor:
                        !_isBuy ? Colors.white : AppTheme.textSecondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Sell',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Order Type (Market vs Limit)
          Row(
            children: [
              ChoiceChip(
                label: const Text('Market'),
                selected: !_isLimit,
                selectedColor: AppTheme.gold,
                backgroundColor: AppTheme.nightObsidian,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: !_isLimit ? Colors.black : AppTheme.textSecondary,
                ),
                onSelected: (_) => setState(() => _isLimit = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Limit'),
                selected: _isLimit,
                selectedColor: AppTheme.gold,
                backgroundColor: AppTheme.nightObsidian,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isLimit ? Colors.black : AppTheme.textSecondary,
                ),
                onSelected: (_) => setState(() => _isLimit = true),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price Field (Editable if limit)
          if (_isLimit) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.nightObsidian,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: TextField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  labelText: 'Price (${_currentPair.quoteAsset})',
                  labelStyle: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Amount Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.nightObsidian,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Amount (${_currentPair.baseAsset})',
                labelStyle: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
                border: InputBorder.none,
                suffixText: _currentPair.baseAsset,
                suffixStyle: const TextStyle(
                    color: AppTheme.gold, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Percentage chips: 25%, 50%, 75%, 100%
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [25, 50, 75, 100].map((pct) {
              return InkWell(
                onTap: () => _selectAllocation(pct),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pct%',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Submit Order Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _executeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isBuy ? AppTheme.greenBullish : AppTheme.redBearish,
                foregroundColor: _isBuy ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                '${_isBuy ? "BUY" : "SELL"} ${_currentPair.baseAsset}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
