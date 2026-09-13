import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required before any Arabic-locale intl.DateFormat call (notifications
  // list, etc.) - without this, DateFormat throws at runtime instead of
  // just falling back to a default locale.
  await initializeDateFormatting('ar');
  runApp(const EduFirstOnlineApp());
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
