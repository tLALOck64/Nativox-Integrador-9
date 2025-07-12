// TODO Implement this library.
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
