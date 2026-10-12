import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';
import '../../blocs/auth_bloc.dart';

class KycScreen extends StatefulWidget {
  final AuthBloc authBloc;

  const KycScreen({super.key, required this.authBloc});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'JuwishPro Trader');
  final TextEditingController _idNumberController =
      TextEditingController(text: 'P-98421092');
  String _selectedIdType = 'Passport';
  bool _documentFrontAttached = true;
  bool _documentBackAttached = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  void _submitKyc() async {
    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final success = await widget.authBloc.submitKyc(
      fullName: _nameController.text.trim(),
      idType: _selectedIdType,
      idNumber: _idNumberController.text.trim(),
      documentFilePath: 'simulated_kyc_document.jpg',
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'KYC documents submitted successfully! Status: Approved (Level 2 Institutional)'),
            backgroundColor: AppTheme.greenBullish,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      appBar: AppBar(
        title: const Text('Identity & KYC Verification'),
        backgroundColor: AppTheme.nightObsidian,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.greenBullish,
                    child: Icon(Icons.verified_user,
                        color: AppTheme.nightObsidian, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KYC Tier 2 Institutional',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Daily withdrawal limit: \$5,000,000 • Full futures leverage unlocked',
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

            // Form container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Legal Information',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Full Legal Name (as on passport)',
                      labelStyle:
                          const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.nightObsidian,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppTheme.borderHighlight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedIdType,
                    dropdownColor: AppTheme.surfaceCharcoal,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Government ID Document Type',
                      labelStyle:
                          const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.nightObsidian,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppTheme.borderHighlight),
                      ),
                    ),
                    items: [
                      'Passport',
                      'National Identity Card',
                      "Driver's License"
                    ].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedIdType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _idNumberController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Document Serial / ID Number',
                      labelStyle:
                          const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.nightObsidian,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppTheme.borderHighlight),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Document Upload Attachments
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Document Photos & Biometric Scan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.nightObsidian,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _documentFrontAttached
                                    ? AppTheme.greenBullish
                                    : AppTheme.borderHighlight),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.badge,
                                  color: _documentFrontAttached
                                      ? AppTheme.greenBullish
                                      : AppTheme.textSecondary,
                                  size: 32),
                              const SizedBox(height: 8),
                              const Text('Front Side',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                  _documentFrontAttached
                                      ? 'Attached ✓'
                                      : 'Tap to Upload',
                                  style: TextStyle(
                                      color: _documentFrontAttached
                                          ? AppTheme.greenBullish
                                          : AppTheme.textSecondary,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.nightObsidian,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _documentBackAttached
                                    ? AppTheme.greenBullish
                                    : AppTheme.borderHighlight),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.flip_to_back,
                                  color: _documentBackAttached
                                      ? AppTheme.greenBullish
                                      : AppTheme.textSecondary,
                                  size: 32),
                              const SizedBox(height: 8),
                              const Text('Back / Signature',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                  _documentBackAttached
                                      ? 'Attached ✓'
                                      : 'Tap to Upload',
                                  style: TextStyle(
                                      color: _documentBackAttached
                                          ? AppTheme.greenBullish
                                          : AppTheme.textSecondary,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                onPressed: _isSubmitting ? null : _submitKyc,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.nightObsidian))
                    : const Text('Submit KYC Verification',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
