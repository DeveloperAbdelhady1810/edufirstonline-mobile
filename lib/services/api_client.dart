import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Thrown for any non-2xx response. [message] is already a
/// human-readable (often Arabic, straight from Laravel validation) string
/// safe to show directly in a SnackBar/dialog.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors});

  final String message;
  final int? statusCode;

  /// Laravel 422 validation errors, field name -> first error message.
  final Map<String, String>? fieldErrors;

  @override
  String toString() => message;
}

/// Single HTTP client for the whole app - every screen goes through this
/// instead of calling `http` directly, so auth headers, error shaping, and
/// timeouts are handled in exactly one place.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http
        .post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null)
        .timeout(const Duration(seconds: 20));
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(utf8.decode(res.bodyBytes));
    }

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      // Non-JSON error body (e.g. a raw 500 HTML page) - fall through to the
      // generic message below rather than crashing on the decode itself.
    }

    Map<String, String>? fieldErrors;
    if (decoded?['errors'] is Map) {
      fieldErrors = (decoded!['errors'] as Map).map(
        (key, value) => MapEntry('$key', value is List ? '${value.first}' : '$value'),
      );
    }

    final message = (decoded?['message'] as String?) ??
        fieldErrors?.values.firstOrNull ??
        _genericMessageFor(res.statusCode);

    throw ApiException(message, statusCode: res.statusCode, fieldErrors: fieldErrors);
  }

  String _genericMessageFor(int statusCode) => switch (statusCode) {
        401 => 'بيانات الدخول غير صحيحة',
        403 => 'غير مصرح لك بهذا الإجراء',
        404 => 'العنصر المطلوب غير موجود',
        422 => 'يرجى مراجعة البيانات المدخلة',
        >= 500 => 'حدث خطأ في الخادم، حاول مرة أخرى لاحقًا',
        _ => 'حدث خطأ غير متوقع، حاول مرة أخرى',
      };
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
