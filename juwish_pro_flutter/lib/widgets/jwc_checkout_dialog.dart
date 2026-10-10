import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/crypto_payment_client.dart';

/// JuwishPro - JuwishCoin (JWC) BEP-20 Deposit & PancakeSwap Settlement Dialog
class JwcCheckoutDialog extends StatefulWidget {
  final ValueChanged<double>? onDepositConfirmed;

  const JwcCheckoutDialog({
    super.key,
    this.onDepositConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    ValueChanged<double>? onDepositConfirmed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => JwcCheckoutDialog(
        onDepositConfirmed: onDepositConfirmed,
      ),
    );
  }

  @override
  State<JwcCheckoutDialog> createState() => _JwcCheckoutDialogState();
}

class _JwcCheckoutDialogState extends State<JwcCheckoutDialog> {
  static const String jwcContract =
      '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99';
  static const String pancakeSwapUrl =
      'https://pancakeswap.finance/swap?outputCurrency=$jwcContract&chainId=56';

  final CryptoPaymentClient _apiClient = CryptoPaymentClient();
  final TextEditingController _txHashController = TextEditingController();

  bool _isVerifying = false;
  String? _verificationSuccessMessage;
  String? _verificationErrorMessage;

  Future<void> _launchPancakeSwap() async {
    final uri = Uri.parse(pancakeSwapUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $pancakeSwapUrl');
    }
  }

  Future<void> _handleVerifyTx() async {
    final hash = _txHashController.text.trim();
    if (hash.isEmpty || !hash.startsWith('0x') || hash.length != 66) {
      setState(() {
        _verificationErrorMessage =
            'Please enter a valid 66-character BSC transaction hash (starts with 0x).';
        _verificationSuccessMessage = null;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationErrorMessage = null;
      _verificationSuccessMessage = null;
    });

    final res = await _apiClient.verifyTxHash(hash);

    if (!mounted) return;

    if (res['success'] == true) {
      final double amt = (res['data']?['amount'] as num?)?.toDouble() ?? 0.0;
      setState(() {
        _isVerifying = false;
        _verificationSuccessMessage =
            res['message'] ?? 'Transaction verified and balance credited!';
      });
      if (widget.onDepositConfirmed != null && amt > 0) {
        widget.onDepositConfirmed!(amt);
      }
    } else {
      setState(() {
        _isVerifying = false;
        _verificationErrorMessage =
            res['message'] ?? 'Verification failed on BNB Smart Chain.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF181A20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2B313A)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B313A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🥞', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PancakeSwap & JWC Deposit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEAECEF),
                          ),
                        ),
                        Text(
                          'BNB Smart Chain (BEP-20) Automatic Settlement',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF848E9C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF848E9C)),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF2B313A), height: 32),

              // PancakeSwap Direct Link Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2329),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2B313A)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Step 1: Buy JWC on PancakeSwap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEAECEF),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Swap BNB or USDT for JuwishCoin (JWC) directly via PancakeSwap DEX with deep on-chain liquidity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF848E9C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _launchPancakeSwap,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Open PancakeSwap Swap Desk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0B90B),
                        foregroundColor: const Color(0xFF181A20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // BEP-20 Token Address & QR Code
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: jwcContract,
                        version: QrVersions.auto,
                        size: 160.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'JWC BEP-20 Contract Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF848E9C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: SelectableText(
                            jwcContract,
                            style: const TextStyle(
                              color: Color(0xFFF0B90B),
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy,
                              size: 16, color: Color(0xFF848E9C)),
                          onPressed: () {
                            Clipboard.setData(
                                const ClipboardData(text: jwcContract));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contract address copied!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2B313A), height: 32),

              // Step 2: Verify Tx Hash
              const Text(
                'Step 2: Verify & Credit Transaction Hash',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEAECEF),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Paste your completed BSC transaction hash below to verify on-chain and credit your balance immediately:',
                style: TextStyle(fontSize: 12, color: Color(0xFF848E9C)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _txHashController,
                style: const TextStyle(
                  color: Color(0xFFEAECEF),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: '0x1234567890abcdef...',
                  hintStyle: const TextStyle(color: Color(0xFF5E6673)),
                  filled: true,
                  fillColor: const Color(0xFF2B313A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isVerifying ? null : _handleVerifyTx,
                  icon: _isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF181A20),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(_isVerifying
                      ? 'Verifying on BNB Chain...'
                      : 'Verify & Credit Balance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0ECB81),
                    foregroundColor: const Color(0xFF181A20),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Feedback alerts
              if (_verificationSuccessMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x260ECB81),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0ECB81)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF0ECB81), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _verificationSuccessMessage!,
                          style: const TextStyle(
                            color: Color(0xFF0ECB81),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_verificationErrorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x26F6465D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF6465D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFF6465D), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _verificationErrorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFF6465D),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
