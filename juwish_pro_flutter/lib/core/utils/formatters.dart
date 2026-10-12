class AppFormatters {
  static String formatUsd(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 100000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }

  static String formatJwc(double amount) {
    return '${amount.toStringAsFixed(2)} JWC';
  }

  static String formatPercentage(double percent) {
    final prefix = percent >= 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(2)}%';
  }

  static String formatPercent(double percent) => formatPercentage(percent);

  static String formatCrypto(double amount, String symbol) {
    if (amount < 0.0001) {
      return '${amount.toStringAsFixed(8)} $symbol';
    } else if (amount < 1.0) {
      return '${amount.toStringAsFixed(4)} $symbol';
    } else {
      return '${amount.toStringAsFixed(2)} $symbol';
    }
  }

  static String formatAddress(String address, {int head = 6, int tail = 4}) {
    if (address.length <= head + tail) return address;
    return '${address.substring(0, head)}...${address.substring(address.length - tail)}';
  }

  static String shortenAddress(String address, {int head = 6, int tail = 4}) =>
      formatAddress(address, head: head, tail: tail);
}

// Backward compatibility alias
typedef Formatters = AppFormatters;
