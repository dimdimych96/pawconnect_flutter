class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://127.0.0.1:8000/api/v1/ws',
  );

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  /// When true, offline mock fallback is permitted ONLY via explicit compilation flag
  /// (--dart-define=USE_MOCKS=true). In production and standard builds it is always false.
  static const bool enableOfflineMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: false) ||
      bool.fromEnvironment('ENABLE_OFFLINE_MOCKS', defaultValue: false);
}
