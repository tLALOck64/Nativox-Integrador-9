import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _preferences?.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    return _preferences?.getString('auth_token');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _preferences?.setString('refresh_token', refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return _preferences?.getString('refresh_token');
  }

  Future<void> clearTokens() async {
    await _preferences?.remove('auth_token');
    await _preferences?.remove('refresh_token');
  }

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _preferences?.setString('user_data', jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userData = _preferences?.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Generic methods
  Future<void> saveString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _preferences?.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _preferences?.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _preferences?.getInt(key);
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  Future<void> clear() async {
    await _preferences?.clear();
  }
}

/// Secure storage solo funciona en móvil/escritorio. En web, usar StorageService.
class SecureStorageService {
  static final _storage = FlutterSecureStorage();

  // Token management
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
  }

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final data = jsonEncode(userData);
    await _storage.write(key: 'user_data', value: data);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    String? userData = await _storage.read(key: 'user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Generic methods
  Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
