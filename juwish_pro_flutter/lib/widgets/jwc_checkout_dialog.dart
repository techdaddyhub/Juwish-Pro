import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/checkout_order.dart';
import '../models/license_model.dart';
import '../services/cleaninbox_license_service.dart';
import '../services/crypto_payment_client.dart';
import 'transaction_status_stepper.dart';

/// CleanInbox Pro - JuwishCoin (JWC) BEP-20 Checkout & Licensing Dialog
class JwcCheckoutDialog extends StatefulWidget {
  final String initialTier;
  final String initialDuration;
  final String customerEmail;
  final CryptoPaymentClient? apiClient;
  final ValueChanged<CleanInboxLicense>? onLicenseActivated;

  const JwcCheckoutDialog({
    super.key,
    this.initialTier = 'pro',
    this.initialDuration = '1_month',
    this.customerEmail = 'user@example.com',
    this.apiClient,
    this.onLicenseActivated,
  });

  /// Static helper to display the modal dialog on desktop
  static Future<CleanInboxLicense?> show(
    BuildContext context, {
    String initialTier = 'pro',
    String initialDuration = '1_month',
    String customerEmail = 'user@example.com',
  }) {
    return showDialog<CleanInboxLicense>(
      context: context,
      barrierDismissible: false,
      builder: (context) => JwcCheckoutDialog(
        initialTier: initialTier,
        initialDuration: initialDuration,
        customerEmail: customerEmail,
      ),
    );
  }

  @override
  State<JwcCheckoutDialog> createState() => _JwcCheckoutDialogState();
}

class _JwcCheckoutDialogState extends State<JwcCheckoutDialog> {
  late CryptoPaymentClient _apiClient;
  late String _selectedTier;
  late String _selectedDuration;

  CheckoutInvoice? _invoice;
  PaymentStatus _paymentStatus = PaymentStatus.idle;
  int _currentConfirmations = 0;
  String? _detectedTxHash;
  CleanInboxLicense? _issuedLicense;

  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(minutes: 15);
  StreamSubscription? _sseSubscription;

  final TextEditingController _txHashController = TextEditingController();
  bool _isVerifyingManualTx = false;
  String? _manualTxErrorMessage;

  @override
  void initState() {
    super.initState();
    _selectedTier = widget.initialTier;
    _selectedDuration = widget.initialDuration;
    _apiClient = widget.apiClient ?? CryptoPaymentClient();

    _initializeInvoice();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _sseSubscription?.cancel();
    _txHashController.dispose();
    super.dispose();
  }

  /// Fetches real-time price & invoice from backend oracle
  Future<void> _initializeInvoice() async {
    setState(() {
      _paymentStatus = PaymentStatus.creatingInvoice;
    });

    try {
      final invoice = await _apiClient.createInvoice(
        tier: _selectedTier,
        duration: _selectedDuration,
        customerEmail: widget.customerEmail,
      );

      if (!mounted) return;

      setState(() {
        _invoice = invoice;
        _remainingTime = invoice.remainingTime;
        _paymentStatus = PaymentStatus.awaitingPayment;
      });

      _startCountdownTimer();
      _subscribeToRealtimeEvents(invoice.orderId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paymentStatus = PaymentStatus.error;
      });
    }
  }

  /// Starts 15-minute invoice expiration timer
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _paymentStatus = PaymentStatus.expired;
          timer.cancel();
        }
      });
    });
  }

  /// Connects to real-time blockchain event stream
  void _subscribeToRealtimeEvents(String orderId) {
    _sseSubscription?.cancel();
    _sseSubscription = _apiClient.listenToOrderStream(orderId).listen((event) {
      final eventType = event['_event'] ?? '';
      if (!mounted) return;

      if (eventType == 'payment_detected') {
        setState(() {
          _paymentStatus = PaymentStatus.txDetected;
          _detectedTxHash = event['txHash'];
        });
      } else if (eventType == 'confirmations_updated') {
        setState(() {
          _paymentStatus = PaymentStatus.confirming;
          _currentConfirmations = event['confirmations'] ?? 0;
          _detectedTxHash = event['txHash'];
        });
      } else if (eventType == 'license_issued' ||
          eventType == 'payment_confirmed') {
        final licenseMap = event['license'] as Map<String, dynamic>?;
        if (licenseMap != null) {
          final license = CleanInboxLicense.fromJson(licenseMap);
          _onPaymentComplete(license);
        }
      }
    });
  }

  /// Manual verification button handler
  Future<void> _handleManualTxVerification() async {
    final txHash = _txHashController.text.trim();
    if (txHash.isEmpty || _invoice == null) return;

    setState(() {
      _isVerifyingManualTx = true;
      _manualTxErrorMessage = null;
    });

    try {
      final result = await _apiClient.verifyTxHash(
        orderId: _invoice!.orderId,
        txHash: txHash,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        if (result['status'] == 'confirmed') {
          final license = CleanInboxLicense.fromJson(result['license']);
          _onPaymentComplete(license);
        } else if (result['status'] == 'confirming') {
          setState(() {
            _paymentStatus = PaymentStatus.confirming;
            _currentConfirmations = result['confirmations'] ?? 0;
            _detectedTxHash = txHash;
            _manualTxErrorMessage = null;
          });
        }
      } else {
        setState(() {
          _manualTxErrorMessage =
              result['message'] ?? 'Transaction could not be verified.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _manualTxErrorMessage = 'Verification error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingManualTx = false;
        });
      }
    }
  }

  /// Activates software features immediately without app restart
  void _onPaymentComplete(CleanInboxLicense license) {
    setState(() {
      _paymentStatus = PaymentStatus.confirmed;
      _currentConfirmations = 15;
      _issuedLicense = license;
    });

    _countdownTimer?.cancel();
    _sseSubscription?.cancel();

    // 🚀 Instant in-memory unlock of desktop application
    CleanInboxLicenseService.instance.activateLicense(license);
    widget.onLicenseActivated?.call(license);
  }

  /// Opens PancakeSwap deep link directly in default browser
  Future<void> _openPancakeSwapDirectSwap() async {
    final url = _invoice?.pancakeSwapDeepLink ??
        'https://pancakeswap.finance/swap?outputCurrency=0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99&chainId=56';

    final uri = Uri.parse(url);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('[Checkout] Error launching PancakeSwap: $e');
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1E222D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF13161F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF262C3D)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
        child:
            _issuedLicense != null ? _buildSuccessView() : _buildCheckoutView(),
      ),
    );
  }

  Widget _buildCheckoutView() {
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 1, color: Color(0xFF262C3D)),
        Expanded(
          child: _paymentStatus == PaymentStatus.creatingInvoice
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF3888FF)),
                      SizedBox(height: 16),
                      Text('Fetching live PancakeSwap pool rates...',
                          style: TextStyle(color: Color(0xFF8F9BB3))),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTierAndDurationSelectors(),
                      const SizedBox(height: 20),
                      _buildPricingAndPancakeSwapCta(),
                      const SizedBox(height: 20),
                      _buildQrAndTreasurySection(),
                      const SizedBox(height: 20),
                      TransactionStatusStepper(
                        status: _paymentStatus,
                        currentConfirmations: _currentConfirmations,
                        requiredConfirmations:
                            _invoice?.requiredConfirmations ?? 15,
                        txHash: _detectedTxHash,
                      ),
                      const SizedBox(height: 20),
                      _buildManualTxInput(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2333),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: Color(0xFF3888FF), size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CleanInbox Pro Licensing Upgrade',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Instant activation via JuwishCoin (JWC) on BNB Smart Chain',
                style: TextStyle(color: Color(0xFF8F9BB3), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          _buildCountdownBadge(),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF8F9BB3)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBadge() {
    final minutes = _remainingTime.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    final isLowTime = _remainingTime.inMinutes < 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLowTime ? const Color(0xFF3E1F1F) : const Color(0xFF1E2333),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color:
                isLowTime ? const Color(0xFFE74C3C) : const Color(0xFF2C3242)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined,
              size: 14,
              color: isLowTime ? const Color(0xFFE74C3C) : Colors.white70),
          const SizedBox(width: 6),
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              color: isLowTime ? const Color(0xFFE74C3C) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierAndDurationSelectors() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. SELECT TIER',
                  style: TextStyle(
                      color: Color(0xFF8F9BB3),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTierPill('starter', 'Starter', '500/day'),
                  const SizedBox(width: 8),
                  _buildTierPill('pro', 'Pro', '2,000/day'),
                  const SizedBox(width: 8),
                  _buildTierPill('enterprise', 'Enterprise', '5,000/day'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('2. DURATION',
                style: TextStyle(
                    color: Color(0xFF8F9BB3),
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDurationPill('1_week', '1 Wk'),
                const SizedBox(width: 6),
                _buildDurationPill('2_weeks', '2 Wks'),
                const SizedBox(width: 6),
                _buildDurationPill('1_month', '1 Mo'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTierPill(String id, String label, String quota) {
    final isSelected = _selectedTier == id;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_selectedTier != id) {
            setState(() => _selectedTier = id);
            _initializeInvoice();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1B1E29),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3888FF)
                  : const Color(0xFF2C3242),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFB0B7C3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                quota,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFF6B7280),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPill(String id, String label) {
    final isSelected = _selectedDuration == id;
    return InkWell(
      onTap: () {
        if (_selectedDuration != id) {
          setState(() => _selectedDuration = id);
          _initializeInvoice();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1B1E29),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF3888FF) : const Color(0xFF2C3242),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFB0B7C3),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPricingAndPancakeSwapCta() {
    final inv = _invoice;
    final usdPrice = inv?.priceUsd ?? 49.0;
    final jwcAmount = inv?.formattedJwc ?? '... JWC';
    final jwcRate = inv?.jwcPriceUsd ?? 0.05;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF283044)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PAYMENT DUE',
                  style: TextStyle(
                      color: Color(0xFF8F9BB3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    jwcAmount,
                    style: const TextStyle(
                      color: Color(0xFFF3BA2F), // BNB Gold Accent
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(\$${usdPrice.toStringAsFixed(2)} USD)',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Live Rate: 1 JWC ≈ \$${jwcRate.toStringAsFixed(4)} USD • PancakeSwap V2/V3 BSC',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          // 🥞 Prominent CTA: Buy JWC on PancakeSwap
          ElevatedButton.icon(
            onPressed: _openPancakeSwapDirectSwap,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text(
              'Buy JWC on PancakeSwap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1FC7D4), // PancakeSwap Cyan
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrAndTreasurySection() {
    final inv = _invoice;
    final treasury =
        inv?.treasuryAddress ?? '0x4989eF673628E1E55E2d0577F14e5bF0aCce6381';
    final tokenContract =
        inv?.contractAddress ?? '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99';
    final qrData = inv?.toWalletQrUri() ?? treasury;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verified BEP-20 QR Code
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 130,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        // Deposit address and copy tools
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3BA2F).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BNB SMART CHAIN (BEP-20)',
                      style: TextStyle(
                          color: Color(0xFFF3BA2F),
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Direct Deposit Address',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2333),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2C3242)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        treasury,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy,
                          size: 16, color: Color(0xFF3888FF)),
                      tooltip: 'Copy Treasury Address',
                      onPressed: () =>
                          _copyToClipboard(treasury, 'Treasury Address'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Token Contract: ',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
                  SelectableText(
                    '${tokenContract.substring(0, 10)}...${tokenContract.substring(tokenContract.length - 8)}',
                    style: const TextStyle(
                        color: Color(0xFF93C5FD),
                        fontSize: 10,
                        fontFamily: 'monospace'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy,
                        size: 12, color: Color(0xFF6B7280)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        _copyToClipboard(tokenContract, 'Contract Address'),
                  ),
                  const Spacer(),
                  const Icon(Icons.verified,
                      size: 14, color: Color(0xFF2ECC71)),
                  const SizedBox(width: 4),
                  const Text('Verified BEP-20',
                      style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualTxInput() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181B26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF252B3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Already sent? Verify BSC Transaction Hash manually:',
            style: TextStyle(
                color: Color(0xFFB0B7C3),
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _txHashController,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: 'Enter 0x... BSC Transaction Hash',
                    hintStyle:
                        const TextStyle(color: Color(0xFF4B5563), fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF13161F),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2C3242)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2C3242)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed:
                    _isVerifyingManualTx ? null : _handleManualTxVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3888FF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isVerifyingManualTx
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Verify On-Chain',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          if (_manualTxErrorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _manualTxErrorMessage!,
              style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 11),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final license = _issuedLicense!;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFF1B4332),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Color(0xFF2ECC71), size: 42),
          ),
          const SizedBox(height: 18),
          const Text(
            'Payment Confirmed on BSC!',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Software features for ${license.tierDisplayName} are now unlocked immediately.',
            style: const TextStyle(color: Color(0xFF8F9BB3), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E222D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2C3242)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLicenseRow('License Key', license.licenseId),
                _buildLicenseRow(
                    'Daily Quota', '${license.dailyLimit} verifications/day'),
                _buildLicenseRow(
                    'Valid Until', '${license.expiresAt.toLocal()}'),
                _buildLicenseRow('Settlement Tx',
                    '${license.paymentTx.substring(0, 16)}...'),
                _buildLicenseRow('Signature',
                    '${license.signature.substring(0, 24)}... (Ed25519)'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _copyToClipboard(license.exportJson(), 'License Document');
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy License File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF3888FF)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(license),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Start Using CleanInbox Pro',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLicenseRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF8F9BB3), fontSize: 12)),
          SelectableText(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
