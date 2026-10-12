import 'package:flutter/material.dart';
import '../models/futures_position.dart';
import '../theme/app_theme.dart';

class FuturesView extends StatefulWidget {
  const FuturesView({super.key});

  @override
  State<FuturesView> createState() => _FuturesViewState();
}

class _FuturesViewState extends State<FuturesView> {
  bool _isLong = true;
  int _leverage = 20;
  String _selectedContract = 'JWC/USDT';
  bool _isCrossMargin = true;
  final TextEditingController _amountController = TextEditingController(text: '10000');
  final List<FuturesPosition> _positions = FuturesPosition.getMockPositions();

  double get _currentMarkPrice {
    if (_selectedContract == 'JWC/USDT') return 0.0842;
    if (_selectedContract == 'BTC/USDT') return 96420.0;
    return 3280.0;
  }

  void _executeFuturesOrder() {
    final size = double.tryParse(_amountController.text) ?? 1000.0;
    final margin = (size * _currentMarkPrice) / _leverage;
    final newPos = FuturesPosition(
      id: 'POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      symbol: _selectedContract,
      isLong: _isLong,
      leverage: _leverage,
      entryPrice: _currentMarkPrice,
      markPrice: _currentMarkPrice,
      size: size,
      margin: margin,
      liquidationPrice: _isLong
          ? _currentMarkPrice * (1.0 - (1.0 / _leverage) * 0.9)
          : _currentMarkPrice * (1.0 + (1.0 / _leverage) * 0.9),
    );

    setState(() {
      _positions.insert(0, newPos);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isLong ? AppTheme.gainGreen : AppTheme.lossRed,
        content: Text(
          'Opened ${_leverage}x ${_isLong ? "LONG" : "SHORT"} on $_selectedContract ($size units)',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _closePosition(FuturesPosition pos) {
    setState(() {
      _positions.removeWhere((p) => p.id == pos.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.gold,
        content: Text(
          'Closed position ${pos.id} with PnL: \$${pos.unrealizedPnl.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Contract Selector & Leverage Badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedContract,
                      dropdownColor: AppTheme.surfaceDark,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      items: ['JWC/USDT', 'BTC/USDT', 'ETH/USDT'].map((sym) {
                        return DropdownMenuItem(
                          value: sym,
                          child: Row(
                            children: [
                              if (sym.contains('JWC'))
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Text('✡', style: TextStyle(color: AppTheme.gold)),
                                ),
                              Text(sym),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text('Perp', style: TextStyle(color: AppTheme.gold, fontSize: 10)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedContract = val);
                      },
                    ),
                  ),
                  Row(
                    children: [
                      // Margin Mode Toggle
                      GestureDetector(
                        onTap: () => setState(() => _isCrossMargin = !_isCrossMargin),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            _isCrossMargin ? 'Cross' : 'Isolated',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Leverage Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderHighlight),
                        ),
                        child: Text(
                          '${_leverage}x',
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Leverage Slider Bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Leverage Adjustment', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      Text('${_leverage}x Leverage', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  Slider(
                    value: _leverage.toDouble(),
                    min: 1,
                    max: 125,
                    divisions: 124,
                    activeColor: AppTheme.gold,
                    inactiveColor: AppTheme.cardDark,
                    onChanged: (val) => setState(() => _leverage = val.toInt()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [1, 10, 20, 50, 100, 125].map((lvl) {
                      return GestureDetector(
                        onTap: () => setState(() => _leverage = lvl),
                        child: Text(
                          '${lvl}x',
                          style: TextStyle(
                            color: _leverage == lvl ? AppTheme.gold : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: _leverage == lvl ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Long / Short Order Execution Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  // Buy Long vs Sell Short Tab
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLong = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isLong ? AppTheme.gainGreen : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Open Long',
                                  style: TextStyle(
                                    color: _isLong ? Colors.white : AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLong = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isLong ? AppTheme.lossRed : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Open Short',
                                  style: TextStyle(
                                    color: !_isLong ? Colors.white : AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Order Size Input
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Order Size ($_selectedContract)',
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixText: _selectedContract.split('/').first,
                      suffixStyle: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Margin requirement calculation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Required Margin', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      Text(
                        '\$${(((double.tryParse(_amountController.text) ?? 0) * _currentMarkPrice) / _leverage).toStringAsFixed(2)} USDT',
                        style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLong ? AppTheme.gainGreen : AppTheme.lossRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _executeFuturesOrder,
                      child: Text(
                        'Confirm ${_isLong ? "Long" : "Short"} (${_leverage}x)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Positions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Positions & Open Margin',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_positions.length} Active',
                  style: const TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._positions.map((pos) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: pos.isInProfit ? AppTheme.gainGreen.withOpacity(0.3) : AppTheme.lossRed.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: pos.isLong ? AppTheme.gainGreen : AppTheme.lossRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${pos.isLong ? "LONG" : "SHORT"} ${pos.leverage}x',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              pos.symbol,
                              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _closePosition(pos),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.borderSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Market Close', style: TextStyle(color: AppTheme.textPrimary, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Unrealized PnL (ROE %)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            Text(
                              '${pos.isInProfit ? "+" : ""}\$${pos.unrealizedPnl.toStringAsFixed(2)} (${pos.returnOnEquityPercent.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                color: pos.isInProfit ? AppTheme.gainGreen : AppTheme.lossRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Entry / Mark', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            Text(
                              '${pos.entryPrice} / ${pos.markPrice}',
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

