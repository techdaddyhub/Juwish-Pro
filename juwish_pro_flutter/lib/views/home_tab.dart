import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/market_data_service.dart';
import '../widgets/sparkline_chart.dart';
import '../presentation/blocs/auth_bloc.dart';
import '../presentation/blocs/market_bloc.dart';
import '../presentation/blocs/trading_bloc.dart';
import '../presentation/blocs/wallet_bloc.dart';
import '../presentation/screens/sectors/stocks_etfs_screen.dart';
import '../presentation/screens/sectors/crypto_jwc_screen.dart';
import '../presentation/screens/sectors/real_estate_screen.dart';
import '../presentation/screens/sectors/capital_instruments_screen.dart';
import '../presentation/screens/sectors/managed_portfolios_screen.dart';
import '../presentation/screens/trading/futures_trading_screen.dart';
import '../presentation/screens/trading/margin_trading_screen.dart';
import '../presentation/screens/trading/forex_trading_screen.dart';
import '../presentation/screens/wallet/crypto_deposit_screen.dart';
import '../presentation/screens/wallet/withdrawal_screen.dart';
import '../presentation/screens/wallet/transaction_history_screen.dart';
import '../presentation/screens/auth/kyc_screen.dart';

class HomeTab extends StatefulWidget {
  final double jwcBalance;
  final VoidCallback onDepositTap;
  final void Function(int tabIndex) onNavigateTab;

  const HomeTab({
    super.key,
    required this.jwcBalance,
    required this.onDepositTap,
    required this.onNavigateTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  bool _showBalance = true;
  final MarketDataService _dataService = MarketDataService();
  final MarketBloc _marketBloc = MarketBloc();
  final TradingBloc _tradingBloc = TradingBloc();
  final WalletBloc _walletBloc = WalletBloc();
  final AuthBloc _authBloc = AuthBloc();

  @override
  void dispose() {
    _marketBloc.dispose();
    _tradingBloc.dispose();
    _walletBloc.dispose();
    _authBloc.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final allPairs = _dataService.getAllPairs();
    final topGainers = List.of(allPairs)
      ..sort((a, b) => b.change24hPercent.compareTo(a.change24hPercent));

    return RefreshIndicator(
      color: AppTheme.gold,
      backgroundColor: AppTheme.surfaceCharcoal,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {});
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // 1. Balance Header Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildBalanceCard(),
            ),
          ),

          // 2. Quick Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildQuickActions(),
            ),
          ),

          // 3. Staking Vault Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildStakingBanner(),
            ),
          ),

          // 3.1. Asset Sectors (Full Parity)
          SliverToBoxAdapter(
            child: _buildParitySectorsSection(context),
          ),

          // 3.2. Live Trading Engines Hub
          SliverToBoxAdapter(
            child: _buildTradingEnginesSection(context),
          ),

          // 3.3. Banking & Settlement Hub
          SliverToBoxAdapter(
            child: _buildBankingQuickSection(context),
          ),

          // 4. Hot Markets Ticker Carousel
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Hot Tickers',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: allPairs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final pair = allPairs[index];
                      return _buildTickerCard(pair);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 5. Top Market Gainers Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up,
                          size: 18, color: AppTheme.greenBullish),
                      SizedBox(width: 6),
                      Text(
                        'Top Gainers',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(1),
                    child: const Text('View All',
                        style: TextStyle(color: AppTheme.gold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          // 6. Gainers List (Lazy rendering for fast performance)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final pair = topGainers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCharcoal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pair.isJwc
                            ? AppTheme.borderHighlight
                            : AppTheme.borderSubtle,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      leading: Container(
                        width: 38,
                        height: 38,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: pair.isJwc
                              ? AppTheme.gold.withOpacity(0.15)
                              : AppTheme.borderSubtle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: pair.isJwc
                            ? Image.asset('assets/images/juwishcoin.png')
                            : const Icon(Icons.currency_bitcoin,
                                color: AppTheme.gold, size: 20),
                      ),
                      title: Text(
                        pair.symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        pair.name,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SparklineChart(
                            data: pair.sparkline,
                            color: pair.isBullish
                                ? AppTheme.greenBullish
                                : AppTheme.redBearish,
                            width: 60,
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                pair.formattedPrice,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
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
                        ],
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onNavigateTab(2); // Go to trade
                      },
                    ),
                  );
                },
                childCount: topGainers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final estUsd = widget.jwcBalance * 1.425;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2329), Color(0xFF181A20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderHighlight),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Estimated Balance',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showBalance = !_showBalance);
                    },
                    child: Icon(
                      _showBalance
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderHighlight),
                ),
                child: const Row(
                  children: [
                    Text('✡ JWC Core',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _showBalance ? '\$${estUsd.toStringAsFixed(2)} USD' : '••••••••',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _showBalance
                    ? '≈ ${widget.jwcBalance.toStringAsFixed(2)} JWC'
                    : '≈ •••• JWC',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: AppTheme.gold,
                ),
              ),
              const Spacer(),
              const Text(
                'Today: +14.8%',
                style: TextStyle(
                  color: AppTheme.greenBullish,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
        label: 'Deposit JWC',
        icon: Icons.add_circle_outline,
        color: AppTheme.gold,
        onTap: widget.onDepositTap
      ),
      (
        label: 'PancakeSwap',
        icon: Icons.swap_horiz,
        color: const Color(0xFF00C9A7),
        onTap: () => _launchUrl(
            'https://pancakeswap.finance/swap?outputCurrency=0xfeeef79d2a97d9e1f9bcb8eba8fd9587079c9e99&chainId=56')
      ),
      (
        label: 'Staking Vault',
        icon: Icons.account_balance,
        color: const Color(0xFF9D65CD),
        onTap: () => widget.onNavigateTab(3)
      ),
      (
        label: 'Trade Spot',
        icon: Icons.candlestick_chart,
        color: AppTheme.greenBullish,
        onTap: () => widget.onNavigateTab(2)
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                a.onTap();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCharcoal,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: a.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a.icon, color: a.color, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.label,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStakingBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B2613), Color(0xFF181A20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Earn 14.50% Fixed APY compounded daily in JWC',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onNavigateTab(3);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Stake',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildParitySectorsSection(BuildContext context) {
    final sectors = [
      (
        title: 'Stocks & ETFs',
        subtitle: 'DMA Equities & Dividends',
        icon: Icons.trending_up,
        color: const Color(0xFF00C9A7),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StocksEtfsScreen()),
            ),
      ),
      (
        title: 'Crypto & JWC',
        subtitle: 'Live \$1.425 • DEX Swap',
        icon: Icons.stars,
        color: AppTheme.gold,
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CryptoJwcScreen(marketBloc: _marketBloc)),
            ),
      ),
      (
        title: 'Real Estate',
        subtitle: 'Fractional & Rental Yields',
        icon: Icons.apartment,
        color: const Color(0xFF4D96FF),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RealEstateScreen()),
            ),
      ),
      (
        title: 'Capital Instruments',
        subtitle: 'Bonds, Gold & Collectibles',
        icon: Icons.account_balance,
        color: const Color(0xFFFF6B6B),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CapitalInstrumentsScreen()),
            ),
      ),
      (
        title: 'Managed Portfolios',
        subtitle: '29 Active Database Plans',
        icon: Icons.pie_chart,
        color: const Color(0xFF9D65CD),
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ManagedPortfoliosScreen()),
            ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Asset Sectors (Full Parity)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '5 Institutional Sectors',
                style: TextStyle(fontSize: 11, color: AppTheme.gold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sectors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final s = sectors[i];
                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    s.onTap();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCharcoal,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderHighlight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: s.color.withOpacity(0.18),
                              child: Icon(s.icon, size: 14, color: s.color),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right,
                                size: 16, color: AppTheme.textSecondary),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppTheme.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              s.subtitle,
                              style: const TextStyle(
                                  fontSize: 10, color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingEnginesSection(BuildContext context) {
    final engines = [
      (
        title: 'Futures Trading',
        desc: 'Up to 125x Leverage • TP/SL Risk Tools',
        icon: Icons.flash_on,
        badge: '125x',
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FuturesTradingScreen(
                  tradingBloc: _tradingBloc,
                  marketBloc: _marketBloc,
                ),
              ),
            ),
      ),
      (
        title: 'Margin Trading',
        desc: '3x-10x Borrow / Repay • Collateral Buffer',
        icon: Icons.balance,
        badge: 'Margin',
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarginTradingScreen()),
            ),
      ),
      (
        title: 'Forex Pairs',
        desc: 'Interbank Spreads • Instant Conversion',
        icon: Icons.currency_exchange,
        badge: '0.2 pips',
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForexTradingScreen()),
            ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Live Trading Engines',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Institutional DMA',
                style: TextStyle(fontSize: 11, color: AppTheme.gold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: engines.map((e) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      e.onTap();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCharcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderHighlight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(e.icon, size: 20, color: AppTheme.gold),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  e.badge,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.gold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            e.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.desc,
                            style: const TextStyle(
                                fontSize: 9.5, color: AppTheme.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBankingQuickSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCharcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderHighlight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBankAction(
              icon: Icons.qr_code_scanner,
              label: 'Deposit',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        CryptoDepositScreen(walletBloc: _walletBloc)),
              ),
            ),
            _buildBankAction(
              icon: Icons.outbox,
              label: 'Withdraw',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => WithdrawalScreen(walletBloc: _walletBloc)),
              ),
            ),
            _buildBankAction(
              icon: Icons.receipt_long,
              label: 'Ledger',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        TransactionHistoryScreen(walletBloc: _walletBloc)),
              ),
            ),
            _buildBankAction(
              icon: Icons.verified_user,
              label: 'KYC',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => KycScreen(authBloc: _authBloc)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.gold, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTickerCard(pair) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onNavigateTab(2);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCharcoal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                pair.isJwc ? AppTheme.borderHighlight : AppTheme.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pair.symbol,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (pair.isJwc)
                  const Text('✡',
                      style: TextStyle(fontSize: 10, color: AppTheme.gold)),
              ],
            ),
            Text(
              pair.formattedPrice,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: AppTheme.textPrimary,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pair.formattedChange,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: pair.isBullish
                        ? AppTheme.greenBullish
                        : AppTheme.redBearish,
                  ),
                ),
                SparklineChart(
                  data: pair.sparkline,
                  color: pair.isBullish
                      ? AppTheme.greenBullish
                      : AppTheme.redBearish,
                  width: 36,
                  height: 14,
                  showGradient: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
