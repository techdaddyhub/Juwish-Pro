import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'widgets/jwc_checkout_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JuwishProApp());
}

class JuwishProApp extends StatelessWidget {
  const JuwishProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JuwishPro - User Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0E11), // Binance Deep Dark
        cardColor: const Color(0xFF181A20), // Binance Surface Card
        primaryColor: const Color(0xFFF0B90B), // Binance Yellow
        dividerColor: const Color(0xFF2B313A), // Binance Border
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF0B90B),
          secondary: Color(0xFFFCD535),
          surface: Color(0xFF181A20),
        ),
      ),
      home: const JuwishProPortalScreen(),
    );
  }
}

class JuwishProPortalScreen extends StatefulWidget {
  const JuwishProPortalScreen({super.key});

  @override
  State<JuwishProPortalScreen> createState() => _JuwishProPortalScreenState();
}

class _JuwishProPortalScreenState extends State<JuwishProPortalScreen> {
  static const String userPortalUrl =
      'https://techdaddyhub.github.io/Juwish-Pro';
  static const String jwcContract =
      '0xfEEEF79d2A97d9e1f9bcB8eBA8FD9587079C9e99';
  static const String pancakeSwapUrl =
      'https://pancakeswap.finance/swap?outputCurrency=$jwcContract&chainId=56';

  WebViewController? _webViewController;
  bool _isLoading = true;
  int _loadingProgress = 0;
  bool _hasError = false;
  String? _errorMessage;

  bool get _isMobileOrMac {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  @override
  void initState() {
    super.initState();
    if (_isMobileOrMac) {
      _initWebView();
    }
  }

  void _initWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B0E11))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
                if (progress == 100) {
                  _isLoading = false;
                }
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadingProgress = 100;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only report main frame errors
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // Restrict admin portal routes - app is for user portal alone
            if ((url.contains('/admin') || url.contains('2026.dmillers.org')) &&
                !url.contains('/api/') &&
                !url.contains('/assets/')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Admin Portal is restricted to administrative browsers. Mobile app is synchronized with User Portal alone.'),
                  backgroundColor: Color(0xFFF6465D),
                  duration: Duration(seconds: 3),
                ),
              );
              return NavigationDecision.prevent;
            }

            // Launch PancakeSwap and BscScan in external browser/wallet
            if (url.contains('pancakeswap.finance') ||
                url.contains('bscscan.com')) {
              _launchUrl(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(userPortalUrl));

    _webViewController = controller;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  void _reloadPortal() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _webViewController?.reload();
  }

  void _goHome() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _webViewController?.loadRequest(Uri.parse(userPortalUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMobileOrMac) {
      return _buildDesktopDashboard(context);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_webViewController != null &&
            await _webViewController!.canGoBack()) {
          await _webViewController!.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).maybePop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0E11),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181A20),
          elevation: 1,
          titleSpacing: 12,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B313A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.currency_exchange,
                    color: Color(0xFFF0B90B), size: 20),
              ),
              const SizedBox(width: 10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: 'Juwish',
                        style: TextStyle(color: Color(0xFFEAECEF))),
                    TextSpan(
                        text: 'Pro',
                        style: TextStyle(color: Color(0xFFF0B90B))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x260ECB81),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0ECB81)),
                ),
                child: const Text(
                  'User Portal',
                  style: TextStyle(
                    color: Color(0xFF0ECB81),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFEAECEF)),
              tooltip: 'Refresh Portal',
              onPressed: _reloadPortal,
            ),
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Color(0xFFF0B90B)),
              tooltip: 'Home (Exchange)',
              onPressed: _goHome,
            ),
            const SizedBox(width: 4),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2.5),
                  child: LinearProgressIndicator(
                    value: _loadingProgress > 0 ? _loadingProgress / 100 : null,
                    backgroundColor: const Color(0xFF181A20),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFF0B90B)),
                    minHeight: 2.5,
                  ),
                )
              : null,
        ),
        body: _hasError ? _buildErrorView() : _buildWebView(),
      ),
    );
  }

  Widget _buildWebView() {
    if (_webViewController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF0B90B)),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFFF0B90B),
      backgroundColor: const Color(0xFF181A20),
      onRefresh: () async {
        _reloadPortal();
      },
      child: WebViewWidget(controller: _webViewController!),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0x26F6465D),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off,
                  size: 48, color: Color(0xFFF6465D)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEAECEF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ??
                  'Unable to connect to the JuwishPro User Portal. Please check your internet connection.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF848E9C)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reloadPortal,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF0B90B),
                foregroundColor: const Color(0xFF181A20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2B313A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.currency_exchange,
                  color: Color(0xFFF0B90B), size: 22),
            ),
            const SizedBox(width: 12),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: 'Juwish',
                      style: TextStyle(color: Color(0xFFEAECEF))),
                  TextSpan(
                      text: 'Pro', style: TextStyle(color: Color(0xFFF0B90B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x260ECB81),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0ECB81)),
              ),
              child: const Text(
                'User Portal Sync',
                style: TextStyle(
                  color: Color(0xFF0ECB81),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _launchUrl(userPortalUrl),
            icon: const Icon(Icons.open_in_browser, size: 16),
            label: const Text('Open User Portal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0B90B),
              foregroundColor: const Color(0xFF181A20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF181A20), Color(0xFF1E2329)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2B313A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JuwishPro User Portal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEAECEF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Synchronized exclusively with the JuwishPro User Portal. Trade JuwishCoin (JWC), access live spot markets, and settle PancakeSwap BEP-20 deposits automatically.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF848E9C)),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _launchUrl(userPortalUrl),
                        icon: const Icon(Icons.launch,
                            size: 16, color: Color(0xFF181A20)),
                        label: const Text('Launch Full User Portal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0B90B),
                          foregroundColor: const Color(0xFF181A20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          JwcCheckoutDialog.show(context);
                        },
                        icon: const Text('🥞', style: TextStyle(fontSize: 16)),
                        label: const Text('PancakeSwap Deposit Desk'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF0B90B),
                          side: const BorderSide(color: Color(0xFFF0B90B)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _launchUrl(pancakeSwapUrl),
                        icon: const Icon(Icons.open_in_new,
                            size: 16, color: Color(0xFFEAECEF)),
                        label: const Text('Direct PancakeSwap DEX'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEAECEF),
                          side: const BorderSide(color: Color(0xFF2B313A)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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
