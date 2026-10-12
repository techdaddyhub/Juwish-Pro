import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_theme.dart';

class InstrumentItem {
  final String title;
  final String category;
  final String rating;
  final double annualYield;
  final String maturity;
  final double minInvestment;
  final String risk;
  final String description;

  const InstrumentItem({
    required this.title,
    required this.category,
    required this.rating,
    required this.annualYield,
    required this.maturity,
    required this.minInvestment,
    required this.risk,
    required this.description,
  });
}

class CapitalInstrumentsScreen extends StatefulWidget {
  const CapitalInstrumentsScreen({super.key});

  @override
  State<CapitalInstrumentsScreen> createState() =>
      _CapitalInstrumentsScreenState();
}

class _CapitalInstrumentsScreenState extends State<CapitalInstrumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<InstrumentItem> _allInstruments = const [
    // Bonds & Fixed Income
    InstrumentItem(
      title: 'US 10-Year Treasury Yield Note',
      category: 'Bonds & Fixed Income',
      rating: 'AAA (Sovereign)',
      annualYield: 4.82,
      maturity: '10 Years (Semi-Annual)',
      minInvestment: 1000.0,
      risk: 'Ultra Low',
      description:
          'Backed by full faith and credit of the US Government. Direct digital issuance.',
    ),
    InstrumentItem(
      title: 'Microsoft 5.2% Corporate Senior Bond',
      category: 'Bonds & Fixed Income',
      rating: 'AAA Corporate',
      annualYield: 5.20,
      maturity: '5 Years',
      minInvestment: 5000.0,
      risk: 'Low',
      description:
          'Investment grade institutional debt issuance with fixed semi-annual coupon distributions.',
    ),

    // Commodities
    InstrumentItem(
      title: 'Tokenized Physical Gold (PAXG / JWC-GOLD)',
      category: 'Commodities',
      rating: 'LBMA Certified',
      annualYield: 3.50,
      maturity: 'Spot / Perpetual',
      minInvestment: 250.0,
      risk: 'Moderate',
      description:
          '100% physically allocated fine gold stored in audited vaults in Zurich and London.',
    ),
    InstrumentItem(
      title: 'Brent Crude Oil Benchmark Yield Contract',
      category: 'Commodities',
      rating: 'Tier-1 Energy',
      annualYield: 14.20,
      maturity: 'Quarterly Roll',
      minInvestment: 500.0,
      risk: 'High',
      description:
          'Commodity futures backed yield structure targeting global oil supply movements.',
    ),

    // Startups & Venture Equity
    InstrumentItem(
      title: 'NeuralCompute AI Seed Series-A',
      category: 'Startups & Ventures',
      rating: 'Venture Backed',
      annualYield: 28.50,
      maturity: '3-5 Year Horizon',
      minInvestment: 2500.0,
      risk: 'High Growth',
      description:
          'Next-gen distributed GPU compute network for LLM inference and agentic reasoning.',
    ),
    InstrumentItem(
      title: 'DeFi Liquidity Aggregator V3',
      category: 'Startups & Ventures',
      rating: 'Y-Combinator Alumni',
      annualYield: 32.00,
      maturity: 'Liquid Secondary',
      minInvestment: 1000.0,
      risk: 'High Growth',
      description:
          'Decentralized cross-chain liquidity protocol built for institutional capital onboarding.',
    ),

    // Collectibles & Fine Art
    InstrumentItem(
      title: '1962 Ferrari 250 GTO Fractional Shares',
      category: 'Collectibles',
      rating: 'Concours Heritage',
      annualYield: 16.40,
      maturity: 'Open Secondary Market',
      minInvestment: 500.0,
      risk: 'Balanced',
      description:
          'Curated world-class classic automobile asset with verified provenance and climate vaulting.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showInvestModal(InstrumentItem item) {
    final TextEditingController amountController =
        TextEditingController(text: item.minInvestment.toStringAsFixed(0));
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
              Text(
                'Subscribe to ${item.title}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
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
                    _buildRow('Target Coupon / Yield',
                        '${item.annualYield}% Annualized'),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow('Maturity / Liquidity', item.maturity),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow('Credit / Security Rating', item.rating),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Investment Amount (\$)',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
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
                            'Subscription confirmed: \$${amountController.text} in ${item.title}'),
                        backgroundColor: AppTheme.greenBullish,
                      ),
                    );
                  },
                  child: const Text('Confirm Capital Allocation',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('Capital Instruments & Yield'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold,
          labelColor: AppTheme.gold,
          unselectedLabelColor: AppTheme.textSecondary,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Fixed Income & Bonds'),
            Tab(text: 'Commodities'),
            Tab(text: 'Startups & Ventures'),
            Tab(text: 'Collectibles & Art'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList('Bonds & Fixed Income'),
          _buildCategoryList('Commodities'),
          _buildCategoryList('Startups & Ventures'),
          _buildCategoryList('Collectibles'),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String category) {
    final list = _allInstruments.where((i) => i.category == category).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = list[index];
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.rating,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.gold,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.greenBullish.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${item.annualYield}% APY',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greenBullish,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Min Entry',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary)),
                      Text(AppFormatters.formatUsd(item.minInvestment),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Maturity',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary)),
                      Text(item.maturity,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Risk Profile',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary)),
                      Text(item.risk,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold)),
                    ],
                  ),
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
                  onPressed: () => _showInvestModal(item),
                  child: const Text('Subscribe Instrument',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
