import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_theme.dart';

class MarginTradingScreen extends StatefulWidget {
  const MarginTradingScreen({super.key});

  @override
  State<MarginTradingScreen> createState() => _MarginTradingScreenState();
}

class _MarginTradingScreenState extends State<MarginTradingScreen> {
  bool _isCrossMargin = true;
  double _collateralUsd = 25000.0;
  double _borrowedUsd = 8500.0;
  final TextEditingController _borrowController =
      TextEditingController(text: '1000');

  double get _marginLevel {
    if (_borrowedUsd <= 0) return 999.0;
    return (_collateralUsd / _borrowedUsd) * 100.0;
  }

  Color get _marginLevelColor {
    if (_marginLevel > 200) return AppTheme.greenBullish;
    if (_marginLevel > 130) return AppTheme.gold;
    return AppTheme.redBearish;
  }

  String get _marginStatusRisk {
    if (_marginLevel > 200) return 'Safe (Low Risk)';
    if (_marginLevel > 130) return 'Caution (Margin Call Warning @ 130%)';
    return 'DANGER: Liquidation Risk (@ 110%)';
  }

  void _executeBorrow() {
    final amount = double.tryParse(_borrowController.text) ?? 1000.0;
    setState(() {
      _borrowedUsd += amount;
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Borrowed \$${amount.toStringAsFixed(2)} USDT into Margin Account'),
        backgroundColor: AppTheme.greenBullish,
      ),
    );
  }

  void _executeRepay() {
    final amount = double.tryParse(_borrowController.text) ?? 1000.0;
    if (_borrowedUsd <= 0) return;
    setState(() {
      _borrowedUsd = (_borrowedUsd - amount).clamp(0.0, 1000000.0);
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Repaid \$${amount.toStringAsFixed(2)} USDT loan'),
        backgroundColor: AppTheme.greenBullish,
      ),
    );
  }

  @override
  void dispose() {
    _borrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      appBar: AppBar(
        title: const Text('Margin Trading & Collateral'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Margin Mode Toggle: Cross vs Isolated
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCrossMargin = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isCrossMargin
                              ? AppTheme.gold
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cross Margin (3x)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isCrossMargin
                                ? AppTheme.nightObsidian
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCrossMargin = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isCrossMargin
                              ? AppTheme.gold
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Isolated Margin (10x)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !_isCrossMargin
                                ? AppTheme.nightObsidian
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Collateral Ratio & Health Meter
            Container(
              padding: const EdgeInsets.all(18),
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
                      const Text('Margin Level / Collateral Ratio',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _marginLevelColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _marginStatusRisk,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _marginLevelColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_marginLevel.toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _marginLevelColor),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Debt',
                              style: TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                          Text(AppFormatters.formatUsd(_borrowedUsd),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_marginLevel / 300.0).clamp(0.0, 1.0),
                      backgroundColor: AppTheme.nightObsidian,
                      color: _marginLevelColor,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('110% (Liquidation)',
                          style: TextStyle(
                              fontSize: 10, color: AppTheme.redBearish)),
                      Text('130% (Margin Call)',
                          style: TextStyle(fontSize: 10, color: AppTheme.gold)),
                      Text('200%+ (Low Risk)',
                          style: TextStyle(
                              fontSize: 10, color: AppTheme.greenBullish)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Borrow & Repay Module
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
                  const Text('Borrow / Repay Capital',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 6),
                  const Text(
                      'Daily Interest Rate: 0.015% (5.475% APR) • Auto-settle enabled',
                      style: TextStyle(fontSize: 11, color: AppTheme.gold)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _borrowController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Amount (USDT)',
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
                            backgroundColor: AppTheme.gold,
                            foregroundColor: AppTheme.nightObsidian,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _executeBorrow,
                          child: const Text('Borrow USDT',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.gold),
                            foregroundColor: AppTheme.gold,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _executeRepay,
                          child: const Text('Repay Loan',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Collateral Assets Table
            const Text('Your Collateral Balances',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            _buildAssetRow('JuwishCoin (JWC)', '25,000 JWC', '\$35,625.00',
                '1.4250', true),
            const SizedBox(height: 8),
            _buildAssetRow('Tether USD (USDT)', '14,250 USDT', '\$14,250.00',
                '1.0000', false),
            const SizedBox(height: 8),
            _buildAssetRow(
                'Bitcoin (BTC)', '0.65 BTC', '\$42,523.00', '65,420.00', false),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow(
      String name, String amount, String valUsd, String price, bool isJwc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCharcoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isJwc
                ? AppTheme.gold.withOpacity(0.4)
                : AppTheme.borderHighlight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isJwc
                    ? AppTheme.gold.withOpacity(0.2)
                    : AppTheme.nightObsidian,
                child: Text(name.substring(0, 3),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isJwc ? AppTheme.gold : AppTheme.textPrimary)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontSize: 13)),
                  Text('@ \$$price',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      fontSize: 13)),
              Text(valUsd,
                  style: const TextStyle(
                      color: AppTheme.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
