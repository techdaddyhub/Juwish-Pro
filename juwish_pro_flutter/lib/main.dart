import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/app_theme.dart';
import 'models/market_pair.dart';
import 'models/user_account.dart';
import 'views/home_tab.dart';
import 'views/markets_tab.dart';
import 'views/trade_tab.dart';
import 'views/futures_view.dart';
import 'views/capital_instruments_view.dart';
import 'views/vault_tab.dart';
import 'views/wallet_tab.dart';
import 'views/funding_view.dart';
import 'views/auth_view.dart';
import 'widgets/jwc_checkout_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure dark status bar icons and full-screen responsiveness
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surfaceCharcoal,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const JuwishProApp());
}

class JuwishProApp extends StatelessWidget {
  const JuwishProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JuwishPro | Crypto Exchange & JWC Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainResponsiveShell(),
    );
  }
}

class MainResponsiveShell extends StatefulWidget {
  const MainResponsiveShell({super.key});

  @override
  State<MainResponsiveShell> createState() => _MainResponsiveShellState();
}

class _MainResponsiveShellState extends State<MainResponsiveShell> {
  int _currentIndex = 0;
  double _jwcBalance = 2500.00;
  MarketPair? _selectedTradingPair;
  UserAccount _currentUser = UserAccount.mockAdmin();

  static const String webExchangeUrl = 'https://2026.dmillers.org';

  void _onTabSelected(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _onTradePairSelected(MarketPair pair) {
    setState(() {
      _selectedTradingPair = pair;
      _currentIndex = 2; // Jump to trade tab
    });
  }

  void _openDepositDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    JwcCheckoutDialog.show(
      context,
      onDepositConfirmed: (double amount) {
        setState(() {
          _jwcBalance += amount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.greenBullish,
            content: Text(
              'Credited ${amount.toStringAsFixed(2)} JWC to your balance!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchWebPortal() async {
    final uri = Uri.parse(webExchangeUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $webExchangeUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;

        final tabs = [
          HomeTab(
            jwcBalance: _jwcBalance,
            onDepositTap: () => _openDepositDialog(context),
            onNavigateTab: (index) => _onTabSelected(index),
          ),
          MarketsTab(
            onSelectPair: _onTradePairSelected,
          ),
          TradeTab(
            initialPair: _selectedTradingPair,
            jwcBalance: _jwcBalance,
            onBalanceUpdated: (newBal) => setState(() => _jwcBalance = newBal),
          ),
          const FuturesView(),
          const CapitalInstrumentsView(),
          VaultTab(
            jwcBalance: _jwcBalance,
            onBalanceUpdated: (newBal) => setState(() => _jwcBalance = newBal),
          ),
          const FundingView(),
          AuthView(
            currentUser: _currentUser,
            onUserUpdated: (u) => setState(() => _currentUser = u),
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderHighlight),
                  ),
                  child: Image.asset('assets/images/juwishcoin.png'),
                ),
                const SizedBox(width: 10),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'JUWISH',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      TextSpan(
                        text: 'PRO',
                        style: TextStyle(color: AppTheme.gold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Quick action: Futures & Margin
              IconButton(
                tooltip: 'Futures & Margin Trading',
                icon: Icon(
                  Icons.stacked_line_chart,
                  color: _currentIndex == 3 ? AppTheme.gold : AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () => _onTabSelected(3),
              ),

              // Quick action: Stocks & Capital Assets
              IconButton(
                tooltip: 'Stocks, ETFs & Bonds',
                icon: Icon(
                  Icons.domain,
                  color: _currentIndex == 4 ? AppTheme.gold : AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () => _onTabSelected(4),
              ),

              // JWC Balance chip
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppTheme.nightObsidian,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderHighlight),
                ),
                child: Row(
                  children: [
                    const Text('✡',
                        style: TextStyle(color: AppTheme.gold, fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${_jwcBalance.toStringAsFixed(0)} JWC',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // User Profile & KYC
              IconButton(
                tooltip: 'Profile & KYC Status',
                icon: Icon(
                  Icons.account_circle,
                  color: _currentIndex == 7 ? AppTheme.gold : AppTheme.textSecondary,
                  size: 22,
                ),
                onPressed: () => _onTabSelected(7),
              ),

              // Web Portal Link
              IconButton(
                tooltip: '2026.dmillers.org Live Portal',
                icon: const Icon(Icons.language,
                    color: AppTheme.textSecondary, size: 20),
                onPressed: _launchWebPortal,
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: isWide
              ? Row(
                  children: [
                    // Navigation Rail for Tablet / Desktop (Full 8 Modules)
                    NavigationRail(
                      backgroundColor: AppTheme.surfaceCharcoal,
                      selectedIndex: _currentIndex,
                      onDestinationSelected: _onTabSelected,
                      labelType: NavigationRailLabelType.all,
                      selectedIconTheme:
                          const IconThemeData(color: AppTheme.gold),
                      selectedLabelTextStyle: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      unselectedLabelTextStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.insert_chart_outlined),
                          selectedIcon: Icon(Icons.insert_chart),
                          label: Text('Markets'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.candlestick_chart_outlined),
                          selectedIcon: Icon(Icons.candlestick_chart),
                          label: Text('Trade'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.stacked_line_chart_outlined),
                          selectedIcon: Icon(Icons.stacked_line_chart),
                          label: Text('Futures'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.domain_outlined),
                          selectedIcon: Icon(Icons.domain),
                          label: Text('Assets'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.account_balance_outlined),
                          selectedIcon: Icon(Icons.account_balance),
                          label: Text('Vault'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.account_balance_wallet_outlined),
                          selectedIcon: Icon(Icons.account_balance_wallet),
                          label: Text('Wallet'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
                      ],
                    ),
                    const VerticalDivider(
                        color: AppTheme.borderSubtle, width: 1),

                    // Main Content Area constrained
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: IndexedStack(
                            index: _currentIndex,
                            children: tabs,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : IndexedStack(
                  index: _currentIndex,
                  children: tabs,
                ),
          bottomNavigationBar: isWide
              ? null
              : BottomNavigationBar(
                  currentIndex: _currentIndex > 4 ? 4 : _currentIndex,
                  onTap: _onTabSelected,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.insert_chart_outlined),
                      activeIcon: Icon(Icons.insert_chart),
                      label: 'Markets',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.candlestick_chart_outlined),
                      activeIcon: Icon(Icons.candlestick_chart),
                      label: 'Trade',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_outlined),
                      activeIcon: Icon(Icons.account_balance),
                      label: 'Vault',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      activeIcon: Icon(Icons.account_balance_wallet),
                      label: 'Wallet',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
