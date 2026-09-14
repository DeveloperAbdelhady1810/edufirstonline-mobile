import 'api_client.dart';

enum PaymentStatusValue { completed, failed, pending }

class PaymentResult {
  const PaymentResult({required this.status, this.courseId, this.packageId});

  final PaymentStatusValue status;
  final int? courseId;
  final int? packageId;
}

/// Backs the WebView's checkout-return interception (see AppWebviewScreen) -
/// asks the backend what actually happened with a given order_ref instead
/// of guessing from whatever web page the browser would otherwise have
/// landed on.
class PaymentStatusService {
  PaymentStatusService._();
  static final PaymentStatusService instance = PaymentStatusService._();

  Future<PaymentResult> check(String orderRef) async {
    final data = await ApiClient.instance.get(
      '/mobile/payment-status',
      query: {'order_ref': orderRef},
    ) as Map<String, dynamic>;

    final status = switch (data['status'] as String?) {
      'completed' => PaymentStatusValue.completed,
      'failed' => PaymentStatusValue.failed,
      _ => PaymentStatusValue.pending,
    };

    return PaymentResult(
      status: status,
      courseId: data['course_id'] as int?,
      packageId: data['package_id'] as int?,
    );
  }
}
