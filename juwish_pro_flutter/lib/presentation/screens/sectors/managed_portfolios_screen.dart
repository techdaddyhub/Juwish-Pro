import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/investment_repository_impl.dart';
import '../../../domain/entities/investment_plan_entity.dart';
import '../../../theme/app_theme.dart';

class ManagedPortfoliosScreen extends StatefulWidget {
  const ManagedPortfoliosScreen({super.key});

  @override
  State<ManagedPortfoliosScreen> createState() =>
      _ManagedPortfoliosScreenState();
}

class _ManagedPortfoliosScreenState extends State<ManagedPortfoliosScreen> {
  final InvestmentRepositoryImpl _repository = InvestmentRepositoryImpl();
  List<InvestmentPlanEntity> _plans = [];
  bool _isLoading = true;
  String _activeSectorFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final list = await _repository.getInvestmentPlans();
    if (mounted) {
      setState(() {
        _plans = list;
        _isLoading = false;
      });
    }
  }

  void _showStakeModal(InvestmentPlanEntity plan) {
    final TextEditingController amountController =
        TextEditingController(text: plan.minInvestment.toStringAsFixed(0));
    bool compounding = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.nightObsidian,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double amount =
                double.tryParse(amountController.text) ?? plan.minInvestment;
            final double totalReturn = compounding
                ? amount * (1.0 + (plan.returnPercent / 100.0) * 1.15)
                : amount * (1.0 + (plan.returnPercent / 100.0));
            final double estProfit = totalReturn - amount;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.greenBullish.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${plan.returnPercent}% ROI',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.greenBullish,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(plan.description,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCharcoal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderHighlight),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Lockup Duration',
                            '${plan.durationDays} Days Term'),
                        const Divider(color: AppTheme.borderHighlight),
                        _buildRow(
                            'Capital Return Guarantee',
                            plan.capitalReturned
                                ? '100% Guaranteed Return'
                                : 'Amortized'),
                        const Divider(color: AppTheme.borderHighlight),
                        _buildRow(
                            'Risk Rating', plan.riskProfile.toUpperCase()),
                        const Divider(color: AppTheme.borderHighlight),
                        _buildRow('Est. Net Profit',
                            AppFormatters.formatUsd(estProfit),
                            isHighlight: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Auto-Compound Daily ROI',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: compounding,
                        activeColor: AppTheme.gold,
                        onChanged: (val) {
                          setModalState(() => compounding = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold),
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Deposit Capital (\$)',
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
                                'Plan activated! Allocated \$${amountController.text} in ${plan.name}'),
                            backgroundColor: AppTheme.greenBullish,
                          ),
                        );
                      },
                      child: const Text('Confirm Staking & Lock Capital',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildRow(String title, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppTheme.gold : AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlans = _activeSectorFilter == 'All'
        ? _plans
        : _plans.where((p) => p.sector == _activeSectorFilter).toList();

    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      appBar: AppBar(
        title: const Text('Managed Portfolios & Vaults'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.gold.withOpacity(0.18),
                          AppTheme.surfaceCharcoal
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderHighlight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Live Staking Ecosystem',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '${_plans.length} Database Investment Plans Active',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Automated institutional arbitrage, liquidity farming, and multi-asset compounding synced live with 2026.dmillers.org backend.',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sector Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'Stocks & ETFs',
                        'Crypto Assets',
                        'Real Estate',
                        'Capital Instruments'
                      ].map((filter) {
                        final isSelected = _activeSectorFilter == filter;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _activeSectorFilter = filter),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.gold
                                  : AppTheme.surfaceCharcoal,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected
                                      ? AppTheme.gold
                                      : AppTheme.borderHighlight),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppTheme.nightObsidian
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Plan cards list
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPlans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final plan = filteredPlans[index];
                      return Container(
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
                                Expanded(
                                  child: Text(
                                    plan.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.greenBullish.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '+${plan.returnPercent}% ROI',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.greenBullish),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(plan.description,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildBadge(
                                    'Duration', '${plan.durationDays} Days'),
                                _buildBadge(
                                    'Min Entry',
                                    AppFormatters.formatUsd(
                                        plan.minInvestment)),
                                _buildBadge(
                                    'Max Cap',
                                    AppFormatters.formatUsd(
                                        plan.maxInvestment)),
                                _buildBadge(
                                    'Risk', plan.riskProfile.toUpperCase()),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.gold,
                                  foregroundColor: AppTheme.nightObsidian,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _showStakeModal(plan),
                                child: const Text('Stake & Lock Plan',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
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
  }

  Widget _buildBadge(String label, String value) {
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
