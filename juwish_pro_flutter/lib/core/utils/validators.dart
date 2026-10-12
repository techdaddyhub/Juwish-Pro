class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive amount';
    }
    if (min != null && parsed < min) {
      return 'Minimum amount is $min';
    }
    if (max != null && parsed > max) {
      return 'Maximum amount is $max';
    }
    return null;
  }

  static String? validateCryptoAddress(String? value, String network) {
    if (value == null || value.trim().isEmpty) {
      return 'Wallet address is required';
    }
    final trimmed = value.trim();
    if (network.contains('BEP-20') || network.contains('ERC-20')) {
      if (!RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(trimmed)) {
        return 'Invalid EVM/BSC address (must start with 0x and be 42 chars)';
      }
    } else if (network.contains('TRC-20')) {
      if (!trimmed.startsWith('T') || trimmed.length != 34) {
        return 'Invalid Tron TRC-20 address';
      }
    }
    return null;
  }

  static bool isValidEmail(String email) => validateEmail(email) == null;
}

// Backward compatibility alias
typedef AppValidators = Validators;
