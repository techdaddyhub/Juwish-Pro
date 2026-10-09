import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/checkout_order.dart';

/// Client gateway communicating with CleanInbox Pro backend verification service
class CryptoPaymentClient {
  final String baseUrl;
  http.Client? _client;

  CryptoPaymentClient({this.baseUrl = 'http://localhost:3000'});

  http.Client get client => _client ??= http.Client();

  /// Requests a fresh BSC checkout invoice with dynamic PancakeSwap pricing
  Future<CheckoutInvoice> createInvoice({
    required String tier,
    required String duration,
    String customerId = 'CIP-DESKTOP-APP',
    String customerEmail = 'support@cleaninboxpro.com',
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/checkout/create-invoice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tier': tier,
          'duration': duration,
          'customerId': customerId,
          'customerEmail': customerEmail,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CheckoutInvoice.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      // Local fallback calculation if backend is booting or in offline demo mode
      return _generateOfflineFallbackInvoice(tier, duration);
    }
  }

  /// Manually submits BSC Transaction Hash for verification
  Future<Map<String, dynamic>> verifyTxHash({
    required String orderId,
    required String txHash,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/checkout/verify-tx'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'txHash': txHash.trim(),
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      // If backend unreachable, return informative error
      return {
        'success': false,
        'status': 'network_error',
        'message': 'Unable to connect to verification node: $e',
      };
    }
  }

  /// Streams real-time blockchain confirmation events via Server-Sent Events (SSE)
  Stream<Map<String, dynamic>> listenToOrderStream(String orderId) async* {
    final uri = Uri.parse('$baseUrl/api/checkout/stream/$orderId');
    final request = http.Request('GET', uri);
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    try {
      final response = await client.send(request);
      String currentEvent = 'message';

      await for (final line in response.stream.toStringStream().transform(const LineSplitter())) {
        if (line.startsWith('event: ')) {
          currentEvent = line.substring(7).trim();
        } else if (line.startsWith('data: ')) {
          final rawData = line.substring(6).trim();
          try {
            final parsed = jsonDecode(rawData) as Map<String, dynamic>;
            parsed['_event'] = currentEvent;
            yield parsed;
          } catch (_) {}
        }
      }
    } catch (e) {
      // Stream closed or error
    }
  }

  /// Fallback invoice generator when developing or testing offline
  CheckoutInvoice _generateOfflineFallbackInvoice(String tier, String duration) {
    double usd = 49.0;
    int limit = 2000;
    if (tier == 'starter') {
      usd = 19.0;
      limit = 500;
    } else if (tier == 'enterprise') {
      usd = 129.0;
      limit = 5000;
    }

    const double jwcRate = 0.05; // $0.05 per JWC
    final double jwcTokens = usd / jwcRate;

    return CheckoutInvoice(
      orderId: 'ORD-DEMO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      tier: tier,
      duration: duration,
      dailyLimit: limit,
      priceUsd: usd,
      expectedJwcAmount: jwcTokens,
      formattedJwc: '${jwcTokens.toStringAsFixed(2)} JWC',
      jwcPriceUsd: jwcRate,
      treasuryAddress: '0x4989eF673628E1E55E2d0577F14e5bF0aCce6381',
      contractAddress: '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99',
      chainId: 56,
      pancakeSwapDeepLink: 'https://pancakeswap.finance/swap?outputCurrency=0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99&chainId=56',
      requiredConfirmations: 15,
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  void dispose() {
    _client?.close();
  }
}
