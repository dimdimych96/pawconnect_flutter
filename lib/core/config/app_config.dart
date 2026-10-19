import 'package:flutter/foundation.dart';

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

  /// When true, offline mock fallback is permitted when the server is unreachable
  /// or when running on static web hosting (GitHub Pages, etc.).
  static bool get enableOfflineMocks {
    const fromEnv = bool.fromEnvironment('ENABLE_OFFLINE_MOCKS', defaultValue: false) ||
        bool.fromEnvironment('USE_MOCKS', defaultValue: false);
    if (fromEnv) return true;
    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host.contains('github.io') ||
          host.contains('pages.dev') ||
          host.contains('netlify.app') ||
          host.contains('vercel.app')) {
        return true;
      }
    }
    return false;
  }
}
