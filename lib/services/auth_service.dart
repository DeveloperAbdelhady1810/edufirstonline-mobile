import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_client.dart';
import 'push_notification_service.dart';

/// Single source of truth for "who is logged in" - the whole app listens to
/// this via Provider instead of screens managing their own token state.
class AuthService extends ChangeNotifier {
  AuthService() {
    _bootstrap();
  }

  static const _tokenPrefsKey = 'auth_token';

  AppUser? currentUser;
  String? _token;

  /// True while the very first launch is checking for a saved session -
  /// the splash screen watches this instead of guessing a fixed delay.
  bool isBootstrapping = true;

  bool get isAuthenticated => _token != null && currentUser != null;

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenPrefsKey);

    if (token != null) {
      _token = token;
      ApiClient.instance.setToken(token);
      try {
        final data = await ApiClient.instance.get('/me') as Map<String, dynamic>;
        currentUser = AppUser.fromJson(data);
        unawaited(PushNotificationService.instance.registerDeviceToken());
      } catch (_) {
        // Saved token is expired/revoked - fall back to logged-out silently,
        // the login screen is where the user finds out, not a startup error.
        await _clearSession();
      }
    }

    isBootstrapping = false;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final data = await ApiClient.instance.post('/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    await _persistSession(data['token'] as String, data['user'] as Map<String, dynamic>);
  }

  Future<void> registerStudent(Map<String, dynamic> payload) async {
    final data = await ApiClient.instance.post('/auth/register/student', payload) as Map<String, dynamic>;
    await _persistSession(data['token'] as String, data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await PushNotificationService.instance.unregisterDeviceToken();
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {
      // Even if the network call fails, still forget the local session -
      // the user asked to log out, that must always succeed locally.
    }
    await _clearSession();
  }

  Future<void> _persistSession(String token, Map<String, dynamic> userJson) async {
    _token = token;
    ApiClient.instance.setToken(token);
    currentUser = AppUser.fromJson(userJson);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenPrefsKey, token);
    notifyListeners();
    unawaited(PushNotificationService.instance.registerDeviceToken());
  }

  Future<void> _clearSession() async {
    _token = null;
    currentUser = null;
    ApiClient.instance.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenPrefsKey);
    notifyListeners();
  }
}
