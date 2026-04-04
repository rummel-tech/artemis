import 'package:shared_services/shared_services.dart';
import '../models/user.dart';

/// Authentication service backed by shared [BaseApiClient] and [TokenStorage].
///
/// Extends the shared infrastructure with Artemis-specific flows (Google login)
/// and returns [ArtemisUser] (which carries enabledModules / permissions).
class AuthService {
  final BaseApiClient _client;
  final TokenStorage _storage;

  AuthService({
    required BaseApiClient client,
    required TokenStorage storage,
  })  : _client = client,
        _storage = storage;

  // ---- Auth API calls ----

  Future<void> login(String email, String password) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        body: {'email': email, 'password': password},
        fromJson: (json) => json,
      );
      await _saveTokensFrom(response);
    } on ApiException catch (e) {
      throw AuthException(
        _extractDetail(e) ?? 'Login failed',
        code: 'LOGIN_FAILED',
      );
    }
  }

  Future<void> register(String email, String password, {String? fullName}) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/register',
        body: {
          'email': email,
          'password': password,
          if (fullName != null) 'full_name': fullName,
        },
        fromJson: (json) => json,
      );
      await _saveTokensFrom(response);
    } on ApiException catch (e) {
      throw AuthException(
        _extractDetail(e) ?? 'Registration failed',
        code: 'REGISTRATION_FAILED',
      );
    }
  }

  Future<void> loginWithGoogle(String idToken) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/auth/google',
        body: {'id_token': idToken},
        fromJson: (json) => json,
      );
      await _saveTokensFrom(response);
    } on ApiException catch (e) {
      throw AuthException(
        _extractDetail(e) ?? 'Google sign-in failed',
        code: 'GOOGLE_LOGIN_FAILED',
      );
    }
  }

  Future<ArtemisUser> getCurrentUser() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/auth/me',
        fromJson: (json) => json,
      );
      return ArtemisUser.fromJson(response);
    } on ApiException catch (e) {
      if (e.statusCode == 401) throw AuthException.tokenExpired();
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) return false;
    try {
      // Bypass the automatic token provider so we can send the refresh token.
      final originalProvider = _client.tokenProvider;
      _client.tokenProvider = null;
      try {
        final response = await _client.post<Map<String, dynamic>>(
          '/auth/refresh',
          headers: {'Authorization': 'Bearer $refresh'},
          fromJson: (json) => json,
        );
        await _saveTokensFrom(response);
        return true;
      } finally {
        _client.tokenProvider = originalProvider;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _client.post<Map<String, dynamic>>(
        '/auth/logout',
        fromJson: (json) => json,
      );
    } catch (_) {}
    await _storage.clear();
  }

  Future<bool> isLoggedIn() => _storage.hasTokens();

  Future<String?> getAccessToken() => _storage.getAccessToken();

  void dispose() => _client.dispose();

  // ---- Helpers ----

  Future<void> _saveTokensFrom(Map<String, dynamic> response) async {
    await _storage.saveTokens(
      accessToken: response['access_token'] as String,
      refreshToken: response['refresh_token'] as String,
    );
  }

  static String? _extractDetail(ApiException e) =>
      e.responseData?['detail'] as String?;
}
