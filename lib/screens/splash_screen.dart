import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'app_shell.dart';
import 'login_screen.dart';

/// Decides where to land: straight into the app if a saved session is
/// still valid, otherwise the login screen. Watches AuthService's
/// bootstrap flag instead of guessing a fixed delay.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isBootstrapping) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_rounded, size: 72, color: Colors.white)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.95, end: 1.05, duration: 900.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 16),
                  Text('EduFirstOnline', style: AppTypography.headline.copyWith(color: Colors.white))
                      .animate()
                      .fadeIn(duration: 400.ms),
                ],
              ),
            ),
          );
        }

        return auth.isAuthenticated ? AppShell() : const LoginScreen();
      },
    );
  }
}
