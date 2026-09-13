import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Generic full-screen WebView used for both lecture playback and Paymob
/// checkout - both bridged from the real backend via a signed one-time
/// ticket URL (see WebviewTicketService). Neither flow has a native
/// completion callback exposed by the API, so the user simply closes this
/// screen (back arrow) when done and the calling screen refreshes itself.
class AppWebviewScreen extends StatefulWidget {
  const AppWebviewScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<AppWebviewScreen> createState() => _AppWebviewScreenState();
}

class _AppWebviewScreenState extends State<AppWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: AppTypography.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}
