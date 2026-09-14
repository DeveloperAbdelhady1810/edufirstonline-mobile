import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/push_notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required before any Arabic-locale intl.DateFormat call (notifications
  // list, etc.) - without this, DateFormat throws at runtime instead of
  // just falling back to a default locale.
  await initializeDateFormatting('ar');

  await _setUpPushNotifications();

  runApp(const EduFirstOnlineApp());
}

/// Reads google-services.json (Android) / GoogleService-Info.plist (iOS)
/// automatically - no explicit FirebaseOptions needed since this project
/// uses the native config files directly rather than the FlutterFire CLI.
///
/// Runs in every build mode, including debug - it used to skip debug builds
/// entirely because GoogleService-Info.plist wasn't yet a bundled Xcode
/// resource, which made Firebase.initializeApp() throw "core/not-initialized"
/// on iOS before runApp() even ran, crashing the whole app. That's fixed now
/// (the plist is registered in the Xcode project), but skipping debug builds
/// meant push setup - and device-token registration - never ran during
/// normal `flutter run` testing either, silently producing zero registered
/// tokens. The try/catch below is the real safety net (kept in every build
/// mode): a push-setup problem should never be able to take the whole app
/// down, in debug or release.
Future<void> _setUpPushNotifications() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize();
  } catch (e, stackTrace) {
    debugPrint('Push notification setup failed, continuing without it: $e\n$stackTrace');
  }
}

class EduFirstOnlineApp extends StatelessWidget {
  const EduFirstOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'EduFirstOnline',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // Arabic-first: this app defaults to RTL, it's not an English layout
        // with Arabic text pasted in. The delegates below are what make
        // Flutter's own widgets (back buttons, text selection, etc.) mirror
        // correctly for 'ar' - locale alone isn't enough without them.
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
