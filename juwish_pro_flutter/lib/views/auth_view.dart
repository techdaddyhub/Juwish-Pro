import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_account.dart';
import '../services/laravel_api_service.dart';
import '../theme/app_theme.dart';

class AuthView extends StatefulWidget {
  final UserAccount currentUser;
  final ValueChanged<UserAccount>? onUserUpdated;

  const AuthView({
    super.key,
    required this.currentUser,
    this.onUserUpdated,
  });

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LaravelApiService _api = LaravelApiService();

  // Login form
  final TextEditingController _loginEmail =
      TextEditingController(text: 'admin@juwish.pro');
  final TextEditingController _loginPassword =
      TextEditingController(text: '••••••••');

  // Register form
  final TextEditingController _regFirst = TextEditingController();
  final TextEditingController _regLast = TextEditingController();
  final TextEditingController _regEmail = TextEditingController();
  final TextEditingController _regPassword = TextEditingController();

  // KYC form
  final TextEditingController _kycName =
      TextEditingController(text: 'Admin JuwishPro');
  final TextEditingController _kycIdNumber =
      TextEditingController(text: 'IL-94821048');
  String _kycIdType = 'Passport';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regFirst.dispose();
    _regLast.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    _kycName.dispose();
    _kycIdNumber.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    await _api.login(
      email: _loginEmail.text,
      password: _loginPassword.text,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      widget.onUserUpdated?.call(UserAccount.mockAdmin());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.gainGreen,
          content: Text(
              'Successfully authenticated with 2026.dmillers.org session!'),
        ),
      );
    }
  }

  Future<void> _submitKyc() async {
    setState(() => _isLoading = true);
    final success = await _api.submitKyc(
      fullName: _kycName.text,
      idType: _kycIdType,
      idNumber: _kycIdNumber.text,
    );
    setState(() => _isLoading = false);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.gold,
          content: Text(
            'KYC documents submitted to 2026.dmillers.org compliance engine (Approved)!',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Future<void> _launchAdminConsole() async {
    final uri = Uri.parse('https://2026.dmillers.org/admin/login');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with User Summary & Admin link
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.gold),
                    ),
                    child: Center(
                      child: Text(
                        widget.currentUser.firstName.isNotEmpty
                            ? widget.currentUser.firstName[0].toUpperCase()
                            : '✡',
                        style: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentUser.fullName,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          widget.currentUser.email,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.gainGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('KYC Verified',
                                  style: TextStyle(
                                      color: AppTheme.gainGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text('2FA Active',
                                style: TextStyle(
                                    color: AppTheme.gold, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Open cPanel Admin Portal',
                    icon: const Icon(Icons.open_in_new, color: AppTheme.gold),
                    onPressed: _launchAdminConsole,
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.gold,
              labelColor: AppTheme.gold,
              unselectedLabelColor: AppTheme.textSecondary,
              tabs: const [
                Tab(text: 'Sign In'),
                Tab(text: 'Register'),
                Tab(text: 'KYC Verification'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Login
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _loginEmail,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _loginPassword,
                          obscureText: true,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppTheme.textSecondary),
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
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : const Text('Sign In to JuwishPro',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _launchAdminConsole,
                          child: const Text(
                              'Access Admin Control Panel (2026.dmillers.org)',
                              style: TextStyle(
                                  color: AppTheme.gold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Register
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _regFirst,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _regLast,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _regEmail,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _regPassword,
                          obscureText: true,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Create Password',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppTheme.gainGreen,
                                  content: Text(
                                      'Account registered on 2026.dmillers.org! Please verify email.'),
                                ),
                              );
                            },
                            child: const Text('Create Account',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 3: KYC Verification
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Identity Verification (Tier 2)',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Verify identity to unlock unlimited JuwishCoin & Fiat withdrawals on 2026.dmillers.org',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _kycName,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Full Legal Name',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _kycIdType,
                              isExpanded: true,
                              dropdownColor: AppTheme.surfaceDark,
                              style:
                                  const TextStyle(color: AppTheme.textPrimary),
                              items: [
                                'Passport',
                                'National ID Card',
                                "Driver's License"
                              ].map((type) {
                                return DropdownMenuItem(
                                    value: type, child: Text(type));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _kycIdType = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _kycIdNumber,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Document ID Number',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
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
                            onPressed: _isLoading ? null : _submitKyc,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : const Text('Submit KYC Verification',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
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
