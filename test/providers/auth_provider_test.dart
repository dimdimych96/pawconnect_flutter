import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/auth_model.dart';
import 'package:pawconnect/providers/auth_provider.dart';
import 'package:pawconnect/services/auth_service.dart';

void main() {
  group('AuthNotifier Tests', () {
    late FakeAuthStorage fakeStorage;
    late AuthService authService;
    late AuthNotifier authNotifier;

    setUp(() {
      fakeStorage = FakeAuthStorage();
      authService = AuthService(storage: fakeStorage);
      authNotifier = AuthNotifier(authService);
    });

    tearDown(() {
      authNotifier.dispose();
    });

    test('Initial state reflects storage session', () async {
      await fakeStorage.saveUser(AuthService.defaultUser);
      await fakeStorage.saveTokens(AuthService.defaultTokens);

      await authNotifier.checkSession();
      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.currentUser?.email, equals('alex@pawconnect.app'));
    });

    test('Login updates user state to authenticated and sets currentUser', () async {
      final success = await authNotifier.login(
        email: 'alex@pawconnect.app',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.currentUser?.email, equals('alex@pawconnect.app'));
    });

    test('Register creates new session and updates currentUser', () async {
      final success = await authNotifier.register(
        name: 'Мария Ветрова',
        email: 'maria@pawconnect.app',
        password: 'secretPassword',
      );

      expect(success, isTrue);
      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.currentUser?.name, equals('Мария Ветрова'));
    });

    test('Logout clears session and sets isAuthenticated to false', () async {
      await authNotifier.login(
        email: 'alex@pawconnect.app',
        password: 'password123',
      );

      expect(authNotifier.state.isAuthenticated, isTrue);

      await authNotifier.logout();

      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.currentUser, isNull);
    });
  });
}
