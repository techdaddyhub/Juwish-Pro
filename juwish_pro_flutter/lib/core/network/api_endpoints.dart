class ApiEndpoints {
  static const String baseUrl = 'https://2026.dmillers.org';
  static const String baseApiUrl = '$baseUrl/api/v1';

  // Mobile Sync Endpoints
  static const String syncInfo = '$baseApiUrl/mobile/sync-info';
  static const String plans = '$baseApiUrl/mobile/plans';
  static const String tickers = '$baseApiUrl/mobile/tickers';

  // Webhook / Payments
  static const String nowpaymentDeposit =
      '$baseApiUrl/webhooks/nowpayments/deposit';
  static const String nowpaymentWithdrawal =
      '$baseApiUrl/webhooks/nowpayments/withdrawal';

  // Auth & User Portal
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String userDashboard = '$baseUrl/user/dashboard';
  static const String userKyc = '$baseUrl/user/kyc';
  static const String userDeposits = '$baseUrl/user/deposits';
  static const String userWithdrawals = '$baseUrl/user/withdrawals';
  static const String userInvestments = '$baseUrl/user/investments';

  // Trading & Sectors
  static const String futuresTrading = '$baseUrl/trading/futures';
  static const String marginTrading = '$baseUrl/trading/margin';
  static const String forexTrading = '$baseUrl/trading/forex';
  static const String stocks = '$baseUrl/capital-instruments/stocks';
  static const String bonds = '$baseUrl/capital-instruments/bonds';
  static const String etfs = '$baseUrl/capital-instruments/etfs';
  static const String mutualFunds = '$baseUrl/capital-instruments/mutual-funds';

  // Admin Portal
  static const String adminDashboard = '$baseUrl/admin/dashboard';
}
