import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../blocs/wallet_bloc.dart';

class CryptoDepositScreen extends StatefulWidget {
  final WalletBloc walletBloc;

  const CryptoDepositScreen({super.key, required this.walletBloc});

  @override
  State<CryptoDepositScreen> createState() => _CryptoDepositScreenState();
}

class _CryptoDepositScreenState extends State<CryptoDepositScreen> {
  String _selectedAsset = 'JWC';
  String _selectedNetwork = 'BSC (BEP-20)';
  final String _depositAddress = '0x3aF8795A40129a03975CFFa7Ea37eb5f02D15792';
  final TextEditingController _amountController =
      TextEditingController(text: '1000');

  final Map<String, List<String>> _networks = {
    'JWC': ['BSC (BEP-20)'],
    'USDT': ['TRC-20 (Tron)', 'BEP-20 (BSC)', 'ERC-20 (Ethereum)'],
    'BTC': ['Bitcoin Native', 'BEP-20 (BTCB)'],
    'ETH': ['ERC-20 (Ethereum)', 'Arbitrum One', 'Optimism'],
    'BNB': ['BNB Smart Chain (BEP-20)'],
  };

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: AppTheme.greenBullish,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableNetworks = _networks[_selectedAsset] ?? ['Default'];
    if (!availableNetworks.contains(_selectedNetwork)) {
      _selectedNetwork = availableNetworks.first;
    }

    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      appBar: AppBar(
        title: const Text('Deposit Crypto Assets'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Selector
            const Text('Select Deposit Coin',
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
                  items: ['JWC', 'USDT', 'BTC', 'ETH', 'BNB'].map((a) {
                    return DropdownMenuItem(
                      value: a,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: a == 'JWC'
                                ? AppTheme.gold
                                : AppTheme.borderHighlight,
                            child: Text(
                              a.substring(0, 1),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: a == 'JWC'
                                    ? AppTheme.nightObsidian
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(a == 'JWC' ? 'JuwishCoin (JWC) - Native' : a),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAsset = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Network Selector
            const Text('Deposit Network',
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
                  value: _selectedNetwork,
                  dropdownColor: AppTheme.surfaceCharcoal,
                  isExpanded: true,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gold,
                      fontSize: 15),
                  items: availableNetworks.map((n) {
                    return DropdownMenuItem(value: n, child: Text(n));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedNetwork = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // QR Code Presentation Card
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withOpacity(0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data:
                      '$_selectedNetwork:$_depositAddress?amount=${_amountController.text}',
                  version: QrVersions.auto,
                  size: 200.0,
                  foregroundColor: const Color(0xFF0B0E11),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Deposit Address Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Official Inbound Address',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            color: AppTheme.gold, size: 20),
                        onPressed: () => _copyToClipboard(
                            _depositAddress, 'Deposit Address'),
                      ),
                    ],
                  ),
                  Text(
                    _depositAddress,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details and Important Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildRow('Minimum Deposit', '10.00 $_selectedAsset'),
                  const Divider(color: AppTheme.borderHighlight),
                  _buildRow(
                      'Confirmation Blocks', '15 Block Confirmations (~45s)'),
                  const Divider(color: AppTheme.borderHighlight),
                  _buildRow(
                      'Account Crediting', 'Instant Automatic Webhook Sync'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Copy Address Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.nightObsidian,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copy Deposit Address',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () =>
                    _copyToClipboard(_depositAddress, 'Deposit Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ],
    );
  }
}
