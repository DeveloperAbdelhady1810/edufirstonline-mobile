// Basic smoke test - confirms the app boots and the login screen's
// Arabic title renders. Replace/expand once real screens exist.

import 'package:flutter_test/flutter_test.dart';

import 'package:edufirstonline_mobile/main.dart';

void main() {
  testWidgets('App boots and shows the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EduFirstOnlineApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('EduFirstOnline'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsWidgets);
  });
}
