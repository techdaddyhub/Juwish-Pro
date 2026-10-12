import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/validators.dart';
import '../../../theme/app_theme.dart';
import '../../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  final AuthBloc authBloc;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.authBloc,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: 'admin@admin.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password');
  bool _obscurePassword = true;
  bool _isRegistering = false;
  final TextEditingController _nameController =
      TextEditingController(text: 'JuwishPro Trader');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    if (!AppValidators.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: AppTheme.redBearish),
      );
      return;
    }

    if (pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your password'),
            backgroundColor: AppTheme.redBearish),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final success = await widget.authBloc.login(email, pass);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${widget.authBloc.state.user?.name}!'),
          backgroundColor: AppTheme.greenBullish,
        ),
      );
      widget.onLoginSuccess();
    }
  }

  void _biometricLogin() async {
    final success = await widget.authBloc.authenticateWithBiometrics();
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Biometric verification successful!'),
            backgroundColor: AppTheme.greenBullish),
      );
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // JuwishPro official Gold Medallion Logo
                Image.asset(
                  'assets/images/logo-square.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.stars, color: AppTheme.gold, size: 80),
                ),
                const SizedBox(height: 16),
                const Text(
                  'JuwishPro Exchange',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Institutional Crypto, Stocks & Wealth Platform',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),

                // Card container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCharcoal,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderHighlight),
                  ),
                  child: Column(
                    children: [
                      if (_isRegistering) ...[
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle:
                                const TextStyle(color: AppTheme.textSecondary),
                            prefixIcon:
                                const Icon(Icons.person, color: AppTheme.gold),
                            filled: true,
                            fillColor: AppTheme.nightObsidian,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppTheme.borderHighlight),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle:
                              const TextStyle(color: AppTheme.textSecondary),
                          prefixIcon:
                              const Icon(Icons.email, color: AppTheme.gold),
                          filled: true,
                          fillColor: AppTheme.nightObsidian,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.borderHighlight),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle:
                              const TextStyle(color: AppTheme.textSecondary),
                          prefixIcon:
                              const Icon(Icons.lock, color: AppTheme.gold),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: AppTheme.nightObsidian,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.borderHighlight),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit button
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
                          onPressed: _submit,
                          child: Text(
                            _isRegistering
                                ? 'Create Account'
                                : 'Sign In to JuwishPro',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Biometric button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.gold),
                            foregroundColor: AppTheme.gold,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Unlock with FaceID / Biometrics',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _biometricLogin,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Toggle Login / Register
                TextButton(
                  onPressed: () =>
                      setState(() => _isRegistering = !_isRegistering),
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Sign In'
                        : 'New to JuwishPro? Create an Account',
                    style: const TextStyle(
                        color: AppTheme.gold, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 12),

                // Backend Sync Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCharcoal,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderHighlight),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_done,
                          color: AppTheme.greenBullish, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Synced with 2026.dmillers.org Sanctum API',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
