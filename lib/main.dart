import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EduFirstOnlineApp());
}

class EduFirstOnlineApp extends StatelessWidget {
  const EduFirstOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const LoginScreen(),
    );
  }
}
