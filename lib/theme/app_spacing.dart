/// Consistent spacing scale (4/8/12/16/24/32) used across every screen so
/// padding/gaps never become ad-hoc magic numbers. Pick the closest value
/// from here instead of typing a raw double in a screen.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard page-edge padding for scrollable screen content.
  static const double pageHorizontal = lg;
  static const double pageVertical = lg;

  /// Corner radius scale - the web platform uses large (1.75rem ≈ 28px)
  /// rounded cards; mirrored here so the mobile app reads as the same
  /// product, not a generic Material app.
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
  static const double radiusPill = 999;
}
