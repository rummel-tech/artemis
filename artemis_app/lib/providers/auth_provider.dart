import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;

  ArtemisUser? _user;
  bool _initialized = false;

  AuthProvider(this._auth);

  ArtemisUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get initialized => _initialized;

  Future<void> init() async {
    if (await _auth.isLoggedIn()) {
      try {
        _user = await _auth.getCurrentUser();
      } catch (_) {
        // Token may be expired — try refresh
        final ok = await _auth.refreshToken();
        if (ok) {
          try { _user = await _auth.getCurrentUser(); } catch (_) {}
        }
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
    _user = await _auth.getCurrentUser();
    notifyListeners();
  }

  Future<void> register(String email, String password, {String? fullName}) async {
    await _auth.register(email, password, fullName: fullName);
    _user = await _auth.getCurrentUser();
    notifyListeners();
  }

  Future<void> loginWithGoogle(String idToken) async {
    await _auth.loginWithGoogle(idToken);
    _user = await _auth.getCurrentUser();
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    notifyListeners();
  }
}
