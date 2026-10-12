import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class VaultTab extends StatefulWidget {
  final double jwcBalance;
  final void Function(double newJwcBalance) onBalanceUpdated;

  const VaultTab({
    super.key,
    required this.jwcBalance,
    required this.onBalanceUpdated,
  });

  @override
  State<VaultTab> createState() => _VaultTabState();
}

class _VaultTabState extends State<VaultTab>
    with AutomaticKeepAliveClientMixin {
  double _stakedAmount = 10000.0;
  static const double _fixedApy = 14.50; // 14.5%

  @override
  bool get wantKeepAlive => true;

  double get _dailyYield => (_stakedAmount * (_fixedApy / 100)) / 365.0;
  double get _monthlyYield => (_stakedAmount * (_fixedApy / 100)) / 12.0;
  double get _yearlyYield => _stakedAmount * (_fixedApy / 100);

  void _stakeTokens() {
    HapticFeedback.mediumImpact();
    if (widget.jwcBalance < _stakedAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.redBearish,
          content: Text(
            'Need ${_stakedAmount.toStringAsFixed(0)} JWC to activate vault (Current: ${widget.jwcBalance.toStringAsFixed(0)} JWC)',
          ),
        ),
      );
      return;
    }

    widget.onBalanceUpdated(widget.jwcBalance - _stakedAmount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.greenBullish,
        content: Text(
          'Successfully locked ${_stakedAmount.toStringAsFixed(0)} JWC in JuwishPro Vault at 14.5% APY!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildVaultHero(),
          const SizedBox(height: 16),

          // Yield Calculator Card
          _buildCalculatorCard(),
          const SizedBox(height: 16),

          // Staking Tiers
          _buildTiersCard(),
        ],
      ),
    );
  }

  Widget _buildVaultHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF262010), Color(0xFF181A20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.gold),
                ),
                child: Image.asset('assets/images/juwishcoin.png'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '✡ JuwishPro Staking Vault',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Decentralized Generational Wealth',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.greenGlow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.greenBullish),
                ),
                child: const Text(
                  '14.5% APY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.greenBullish,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Harness centuries of financial wisdom with automated on-chain compound interest. Zero lockup fees, daily distributed rewards, and 100% audited smart contract reserves.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCharcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Compound Calculator',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${_stakedAmount.toStringAsFixed(0)} JWC',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),
          Slider(
            value: _stakedAmount,
            min: 1000.0,
            max: 100000.0,
            divisions: 99,
            activeColor: AppTheme.gold,
            inactiveColor: AppTheme.borderSubtle,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _stakedAmount = val);
            },
          ),
          const SizedBox(height: 12),

          // Yield Projections
          Row(
            children: [
              _buildYieldTile('Daily Yield',
                  '${_dailyYield.toStringAsFixed(2)} JWC', '≈ \$${(_dailyYield * 1.425).toStringAsFixed(2)}'),
              const SizedBox(width: 8),
              _buildYieldTile('Monthly',
                  '${_monthlyYield.toStringAsFixed(1)} JWC', '≈ \$${(_monthlyYield * 1.425).toStringAsFixed(2)}'),
              const SizedBox(width: 8),
              _buildYieldTile('Annual (1Y)',
                  '${_yearlyYield.toStringAsFixed(0)} JWC', '≈ \$${(_yearlyYield * 1.425).toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _stakeTokens,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'LOCK IN STAKING VAULT (14.5% APY)',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYieldTile(String label, String jwc, String usd) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.nightObsidian,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              jwc,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: AppTheme.gold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              usd,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTiersCard() {
    final tiers = [
      (
        title: 'Magen David Explorer',
        range: '1,000 - 9,999 JWC',
        apr: '12.0%',
        badge: 'Bronze'
      ),
      (
        title: 'Silver Custody Vault',
        range: '10,000 - 49,999 JWC',
        apr: '14.5%',
        badge: 'Silver'
      ),
      (
        title: 'Gold Sanctuary VIP',
        range: '50,000+ JWC',
        apr: '16.8%',
        badge: 'VIP'
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCharcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vault Tier Privileges',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...tiers.map((t) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Text(t.range,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.borderHighlight),
                    ),
                    child: Text(
                      t.apr,
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
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
}
