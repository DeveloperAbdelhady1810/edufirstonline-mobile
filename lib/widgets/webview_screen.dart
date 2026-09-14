import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/payment_status_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Generic full-screen WebView used for both lecture playback and Paymob
/// checkout - both bridged from the real backend via a signed one-time
/// ticket URL (see WebviewTicketService).
///
/// Lecture playback has no completion callback at all, so it still just
/// closes on the back arrow. Checkout is different: QuadroPay always sends
/// the browser back to one stable, known URL (`/checkout/return?order_ref=`)
/// regardless of success/failure - see CheckoutReturnController. When
/// [watchForPaymentReturn] is true, that URL is intercepted before it ever
/// loads (the full website page behind it is never shown), the real
/// status is fetched from the API, and this screen pops itself with a
/// [PaymentResult] instead of leaving the caller to guess from a bare
/// "webview closed" event.
class AppWebviewScreen extends StatefulWidget {
  const AppWebviewScreen({
    super.key,
    required this.url,
    required this.title,
    this.watchForPaymentReturn = false,
  });

  final String url;
  final String title;
  final bool watchForPaymentReturn;

  @override
  State<AppWebviewScreen> createState() => _AppWebviewScreenState();
}

class _AppWebviewScreenState extends State<AppWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _resolvingPayment = false;

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
          onNavigationRequest: widget.watchForPaymentReturn ? _interceptCheckoutReturn : null,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  NavigationDecision _interceptCheckoutReturn(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null || !uri.path.contains('/checkout/return')) {
      return NavigationDecision.navigate;
    }

    final orderRef = uri.queryParameters['order_ref'];
    if (orderRef == null) {
      return NavigationDecision.navigate;
    }

    // Fire-and-return: prevent the WebView from ever loading the website's
    // own success/failure page, and resolve the result ourselves instead.
    _resolvePayment(orderRef);
    return NavigationDecision.prevent;
  }

  Future<void> _resolvePayment(String orderRef) async {
    if (_resolvingPayment) return;
    setState(() => _resolvingPayment = true);

    PaymentResult result;
    try {
      result = await PaymentStatusService.instance.check(orderRef);
    } catch (_) {
      result = const PaymentResult(status: PaymentStatusValue.pending);
    }

    if (!mounted) return;
    Navigator.of(context).pop(result);
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
          if (_isLoading || _resolvingPayment)
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}
