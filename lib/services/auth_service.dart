import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/app_config.dart';
import '../models/auth_model.dart';

abstract class AuthStorage {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> clearTokens();

  Future<void> saveUser(UserAuthModel user);
  Future<UserAuthModel?> getUser();
  Future<void> clearUser();
}

class SecureAuthStorage implements AuthStorage {
  final FlutterSecureStorage _storage;

  SecureAuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokensKey = 'paw_auth_tokens';
  static const String _userKey = 'paw_auth_user';

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await _storage.write(key: _tokensKey, value: jsonEncode(tokens.toJson()));
    } catch (_) {}
  }

  @override
  Future<AuthTokens?> getTokens() async {
    try {
      final raw = await _storage.read(key: _tokensKey);
      if (raw != null) {
        return AuthTokens.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _tokensKey);
    } catch (_) {}
  }

  @override
  Future<void> saveUser(UserAuthModel user) async {
    try {
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    } catch (_) {}
  }

  @override
  Future<UserAuthModel?> getUser() async {
    try {
      final raw = await _storage.read(key: _userKey);
      if (raw != null) {
        return UserAuthModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> clearUser() async {
    try {
      await _storage.delete(key: _userKey);
    } catch (_) {}
  }
}

class FakeAuthStorage implements AuthStorage {
  AuthTokens? _tokens;
  UserAuthModel? _user;

  @override
  Future<void> saveTokens(AuthTokens tokens) async => _tokens = tokens;

  @override
  Future<AuthTokens?> getTokens() async => _tokens;

  @override
  Future<void> clearTokens() async => _tokens = null;

  @override
  Future<void> saveUser(UserAuthModel user) async => _user = user;

  @override
  Future<UserAuthModel?> getUser() async => _user;

  @override
  Future<void> clearUser() async => _user = null;
}

class AuthService {
  final Dio _dio;
  final AuthStorage _storage;

  AuthService({
    Dio? dio,
    AuthStorage? storage,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 3),
              ),
            ),
        _storage = storage ?? SecureAuthStorage();

  AuthStorage get storage => _storage;

  /// Default Mock User for Offline / Demo Mode
  static final UserAuthModel defaultUser = UserAuthModel(
    id: 'usr-default-1',
    email: 'alex@pawconnect.app',
    name: 'Алексей Иванов',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
  );

  /// Default Mock Tokens
  static final AuthTokens defaultTokens = AuthTokens(
    accessToken: 'mock_jwt_access_token_${DateTime.now().millisecondsSinceEpoch}',
    refreshToken: 'mock_jwt_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    expiresAt: DateTime.now().add(const Duration(days: 30)),
  );

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      ).timeout(const Duration(milliseconds: 500));

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
        await _storage.saveTokens(authResponse.tokens);
        await _storage.saveUser(authResponse.user);
        return authResponse;
      }
    } catch (_) {
      // Offline fallback login
    }

    final fallbackUser = UserAuthModel(
      id: 'usr-${email.hashCode.abs()}',
      email: email,
      name: email.split('@').first,
      avatarUrl: defaultUser.avatarUrl,
      createdAt: DateTime.now(),
    );
    final fallbackTokens = defaultTokens;

    await _storage.saveTokens(fallbackTokens);
    await _storage.saveUser(fallbackUser);

    return AuthResponse(user: fallbackUser, tokens: fallbackTokens);
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(milliseconds: 500));

      if (response.statusCode == 201 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
        await _storage.saveTokens(authResponse.tokens);
        await _storage.saveUser(authResponse.user);
        return authResponse;
      }
    } catch (_) {
      // Offline fallback register
    }

    final newUser = UserAuthModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: defaultUser.avatarUrl,
      createdAt: DateTime.now(),
    );
    final newTokens = defaultTokens;

    await _storage.saveTokens(newTokens);
    await _storage.saveUser(newUser);

    return AuthResponse(user: newUser, tokens: newTokens);
  }

  Future<AuthTokens?> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      ).timeout(const Duration(milliseconds: 500));

      if (response.statusCode == 200 && response.data != null) {
        final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
        await _storage.saveTokens(tokens);
        return tokens;
      }
    } catch (_) {}
    return null;
  }

  Future<void> logout() async {
    try {
      final tokens = await _storage.getTokens();
      if (tokens != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer ${tokens.accessToken}'}),
        ).timeout(const Duration(milliseconds: 300));
      }
    } catch (_) {}

    await _storage.clearTokens();
    await _storage.clearUser();
  }

  Future<UserAuthModel?> getCurrentUser() async {
    return await _storage.getUser();
  }

  Future<AuthTokens?> getSavedTokens() async {
    return await _storage.getTokens();
  }
}

/// Dio Interceptor for Automatic JWT Bearer Header and 401 Refresh
class AuthInterceptor extends Interceptor {
  final AuthStorage _storage;
  final AuthService _authService;

  AuthInterceptor(this._storage, this._authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final tokens = await _storage.getTokens();
    if (tokens != null && tokens.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final tokens = await _storage.getTokens();
      if (tokens != null && tokens.refreshToken.isNotEmpty) {
        final refreshed = await _authService.refreshToken(tokens.refreshToken);
        if (refreshed != null) {
          final req = err.requestOptions;
          req.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
          try {
            final clonedResponse = await Dio().fetch(req);
            return handler.resolve(clonedResponse);
          } catch (e) {
            return handler.next(err);
          }
        }
      }
      await _storage.clearTokens();
      await _storage.clearUser();
    }
    handler.next(err);
  }
}
