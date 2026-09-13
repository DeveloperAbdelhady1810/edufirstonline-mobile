import 'api_client.dart';

/// The backend has no native video-streaming or payment-initiation API -
/// both flows are deliberately bridged through the existing web app via a
/// short-lived signed ticket (`POST /mobile/webview-ticket`), which this app
/// then opens in an in-app WebView. This mirrors the web platform exactly
/// instead of inventing new native endpoints for video/payment.
class WebviewTicketService {
  WebviewTicketService._();
  static final WebviewTicketService instance = WebviewTicketService._();

  Future<String> learnUrl({required int courseId, int? lectureId}) =>
      _ticketUrl({
        'action': 'learn',
        'course_id': courseId,
        if (lectureId != null) 'lecture_id': lectureId,
      });

  Future<String> payCourseUrl(int courseId) => _ticketUrl({
        'action': 'pay_course',
        'course_id': courseId,
      });

  Future<String> payPackageUrl(int packageId) => _ticketUrl({
        'action': 'pay_package',
        'package_id': packageId,
      });

  Future<String> _ticketUrl(Map<String, dynamic> body) async {
    final data = await ApiClient.instance.post('/mobile/webview-ticket', body) as Map<String, dynamic>;
    return data['bridge_url'] as String;
  }
}
