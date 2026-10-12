import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/crypto_payment_client.dart';
import '../presentation/blocs/wallet_bloc.dart';
import '../presentation/screens/wallet/crypto_deposit_screen.dart';
import '../presentation/screens/wallet/withdrawal_screen.dart';
import '../presentation/screens/wallet/transaction_history_screen.dart';

class WalletTab extends StatefulWidget {
  final double jwcBalance;
  final VoidCallback onDepositTap;
  final void Function(double newJwcBalance) onBalanceUpdated;

  const WalletTab({
    super.key,
    required this.jwcBalance,
    required this.onDepositTap,
    required this.onBalanceUpdated,
  });

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _txHashController = TextEditingController();
  final CryptoPaymentClient _paymentClient = CryptoPaymentClient();
  final WalletBloc _walletBloc = WalletBloc();
  bool _isVerifying = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _txHashController.dispose();
    _walletBloc.dispose();
    super.dispose();
  }

  Future<void> _verifyTxHash() async {
    final hash = _txHashController.text.trim();
    if (hash.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.redBearish,
          content: Text('Please enter a valid BSC transaction hash'),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    HapticFeedback.lightImpact();

    try {
      final res = await _paymentClient.verifyTxHash(hash);
      if (!mounted) return;

      if (res['success'] == true) {
        final amount = (res['amount'] ?? 1000.0).toDouble();
        widget.onBalanceUpdated(widget.jwcBalance + amount);
        _txHashController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.greenBullish,
            content: Text(
              'Tx Verified! Credited ${amount.toStringAsFixed(2)} JWC to your wallet!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.gold,
            content: Text(res['message'] ??
                'Transaction is being confirmed on BSC network.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.redBearish,
          content: Text('Verification error: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final jwcUsd = widget.jwcBalance * 1.425;
    final totalUsd = jwcUsd + 1250.0 + 820.0 + 500.0 + 350.0; // demo assets

    final assets = [
      (
        symbol: 'JWC',
        name: 'JuwishCoin (BEP-20)',
        amount: widget.jwcBalance,
        usd: jwcUsd,
        icon: 'assets/images/juwishcoin.png',
        isAssetImage: true,
      ),
      (
        symbol: 'USDT',
        name: 'Tether USD',
        amount: 1250.00,
        usd: 1250.00,
        icon: '',
        isAssetImage: false,
      ),
      (
        symbol: 'BTC',
        name: 'Bitcoin',
        amount: 0.0125,
        usd: 820.00,
        icon: '',
        isAssetImage: false,
      ),
      (
        symbol: 'BNB',
        name: 'BNB Smart Chain',
        amount: 0.843,
        usd: 500.00,
        icon: '',
        isAssetImage: false,
      ),
      (
        symbol: 'ETH',
        name: 'Ethereum',
        amount: 0.099,
        usd: 350.00,
        icon: '',
        isAssetImage: false,
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Net Worth Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2329), Color(0xFF181A20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderHighlight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Portfolio Valuation',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${totalUsd.toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CryptoDepositScreen(
                                    walletBloc: _walletBloc)),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner,
                            size: 16, color: Colors.black),
                        label: const Text('Deposit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    WithdrawalScreen(walletBloc: _walletBloc)),
                          );
                        },
                        icon: const Icon(Icons.outbox,
                            size: 16, color: AppTheme.gold),
                        label: const Text('Withdraw'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.gold,
                          side: const BorderSide(color: AppTheme.gold),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TransactionHistoryScreen(
                                    walletBloc: _walletBloc)),
                          );
                        },
                        icon: const Icon(Icons.receipt_long,
                            size: 16, color: AppTheme.textPrimary),
                        label: const Text('Ledger'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side:
                              const BorderSide(color: AppTheme.borderHighlight),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: widget.onDepositTap,
                        icon: const Icon(Icons.bolt,
                            size: 14, color: AppTheme.gold),
                        label: const Text('Quick JWC Topup',
                            style:
                                TextStyle(color: AppTheme.gold, fontSize: 11)),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _launchUrl(
                            'https://pancakeswap.finance/swap?outputCurrency=0xfeeef79d2a97d9e1f9bcb8eba8fd9587079c9e99&chainId=56'),
                        icon: const Icon(Icons.swap_calls,
                            size: 14, color: Color(0xFF00C9A7)),
                        label: const Text('PancakeSwap DEX',
                            style: TextStyle(
                                color: Color(0xFF00C9A7), fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // On-Chain Transaction Verifier Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCharcoal,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.bolt, color: AppTheme.gold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'PancakeSwap Tx Hash Verifier',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Paste your BNB Smart Chain transaction hash to verify and credit your JWC balance automatically.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.nightObsidian,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: TextField(
                    controller: _txHashController,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText: '0x123abc456def...',
                      hintStyle: const TextStyle(
                          color: AppTheme.textTertiary, fontSize: 12),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste,
                            size: 18, color: AppTheme.gold),
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data != null && data.text != null) {
                            _txHashController.text = data.text!;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyTxHash,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          )
                        : const Text(
                            'VERIFY & CREDIT JWC BALANCE',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Asset List Header
          const Text(
            'Your Crypto Balances',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Asset List
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: assets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final a = assets[index];
              final isJwc = a.symbol == 'JWC';
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isJwc
                        ? AppTheme.borderHighlight
                        : AppTheme.borderSubtle,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isJwc
                          ? AppTheme.gold.withOpacity(0.15)
                          : AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: a.isAssetImage
                        ? Image.asset(a.icon)
                        : Icon(
                            a.symbol == 'BTC'
                                ? Icons.currency_bitcoin
                                : Icons.account_balance_wallet,
                            color: AppTheme.gold,
                            size: 20,
                          ),
                  ),
                  title: Row(
                    children: [
                      Text(a.symbol,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                      if (isJwc) ...[
                        const SizedBox(width: 4),
                        const Text('✡',
                            style:
                                TextStyle(color: AppTheme.gold, fontSize: 12)),
                      ],
                    ],
                  ),
                  subtitle: Text(a.name,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        a.amount.toStringAsFixed(
                            a.symbol == 'BTC' || a.symbol == 'ETH' ? 4 : 2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '≈ \$${a.usd.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
