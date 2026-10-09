import 'package:flutter/material.dart';
import 'models/license_model.dart';
import 'services/cleaninbox_license_service.dart';
import 'widgets/jwc_checkout_dialog.dart';

void main() {
  runApp(const CleanInboxDesktopApp());
}

class CleanInboxDesktopApp extends StatelessWidget {
  const CleanInboxDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanInbox Pro - Email Verification Suite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        cardColor: const Color(0xFF161922),
        primaryColor: const Color(0xFF3888FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3888FF),
          secondary: Color(0xFF1FC7D4),
          surface: Color(0xFF161922),
        ),
      ),
      home: const CleanInboxDashboardScreen(),
    );
  }
}

class CleanInboxDashboardScreen extends StatefulWidget {
  const CleanInboxDashboardScreen({super.key});

  @override
  State<CleanInboxDashboardScreen> createState() => _CleanInboxDashboardScreenState();
}

class _CleanInboxDashboardScreenState extends State<CleanInboxDashboardScreen> {
  final CleanInboxLicenseService _licenseService = CleanInboxLicenseService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13161F),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2333),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.mark_email_read, color: Color(0xFF3888FF), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'CleanInbox Pro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 16),
            ValueListenableBuilder<CleanInboxLicense?>(
              valueListenable: _licenseService.activeLicenseNotifier,
              builder: (context, license, _) {
                final isLicensed = license != null && !license.isExpired;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLicensed ? const Color(0xFF1B4332) : const Color(0xFF262C3D),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isLicensed ? const Color(0xFF2ECC71) : const Color(0xFF3E465B),
                    ),
                  ),
                  child: Text(
                    isLicensed ? 'TIER: ${license.tier.toUpperCase()}' : 'EVALUATION (50 / day)',
                    style: TextStyle(
                      color: isLicensed ? const Color(0xFF2ECC71) : const Color(0xFF8F9BB3),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                JwcCheckoutDialog.show(context);
              },
              icon: const Icon(Icons.rocket_launch, size: 16),
              label: const Text('Upgrade License (JWC / Crypto)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3888FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<CleanInboxLicense?>(
        valueListenable: _licenseService.activeLicenseNotifier,
        builder: (context, license, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLicenseOverviewBanner(license),
                const SizedBox(height: 24),
                const Text(
                  'Active Verification Engines & Quotas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.8,
                    children: [
                      _buildFeatureCard(
                        title: 'Daily Verification Limit',
                        value: '${_licenseService.dailyQuotaLimit} emails/day',
                        subtitle: license != null ? 'Unlocked via Ed25519 signature' : 'Limited in free evaluation mode',
                        icon: Icons.speed,
                        accentColor: const Color(0xFF3888FF),
                      ),
                      _buildFeatureCard(
                        title: 'SMTP Deep Handshake',
                        value: license != null ? 'Full Unlocked (Zero Greylisting)' : 'Basic Single Thread',
                        subtitle: 'Socket simulation without sending mail',
                        icon: Icons.dns,
                        accentColor: const Color(0xFF1FC7D4),
                      ),
                      _buildFeatureCard(
                        title: 'Spam-Trap Neural Filter',
                        value: license != null ? 'Enterprise Heuristics Enabled' : 'Disabled',
                        subtitle: 'Honeypot domain & MX trap detection',
                        icon: Icons.security,
                        accentColor: const Color(0xFFF3BA2F),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLicenseOverviewBanner(CleanInboxLicense? license) {
    if (license == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF283044)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFF3BA2F), size: 28),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are using CleanInbox Pro in Evaluation Mode',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pay with JuwishCoin (JWC) on BNB Smart Chain to unlock 500, 2,000, or 5,000 daily checks instantly with Ed25519 offline signed licenses.',
                    style: TextStyle(color: Color(0xFF8F9BB3), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => JwcCheckoutDialog.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1FC7D4),
                foregroundColor: Colors.black,
              ),
              child: const Text('Upgrade with JWC', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF14241B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2ECC71)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Color(0xFF2ECC71), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${license.tierDisplayName} Active',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'License: ${license.licenseId} • Settled on BSC: ${license.paymentTx.substring(0, 14)}... • Quota: ${license.dailyLimit}/day',
                  style: const TextStyle(color: Color(0xFF94D2BD), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Reset to Free Mode (Testing)',
            onPressed: () => _licenseService.clearLicense(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262C3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Color(0xFF8F9BB3), fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

