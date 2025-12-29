import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Repository responsible for managing authentication token storage and retrieval
class AuthRepository {
  AuthRepository({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;
  static const String _tokenKey = 'auth_token';
  static const String _fakeToken = 'abc123';

  /// Check if user is already authenticated by checking for stored token
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get the currently stored authentication token
  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  /// Simulate login by storing a fake token
  /// In a real app, this would validate credentials and receive a token from API
  Future<void> login() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(seconds: 1));

    // Store the fake token
    await _secureStorage.write(key: _tokenKey, value: _fakeToken);
  }

  /// Clear the stored token (logout)
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
