import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../theme/app_theme.dart';

class PropertyItem {
  final String title;
  final String location;
  final double propertyValuation;
  final double rentalYieldPercent;
  final double minInvestment;
  final double totalFundedPercent;
  final String contractId;
  final String status;
  final String propertyType;

  const PropertyItem({
    required this.title,
    required this.location,
    required this.propertyValuation,
    required this.rentalYieldPercent,
    required this.minInvestment,
    required this.totalFundedPercent,
    required this.contractId,
    required this.status,
    required this.propertyType,
  });
}

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  final List<PropertyItem> _properties = const [
    PropertyItem(
      title: 'The Hudson Yards Luxury Tower',
      location: 'Manhattan, New York, USA',
      propertyValuation: 48500000.0,
      rentalYieldPercent: 9.8,
      minInvestment: 500.0,
      totalFundedPercent: 88.5,
      contractId: 'RE-NYC-0941-JWC',
      status: 'Open for Funding',
      propertyType: 'Commercial / Residential',
    ),
    PropertyItem(
      title: 'Marina Gate Waterfront Residences',
      location: 'Dubai Marina, UAE',
      propertyValuation: 24200000.0,
      rentalYieldPercent: 12.4,
      minInvestment: 250.0,
      totalFundedPercent: 94.2,
      contractId: 'RE-DXB-8820-JWC',
      status: 'Open for Funding',
      propertyType: 'High-Yield Residential',
    ),
    PropertyItem(
      title: 'Kensington Garden Court Estates',
      location: 'London, United Kingdom',
      propertyValuation: 32000000.0,
      rentalYieldPercent: 8.4,
      minInvestment: 1000.0,
      totalFundedPercent: 72.0,
      contractId: 'RE-LON-4412-JWC',
      status: 'Open for Funding',
      propertyType: 'Prime Real Estate',
    ),
    PropertyItem(
      title: 'Silicon Valley Innovation Park',
      location: 'Palo Alto, California, USA',
      propertyValuation: 65000000.0,
      rentalYieldPercent: 11.2,
      minInvestment: 2500.0,
      totalFundedPercent: 100.0,
      contractId: 'RE-SFO-7711-JWC',
      status: 'Fully Funded (Yielding)',
      propertyType: 'Tech Hub Office Campus',
    ),
  ];

  void _showAllocationModal(PropertyItem property) {
    final TextEditingController amountController =
        TextEditingController(text: property.minInvestment.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.nightObsidian,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
              Text(
                'Fractional Ownership: ${property.title}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Smart Contract ID: ${property.contractId}',
                style: const TextStyle(fontSize: 12, color: AppTheme.gold),
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
                    _buildRow('Target Property Valuation',
                        AppFormatters.formatUsd(property.propertyValuation)),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow('Annual Rental Yield',
                        '${property.rentalYieldPercent}% Net ROI'),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow('Yield Distribution Frequency',
                        'Monthly Automatic Credit (JWC / USDT)'),
                    const Divider(color: AppTheme.borderHighlight),
                    _buildRow('Minimum Allocation',
                        AppFormatters.formatUsd(property.minInvestment)),
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
                            'Contract signed! \$${amountController.text} allocated into ${property.title}'),
                        backgroundColor: AppTheme.greenBullish,
                      ),
                    );
                  },
                  child: const Text('Execute Fractional Contract',
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
        title: const Text('Real Estate & Fractional Assets'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio statistics overview
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
                      _buildMetricColumn('Total Real Estate AUM', '\$169.7M'),
                      _buildMetricColumn('Avg. Net Rental Yield', '10.45%'),
                      _buildMetricColumn('Funded Contracts', '1,420+'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Institutional Property Listings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _properties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = _properties[index];
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.propertyType,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            item.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: item.totalFundedPercent >= 100
                                  ? AppTheme.textSecondary
                                  : AppTheme.greenBullish,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                      ),
                      Text(
                        item.location,
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
                              const Text('Valuation',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary)),
                              Text(
                                  AppFormatters.formatUsd(
                                      item.propertyValuation),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Rental Yield',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary)),
                              Text('${item.rentalYieldPercent}% / yr',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.greenBullish)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Min. Stake',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary)),
                              Text(AppFormatters.formatUsd(item.minInvestment),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.gold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.totalFundedPercent / 100.0,
                          backgroundColor: AppTheme.nightObsidian,
                          color: AppTheme.gold,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Funded: ${item.totalFundedPercent}%',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                          Text('Contract: ${item.contractId}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.gold),
                            foregroundColor: AppTheme.gold,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showAllocationModal(item),
                          child: const Text('View Contract & Allocate Capital',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.gold)),
      ],
    );
  }
}
