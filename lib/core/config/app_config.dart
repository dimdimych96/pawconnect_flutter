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

  /// When true, offline mock fallback is permitted for debugging/offline tests.
  /// In Production mode this is strictly false.
  static const bool enableOfflineMocks = bool.fromEnvironment(
    'ENABLE_OFFLINE_MOCKS',
    defaultValue: false,
  );
}
