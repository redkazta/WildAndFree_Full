class CacheService {
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static const Duration defaultTTL = Duration(minutes: 5);

  static T? get<T>(String key) {
    if (_cacheTimestamps.containsKey(key)) {
      if (DateTime.now().difference(_cacheTimestamps[key]!) < defaultTTL) {
        return _memoryCache[key] as T?;
      }
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    return null;
  }

  static void set<T>(String key, T value, {Duration? ttl}) {
    _memoryCache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  static void invalidate(String key) {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  static void invalidateAll() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
  }

  static void invalidatePattern(String pattern) {
    final keysToRemove = _memoryCache.keys
        .where((key) => key.contains(pattern))
        .toList();
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  static int get size => _memoryCache.length;

  static bool has(String key) {
    if (!_cacheTimestamps.containsKey(key)) return false;
    if (DateTime.now().difference(_cacheTimestamps[key]!) >= defaultTTL) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      return false;
    }
    return true;
  }
}
