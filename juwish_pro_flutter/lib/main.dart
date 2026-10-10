import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/jwc_checkout_dialog.dart';

void main() {
  runApp(const JuwishProApp());
}

class JuwishProApp extends StatelessWidget {
  const JuwishProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JuwishPro - Crypto Exchange & JWC Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0E11), // Binance Deep Dark
        cardColor: const Color(0xFF181A20), // Binance Surface Card
        primaryColor: const Color(0xFFF0B90B), // Binance Yellow
        dividerColor: const Color(0xFF2B313A), // Binance Border
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF0B90B),
          secondary: Color(0xFFFCD535),
          surface: Color(0xFF181A20),
        ),
      ),
      home: const JuwishProDashboardScreen(),
    );
  }
}

class JuwishProDashboardScreen extends StatefulWidget {
  const JuwishProDashboardScreen({super.key});

  @override
  State<JuwishProDashboardScreen> createState() =>
      _JuwishProDashboardScreenState();
}

class _JuwishProDashboardScreenState extends State<JuwishProDashboardScreen> {
  static const String webExchangeUrl = 'https://2026.dmillers.org';
  static const String jwcContract =
      '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99';
  static const String pancakeSwapUrl =
      'https://pancakeswap.finance/swap?outputCurrency=$jwcContract&chainId=56';

  double _userJwcBalance = 0.00;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  void _openJwcCheckout(BuildContext context) {
    JwcCheckoutDialog.show(
      context,
      onDepositConfirmed: (double amount) {
        setState(() {
          _userJwcBalance += amount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0ECB81),
            content: Text(
                'Credited ${amount.toStringAsFixed(2)} JWC to your balance!'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2B313A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.currency_exchange,
                  color: Color(0xFFF0B90B), size: 22),
            ),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: 'Juwish',
                      style: TextStyle(color: Color(0xFFEAECEF))),
                  TextSpan(
                      text: 'Pro', style: TextStyle(color: Color(0xFFF0B90B))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Balance pill in AppBar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2B313A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x4DF0B90B)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    size: 14, color: Color(0xFFF0B90B)),
                const SizedBox(width: 6),
                Text(
                  '${_userJwcBalance.toStringAsFixed(2)} JWC',
                  style: const TextStyle(
                    color: Color(0xFFF0B90B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _launchUrl(webExchangeUrl),
            icon: const Icon(Icons.open_in_browser,
                color: Color(0xFFF0B90B), size: 18),
            label: const Text('2026.dmillers.org',
                style: TextStyle(color: Color(0xFFF0B90B))),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF181A20), Color(0xFF1E2329)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2B313A)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JuwishPro Global Trading Ecosystem',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEAECEF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Institutional-grade digital asset exchange and automated PancakeSwap settlement engine on BNB Smart Chain.',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF848E9C)),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _openJwcCheckout(context),
                              icon: const Icon(Icons.account_balance_wallet,
                                  color: Color(0xFF181A20)),
                              label: const Text('Buy / Deposit JWC'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF0B90B),
                                foregroundColor: const Color(0xFF181A20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _launchUrl(pancakeSwapUrl),
                              icon: const Text('🥞',
                                  style: TextStyle(fontSize: 16)),
                              label: const Text('Swap on PancakeSwap'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFF0B90B),
                                side:
                                    const BorderSide(color: Color(0xFFF0B90B)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _launchUrl(webExchangeUrl),
                              icon: const Icon(Icons.language,
                                  color: Color(0xFFEAECEF)),
                              label: const Text('Launch Web Portal'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEAECEF),
                                side:
                                    const BorderSide(color: Color(0xFF2B313A)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Markets Table
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2B313A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.candlestick_chart,
                          color: Color(0xFFF0B90B), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Spot Markets Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEAECEF),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x260ECB81),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Zero Fees on JWC Pairs',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0ECB81),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF2B313A), height: 24),
                  _buildMarketRow(
                    symbol: 'JWC / USDT',
                    name: 'JuwishCoin (BEP-20)',
                    price: '\$0.0500',
                    change: '+14.80%',
                    isUp: true,
                    onTap: () => _openJwcCheckout(context),
                  ),
                  const Divider(color: Color(0xFF2B313A), height: 16),
                  _buildMarketRow(
                    symbol: 'BTC / USDT',
                    name: 'Bitcoin',
                    price: '\$64,320.50',
                    change: '+3.42%',
                    isUp: true,
                    onTap: () => _launchUrl('$webExchangeUrl/exchange'),
                  ),
                  const Divider(color: Color(0xFF2B313A), height: 16),
                  _buildMarketRow(
                    symbol: 'ETH / USDT',
                    name: 'Ethereum',
                    price: '\$3,450.20',
                    change: '+2.15%',
                    isUp: true,
                    onTap: () => _launchUrl('$webExchangeUrl/exchange'),
                  ),
                  const Divider(color: Color(0xFF2B313A), height: 16),
                  _buildMarketRow(
                    symbol: 'BNB / USDT',
                    name: 'BNB Smart Chain',
                    price: '\$586.40',
                    change: '+1.80%',
                    isUp: true,
                    onTap: () => _launchUrl('$webExchangeUrl/exchange'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // JuwishCoin (JWC) Specs Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2B313A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified,
                          color: Color(0xFF0ECB81), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'JuwishCoin (JWC) Token Specifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEAECEF),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B313A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Chain ID 56',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFF0B90B))),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF2B313A), height: 24),
                  Row(
                    children: const [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BEP-20 Contract Address',
                                style: TextStyle(
                                    color: Color(0xFF848E9C), fontSize: 12)),
                            SizedBox(height: 4),
                            SelectableText(jwcContract,
                                style: TextStyle(
                                    color: Color(0xFFF0B90B),
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketRow({
    required String symbol,
    required String name,
    required String price,
    required String change,
    required bool isUp,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symbol,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFEAECEF))),
                Text(name,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF848E9C))),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Color(0xFFEAECEF))),
                Text(change,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: isUp
                            ? const Color(0xFF0ECB81)
                            : const Color(0xFFF6465D))),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: Color(0xFF5E6673)),
          ],
        ),
      ),
    );
  }
}
