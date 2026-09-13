// Basic smoke test - confirms the app boots, bootstraps auth state (no
// saved session in a fresh test environment), and lands on the login
// screen's Arabic title. Replace/expand once real screens exist.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edufirstonline_mobile/main.dart';

void main() {
  testWidgets('App boots and shows the login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const EduFirstOnlineApp());
    // Not pumpAndSettle(): the login screen has deliberately-infinite
    // looping micro-animations (the floating Lottie mascot), which would
    // make pumpAndSettle time out waiting for animations to finish.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('EduFirstOnline'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsWidgets);
  });
}
