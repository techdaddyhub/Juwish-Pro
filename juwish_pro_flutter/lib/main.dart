import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.nightObsidian,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const JuwishProApp());
}

/// Official JuwishPro Cross-Platform Mobile Application
class JuwishProApp extends StatelessWidget {
  const JuwishProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JuwishPro | Crypto Exchange & JWC Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ProductionAppShell(),
    );
  }
}

class ProductionAppShell extends StatefulWidget {
  const ProductionAppShell({super.key});

  @override
  State<ProductionAppShell> createState() => _ProductionAppShellState();
}

class _ProductionAppShellState extends State<ProductionAppShell> {
  static const String webPlatformUrl = 'https://2026.dmillers.org';

  WebViewController? _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime? _lastBackPressTime;

  bool get _isWebViewSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    if (_isWebViewSupported) {
      _initWebView();
    } else {
      _isLoading = false;
    }
  }

  void _initWebView() {
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(AppTheme.nightObsidian)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _loadingProgress = progress;
                  if (progress >= 100) {
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
              final isMainFrame = error.isForMainFrame ?? true;
              if (isMainFrame && mounted) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                  _errorMessage = error.description;
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url;
              // Intercept external communication protocols
              if (url.startsWith('mailto:') ||
                  url.startsWith('tel:') ||
                  url.startsWith('sms:') ||
                  url.startsWith('tg:') ||
                  url.startsWith('whatsapp:') ||
                  url.startsWith('intent:')) {
                _launchExternalUrl(url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        );

      controller.loadRequest(Uri.parse(webPlatformUrl));
      _controller = controller;
    } catch (e) {
      debugPrint('WebView initialization fallback: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Failed to launch external URL: $e');
    }
  }

  Future<void> _handlePopScope(bool didPop, dynamic result) async {
    if (didPop) return;

    if (_controller != null) {
      final canGoBack = await _controller!.canGoBack();
      if (canGoBack) {
        await _controller!.goBack();
        return;
      }
    }

    // Double tap back to exit application
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Press back again to exit JuwishPro',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            backgroundColor: AppTheme.surfaceCharcoal,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Exit application
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopScope,
      child: Scaffold(
        backgroundColor: AppTheme.nightObsidian,
        body: SafeArea(
          top: true,
          bottom: false,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isWebViewSupported) {
      return _buildDesktopFallback();
    }

    if (_hasError && _controller == null) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        // Native Pull-to-Refresh WebView
        if (_controller != null)
          RefreshIndicator(
            color: AppTheme.gold,
            backgroundColor: AppTheme.surfaceCharcoal,
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await _controller?.reload();
            },
            child: WebViewWidget(controller: _controller!),
          ),

        // Linear Progress Bar at top
        if (_isLoading && _loadingProgress < 100)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _loadingProgress > 0 ? _loadingProgress / 100.0 : null,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
              minHeight: 3.0,
            ),
          ),

        // Initial Splash Screen Overlay (while initializing 1st load)
        if (_isLoading && _loadingProgress < 20)
          Container(
            color: AppTheme.nightObsidian,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo-square.png',
                    width: 90,
                    height: 90,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.currency_bitcoin,
                      size: 80,
                      color: AppTheme.gold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Connecting to JuwishPro...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Offline / Error Overlay
        if (_hasError)
          _buildErrorState(),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: AppTheme.nightObsidian,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCharcoal,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderHighlight),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppTheme.gold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Lost',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Unable to connect to the JuwishPro secure exchange network. Please check your internet connection.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.nightObsidian,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Retry Connection',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                  _loadingProgress = 10;
                });
                _controller?.loadRequest(Uri.parse(webPlatformUrl));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFallback() {
    return Container(
      color: AppTheme.nightObsidian,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo-square.png',
                width: 100,
                height: 100,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.token,
                  size: 90,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'JuwishPro Desktop Client',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connected to 2026.dmillers.org',
                style: TextStyle(color: AppTheme.gold, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.nightObsidian,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_browser),
                label: const Text(
                  'Launch Web Platform',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _launchExternalUrl(webPlatformUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
