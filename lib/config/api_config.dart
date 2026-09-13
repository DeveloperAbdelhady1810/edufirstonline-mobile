/// Real, confirmed-live backend - edufirstonline.com's domain was briefly
/// suspended earlier this project but is back and serving the current app
/// (verified directly: GET https://www.edufirstonline.com/api/courses -> 200
/// with real course data, matching this app's models field-for-field).
class ApiConfig {
  ApiConfig._();

  static const String webBaseUrl = 'https://www.edufirstonline.com';
  static const String baseUrl = '$webBaseUrl/api';
}
