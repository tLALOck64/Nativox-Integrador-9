import 'dart:convert';  

class CacheService {
  static CacheService? _instance;
  final Map<String, CacheItem> _cache = {};

  CacheService._internal();

  factory CacheService() {
    _instance ??= CacheService._internal();
    return _instance!;
  }

  void put<T>(String key, T data, {Duration? expiry}) {
    final expiryTime = expiry != null 
        ? DateTime.now().add(expiry) 
        : null;
    
    _cache[key] = CacheItem(
      data: data,
      expiryTime: expiryTime,
    );
  }

  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;
    
    if (item.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    return item.data as T?;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  bool contains(String key) {
    final item = _cache[key];
    if (item == null) return false;
    
    if (item.isExpired) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }
}

class CacheItem {
  final dynamic data;
  final DateTime? expiryTime;

  CacheItem({
    required this.data,
    this.expiryTime,
  });

  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }
}