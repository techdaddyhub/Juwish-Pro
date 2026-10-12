import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/checkout_order.dart';

/// Client gateway communicating with JuwishPro live backend
class CryptoPaymentClient {
  final String baseUrl;
  http.Client? _client;

  CryptoPaymentClient({this.baseUrl = 'https://2026.dmillers.org'});

  http.Client get client => _client ??= http.Client();

  /// Fetches PancakeSwap token specifications and routing
  Future<Map<String, dynamic>> getPancakeSwapInfo() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/pancakeswap-info'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {
      'success': true,
      'data': {
        'token_symbol': 'JWC',
        'token_contract': '0xfeeef79d2a97d9e1f9bcb8eba8fd9587079c9e99',
        'chain_id': 56,
        'pancakeswap_url':
            'https://pancakeswap.finance/swap?outputCurrency=0xfeeef79d2a97d9e1f9bcb8eba8fd9587079c9e99&chainId=56',
        'current_price_usd': 0.05,
      }
    };
  }

  /// Verifies on-chain BNB Smart Chain transaction hash and credits balance automatically
  Future<Map<String, dynamic>> verifyTxHash(String txHash) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/verify-pancakeswap-deposit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'tx_hash': txHash.trim()}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to reach verification gateway: $e'
      };
    }
  }

  /// Create local invoice for QR and checkout display
  Future<CheckoutInvoice> createInvoice({double amount = 1000.0}) async {
    return CheckoutInvoice.defaultJwc(amount: amount);
  }
}
