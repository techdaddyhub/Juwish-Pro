import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/laravel_api_service.dart';
import '../theme/app_theme.dart';

class FundingView extends StatefulWidget {
  const FundingView({super.key});

  @override
  State<FundingView> createState() => _FundingViewState();
}

class _FundingViewState extends State<FundingView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LaravelApiService _api = LaravelApiService();

  String _selectedDepositAsset = 'JWC';
  final String _selectedDepositNetwork = 'BNB Smart Chain (BEP20)';
  final String _depositAddress = '0x71C84949b99682e7075A0c49A4C0513903d6511a';

  final String _selectedWithdrawAsset = 'JWC';
  final TextEditingController _withdrawAddress = TextEditingController();
  final TextEditingController _withdrawAmount =
      TextEditingController(text: '5000');
  bool _isWithdrawing = false;

  final List<Map<String, dynamic>> _transactions = [
    {
      'type': 'Deposit',
      'asset': 'JWC',
      'amount': '+1,250,000 JWC',
      'status': 'Approved',
      'date': '2026-10-12 04:30',
      'ref': 'DEP-JWC-891024',
    },
    {
      'type': 'Staking Reward',
      'asset': 'JWC',
      'amount': '+496.57 JWC',
      'status': 'Approved',
      'date': '2026-10-12 00:00',
      'ref': 'YLD-VAULT-44810',
    },
    {
      'type': 'Deposit',
      'asset': 'USDT',
      'amount': '+18,450.00 USDT',
      'status': 'Approved',
      'date': '2026-10-11 18:22',
      'ref': 'DEP-USDT-90214',
    },
    {
      'type': 'Futures PnL',
      'asset': 'USDT',
      'amount': '+1,600.00 USDT',
      'status': 'Approved',
      'date': '2026-10-11 14:10',
      'ref': 'TRD-FUT-11849',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _withdrawAddress.dispose();
    _withdrawAmount.dispose();
    super.dispose();
  }

  Future<void> _handleWithdrawal() async {
    final amount = double.tryParse(_withdrawAmount.text) ?? 0.0;
    if (amount <= 0 || _withdrawAddress.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.lossRed,
          content: Text('Please enter valid withdrawal address and amount!'),
        ),
      );
      return;
    }

    setState(() => _isWithdrawing = true);
    final res = await _api.submitWithdrawal(
      asset: _selectedWithdrawAsset,
      amount: amount,
      destinationAddress: _withdrawAddress.text.trim(),
      network: 'BEP20 (Binance Smart Chain)',
    );
    setState(() => _isWithdrawing = false);

    if (mounted) {
      setState(() {
        _transactions.insert(0, {
          'type': 'Withdrawal',
          'asset': _selectedWithdrawAsset,
          'amount': '-$amount $_selectedWithdrawAsset',
          'status': 'Pending (On-Chain)',
          'date': 'Just now',
          'ref': res['txHash'] ?? 'TX-98421',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.gainGreen,
          content: Text(
            'Withdrawal submitted! TX: ${res["txHash"]}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              color: AppTheme.surfaceDark,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.gold,
                labelColor: AppTheme.gold,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [
                  Tab(text: 'Deposit'),
                  Tab(text: 'Withdrawal'),
                  Tab(text: 'Transactions'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Deposit
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Asset Selector
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDepositAsset,
                              isExpanded: true,
                              dropdownColor: AppTheme.surfaceDark,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold),
                              items: ['JWC', 'USDT', 'BTC', 'ETH'].map((coin) {
                                return DropdownMenuItem(
                                  value: coin,
                                  child: Row(
                                    children: [
                                      if (coin == 'JWC')
                                        const Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: Text('✡',
                                              style: TextStyle(
                                                  color: AppTheme.gold,
                                                  fontSize: 16)),
                                        ),
                                      Text(coin == 'JWC'
                                          ? 'JuwishCoin (JWC)'
                                          : coin),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedDepositAsset = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Network info badge
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppTheme.gold, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Network: $_selectedDepositNetwork\nContract: 0x71c...6511a',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // QR Code Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.gold.withOpacity(0.15),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: _depositAddress,
                            version: QrVersions.auto,
                            size: 180.0,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Deposit Address Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Deposit Address',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _depositAddress,
                                      style: const TextStyle(
                                        color: AppTheme.gold,
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy,
                                        color: AppTheme.gold, size: 18),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: AppTheme.gainGreen,
                                          content: Text(
                                              'Deposit address copied to clipboard!'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Withdrawal
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _withdrawAddress,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontFamily: 'monospace',
                              fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Destination Wallet Address',
                            hintText: '0x...',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            prefixIcon: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _withdrawAmount,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'Amount to Withdraw',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            suffixText: _selectedWithdrawAsset,
                            suffixStyle: const TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Network Fee',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13)),
                              Text('0.0005 BNB (~0.30 USDT)',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.gold,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed:
                                _isWithdrawing ? null : _handleWithdrawal,
                            child: _isWithdrawing
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : const Text('Confirm Instant Withdrawal',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 3: Transactions
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, idx) {
                      final tx = _transactions[idx];
                      final isDeposit =
                          tx['type'].toString().contains('Deposit') ||
                              tx['type'].toString().contains('Reward');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDeposit
                                        ? AppTheme.gainGreen.withOpacity(0.15)
                                        : AppTheme.lossRed.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDeposit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isDeposit
                                        ? AppTheme.gainGreen
                                        : AppTheme.lossRed,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx['type'] as String,
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      '${tx["date"]} • ${tx["ref"]}',
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  tx['amount'] as String,
                                  style: TextStyle(
                                    color: isDeposit
                                        ? AppTheme.gainGreen
                                        : AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  tx['status'] as String,
                                  style: const TextStyle(
                                      color: AppTheme.gainGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
