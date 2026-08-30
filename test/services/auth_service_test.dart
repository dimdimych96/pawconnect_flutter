import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/auth_model.dart';
import 'package:pawconnect/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late FakeAuthStorage fakeStorage;
    late AuthService authService;

    setUp(() {
      fakeStorage = FakeAuthStorage();
      authService = AuthService(storage: fakeStorage);
    });

    test('UserAuthModel serialization and deserialization', () {
      final user = UserAuthModel(
        id: 'usr-101',
        email: 'alex@pawconnect.app',
        name: 'Алексей Иванов',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
      );

      final json = user.toJson();
      final fromJson = UserAuthModel.fromJson(json);

      expect(fromJson.id, equals('usr-101'));
      expect(fromJson.email, equals('alex@pawconnect.app'));
      expect(fromJson.name, equals('Алексей Иванов'));
    });

    test('AuthTokens serialization and expiration checks', () {
      final tokens = AuthTokens(
        accessToken: 'access-jwt-token-123',
        refreshToken: 'refresh-jwt-token-456',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      );

      final json = tokens.toJson();
      final fromJson = AuthTokens.fromJson(json);

      expect(fromJson.accessToken, equals('access-jwt-token-123'));
      expect(fromJson.refreshToken, equals('refresh-jwt-token-456'));
      expect(fromJson.isExpired, isFalse);
    });

    test('Login stores tokens and returns authenticated user', () async {
      final result = await authService.login(
        email: 'alex@pawconnect.app',
        password: 'password123',
      );

      expect(result.user.email, equals('alex@pawconnect.app'));
      expect(result.tokens.accessToken, isNotEmpty);

      // Verify tokens stored in storage
      final savedTokens = await fakeStorage.getTokens();
      expect(savedTokens, isNotNull);
      expect(savedTokens!.accessToken, equals(result.tokens.accessToken));
    });

    test('Register creates new account, stores tokens and session', () async {
      final result = await authService.register(
        name: 'Елена Смирнова',
        email: 'elena@pawconnect.app',
        password: 'securePassword99',
      );

      expect(result.user.name, equals('Елена Смирнова'));
      expect(result.user.email, equals('elena@pawconnect.app'));
      expect(result.tokens.accessToken, isNotEmpty);

      final savedUser = await fakeStorage.getUser();
      expect(savedUser, isNotNull);
      expect(savedUser!.name, equals('Елена Смирнова'));
    });

    test('Logout clears tokens and cached user data', () async {
      await authService.login(
        email: 'alex@pawconnect.app',
        password: 'password123',
      );

      expect(await fakeStorage.getTokens(), isNotNull);

      await authService.logout();

      expect(await fakeStorage.getTokens(), isNull);
      expect(await fakeStorage.getUser(), isNull);
    });
  });
}
