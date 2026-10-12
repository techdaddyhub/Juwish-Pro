import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/biometric_helper.dart';
import '../../../theme/app_theme.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  bool _biometricsEnabled = true;
  bool _twoFactorEnabled = true;
  bool _requireBioOnTrading = true;
  String _autoLockInterval = 'Immediately on background';

  void _testBiometrics() async {
    HapticFeedback.mediumImpact();
    final authenticated = await BiometricHelper.authenticateWithBiometrics(
      promptMessage: 'Authenticate with FaceID or Fingerprint sensor',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authenticated
              ? 'Biometric authentication successful!'
              : 'Authentication cancelled or failed'),
          backgroundColor:
              authenticated ? AppTheme.greenBullish : AppTheme.redBearish,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      appBar: AppBar(
        title: const Text('Security & Biometrics'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.nightObsidian,
                    child:
                        Icon(Icons.fingerprint, color: AppTheme.gold, size: 30),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hardware Security Enclave',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Biometric credentials remain in secure device hardware (Android Keystore / iOS Secure Enclave).',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings toggles
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: Column(
                children: [
                  _buildToggleRow(
                    'Biometric App Unlock',
                    'Unlock JuwishPro with FaceID or Fingerprint',
                    _biometricsEnabled,
                    (val) => setState(() => _biometricsEnabled = val),
                  ),
                  const Divider(color: AppTheme.borderHighlight),
                  _buildToggleRow(
                    'Trade Execution Confirmation',
                    'Require biometric scan before opening large orders',
                    _requireBioOnTrading,
                    (val) => setState(() => _requireBioOnTrading = val),
                  ),
                  const Divider(color: AppTheme.borderHighlight),
                  _buildToggleRow(
                    'Two-Factor Authentication (2FA)',
                    'Google Authenticator / TOTP on withdrawals',
                    _twoFactorEnabled,
                    (val) => setState(() => _twoFactorEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Test Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.gold),
                  foregroundColor: AppTheme.gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.fingerprint),
                label: const Text('Test Biometric Hardware Sensor',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: _testBiometrics,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppTheme.gold,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
