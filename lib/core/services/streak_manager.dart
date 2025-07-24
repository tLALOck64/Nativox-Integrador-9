import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class StreakManager {
  static const String _firstUseKey = 'streak_first_use';
  static const String _lastDayKey = 'streak_last_day';
  static const String _totalDaysKey = 'streak_total_days';

  final StorageService _storage = StorageService();

  Future<void> registerFirstUse() async {
    final firstUse = await _storage.getString(_firstUseKey);
    if (firstUse == null) {
      final now = DateTime.now().toIso8601String();
      await _storage.saveString(_firstUseKey, now);
      await _storage.saveString(_lastDayKey, now);
      await _storage.saveInt(_totalDaysKey, 1);
    }
  }

  Future<bool> isNewDay() async {
    final lastDayStr = await _storage.getString(_lastDayKey);
    if (lastDayStr == null) return true;
    final lastDay = DateTime.parse(lastDayStr);
    final now = DateTime.now();
    return now.difference(lastDay).inDays >= 1;
  }

  Future<void> registerNewDayIfNeeded() async {
    if (await isNewDay()) {
      final now = DateTime.now().toIso8601String();
      await _storage.saveString(_lastDayKey, now);
      int totalDays = (await _storage.getInt(_totalDaysKey)) ?? 0;
      await _storage.saveInt(_totalDaysKey, totalDays + 1);
    }
  }

  Future<DateTime?> getFirstUseDate() async {
    final firstUse = await _storage.getString(_firstUseKey);
    if (firstUse == null) return null;
    return DateTime.parse(firstUse);
  }

  Future<int> getTotalDays() async {
    return (await _storage.getInt(_totalDaysKey)) ?? 0;
  }

  Future<DateTime?> getLastDay() async {
    final lastDay = await _storage.getString(_lastDayKey);
    if (lastDay == null) return null;
    return DateTime.parse(lastDay);
  }

  Future<void> reset() async {
    await _storage.remove(_firstUseKey);
    await _storage.remove(_lastDayKey);
    await _storage.remove(_totalDaysKey);
  }
} 