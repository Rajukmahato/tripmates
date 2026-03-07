import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  TokenService(SharedPreferences prefs) : _prefs = prefs;

  // Save token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  // Get token
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  // Remove token (for logout)
  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
    // Also remove from FlutterSecureStorage
    await _secureStorage.delete(key: _tokenKey);
  }
}
