import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../theme/app_theme.dart';
import '../../blocs/wallet_bloc.dart';

class WithdrawalScreen extends StatefulWidget {
  final WalletBloc walletBloc;

  const WithdrawalScreen({super.key, required this.walletBloc});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  String _selectedAsset = 'JWC';
  String _selectedNetwork = 'BSC (BEP-20)';
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '500');
  final TextEditingController _twoFaController = TextEditingController();

  final Map<String, double> _availableBalances = {
    'JWC': 25000.0,
    'USDT': 14250.0,
    'BTC': 0.65,
    'ETH': 4.80,
    'BNB': 18.50,
  };

  final Map<String, double> _networkFees = {
    'JWC': 1.0,
    'USDT': 2.0,
    'BTC': 0.0002,
    'ETH': 0.003,
    'BNB': 0.001,
  };

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _twoFaController.dispose();
    super.dispose();
  }

  void _submitWithdrawalRequest() {
    final address = _addressController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final maxBal = _availableBalances[_selectedAsset] ?? 0.0;

    if (address.isEmpty || address.length < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid destination address'),
            backgroundColor: AppTheme.redBearish),
      );
      return;
    }

    if (amount <= 0 || amount > maxBal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Invalid withdrawal amount. Max: $maxBal $_selectedAsset'),
            backgroundColor: AppTheme.redBearish),
      );
      return;
    }

    // 2FA Confirmation Modal
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.nightObsidian,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
              const Row(
                children: [
                  Icon(Icons.security, color: AppTheme.gold),
                  SizedBox(width: 10),
                  Text(
                    'Security 2FA Verification',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Confirm withdrawal of $amount $_selectedAsset to:\n$address',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _twoFaController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    letterSpacing: 8,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Enter 6-digit Authenticator Code',
                  labelStyle: const TextStyle(
                      color: AppTheme.textSecondary,
                      letterSpacing: 0,
                      fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.surfaceCharcoal,
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
                  onPressed: () async {
                    Navigator.pop(ctx);
                    HapticFeedback.heavyImpact();
                    final success = await widget.walletBloc.submitWithdrawal(
                      asset: _selectedAsset,
                      amount: amount,
                      destinationAddress: address,
                      network: _selectedNetwork,
                    );
                    if (mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Withdrawal request for $amount $_selectedAsset submitted! Pending on-chain settlement.'),
                          backgroundColor: AppTheme.greenBullish,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Confirm & Broadcast Payout',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxBal = _availableBalances[_selectedAsset] ?? 0.0;
    final fee = _networkFees[_selectedAsset] ?? 1.0;
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double netReceived = (amount - fee).clamp(0.0, 1000000.0);

    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coin selection
            const Text('Select Asset to Withdraw',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAsset,
                  dropdownColor: AppTheme.surfaceCharcoal,
                  isExpanded: true,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      fontSize: 16),
                  items: _availableBalances.keys.map((a) {
                    return DropdownMenuItem(
                        value: a,
                        child: Text('$a (Balance: ${_availableBalances[a]})'));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAsset = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Destination Address Input
            const Text('Destination Wallet Address',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Paste receiver address (BEP-20 / TRC-20)',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.surfaceCharcoal,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, color: AppTheme.gold),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      setState(() => _addressController.text = data!.text!);
                    }
                  },
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderHighlight),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Withdrawal Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary)),
                GestureDetector(
                  onTap: () => setState(
                      () => _amountController.text = maxBal.toString()),
                  child: Text('MAX: $maxBal $_selectedAsset',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.gold,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceCharcoal,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderHighlight),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Fee and Net Amount Summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Network Gas Fee', '$fee $_selectedAsset'),
                  const Divider(color: AppTheme.borderHighlight),
                  _buildSummaryRow(
                      'Net Amount Credited', '$netReceived $_selectedAsset',
                      isBold: true),
                  const Divider(color: AppTheme.borderHighlight),
                  _buildSummaryRow('Approval Time', 'Instant / ~5-15 Minutes'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
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
                onPressed: _submitWithdrawalRequest,
                child: const Text('Request Withdrawal',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppTheme.gold : AppTheme.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: isBold ? 14 : 13,
          ),
        ),
      ],
    );
  }
}
