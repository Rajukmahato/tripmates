/// Service to manage server time synchronization and offset
class ServerTimeService {
  static final ServerTimeService _instance = ServerTimeService._internal();

  DateTime? _serverTime;
  late DateTime _lastSyncTime;

  factory ServerTimeService() {
    return _instance;
  }

  ServerTimeService._internal() {
    _lastSyncTime = DateTime.now();
    _serverTime = DateTime.now();
  }

  /// Sync with server time from an API response timestamp
  void syncWithServerTime(DateTime serverDateTime) {
    _serverTime = serverDateTime;
    _lastSyncTime = DateTime.now();
  }

  /// Get the current server time (adjusted for elapsed local time)
  DateTime getCurrentServerTime() {
    if (_serverTime == null) {
      return DateTime.now();
    }

    final elapsedLocal = DateTime.now().difference(_lastSyncTime);
    final adjustedServerTime = _serverTime!.add(elapsedLocal);

    return adjustedServerTime;
  }

  /// Get just the server date (without time)
  DateTime getCurrentServerDate() {
    final now = getCurrentServerTime();
    return DateTime(now.year, now.month, now.day);
  }

  /// Check if server time is synchronized
  bool get isSynchronized => _serverTime != null;

  /// Reset the server time sync (use device time)
  void reset() {
    _serverTime = null;
    _lastSyncTime = DateTime.now();
  }
}
