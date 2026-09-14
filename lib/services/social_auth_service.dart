import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'api_client.dart';

/// Result of a Google/Apple sign-in attempt against the backend.
///
/// Either the account already existed (backend already issued a session,
/// same as email/password login) or it's brand new and still needs the
/// student-profile fields the web's complete-profile form also collects
/// (parent phone, grade, school, ...) before a Student row can be created.
sealed class SocialAuthResult {}

class SocialAuthLoggedIn extends SocialAuthResult {
  SocialAuthLoggedIn(this.token, this.user);
  final String token;
  final Map<String, dynamic> user;
}

class SocialAuthNeedsProfile extends SocialAuthResult {
  SocialAuthNeedsProfile({required this.ticket, required this.name, required this.email});
  final String ticket;
  final String name;
  final String email;
}

/// Wraps the native Google/Apple SDKs and exchanges their tokens for a
/// backend session via POST /auth/google and /auth/apple - the mobile
/// equivalent of the web's redirect-based Socialite flow.
class SocialAuthService {
  SocialAuthService._();
  static final SocialAuthService instance = SocialAuthService._();

  // Same Web-application OAuth client this app already uses server-side for
  // Socialite (services.google.client_id) - passing it as serverClientId
  // means the id token Google hands back is audienced to it, so the backend
  // can verify with zero new config.
  static const _googleServerClientId =
      '910529856140-bhfvitu51h82qirid8che9ebpcgnll6b.apps.googleusercontent.com';

  final _googleSignIn = GoogleSignIn(serverClientId: _googleServerClientId);

  Future<SocialAuthResult> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw ApiException('تم إلغاء تسجيل الدخول بواسطة جوجل');
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw ApiException('تعذر الحصول على بيانات جوجل، حاول مرة أخرى');
    }

    final data = await ApiClient.instance.post('/auth/google', {'id_token': idToken}) as Map<String, dynamic>;
    return _resultFrom(data);
  }

  Future<SocialAuthResult> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null) {
      throw ApiException('تعذر الحصول على بيانات آبل، حاول مرة أخرى');
    }

    // Apple only ever returns givenName/familyName on the user's very first
    // authorization - must be captured and forwarded right now, or it's
    // lost for good on every later sign-in.
    final name = [credential.givenName, credential.familyName].whereType<String>().join(' ').trim();

    final data = await ApiClient.instance.post('/auth/apple', {
      'identity_token': identityToken,
      if (name.isNotEmpty) 'name': name,
    }) as Map<String, dynamic>;
    return _resultFrom(data);
  }

  SocialAuthResult _resultFrom(Map<String, dynamic> data) {
    if (data['needs_profile'] == true) {
      return SocialAuthNeedsProfile(
        ticket: data['ticket'] as String,
        name: (data['name'] as String?) ?? '',
        email: (data['email'] as String?) ?? '',
      );
    }
    return SocialAuthLoggedIn(data['token'] as String, data['user'] as Map<String, dynamic>);
  }
}
