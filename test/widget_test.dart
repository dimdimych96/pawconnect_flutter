import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/main.dart';
import 'package:pawconnect/models/auth_model.dart';
import 'package:pawconnect/providers/auth_provider.dart';
import 'package:pawconnect/services/auth_service.dart';

void main() {
  testWidgets('PawConnect app renders and routes to AuthScreen when unauthenticated', (WidgetTester tester) async {
    final fakeStorage = FakeAuthStorage();
    final authService = AuthService(storage: fakeStorage, allowMockFallback: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
        ],
        child: const PawConnectApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The app shell and auth interface should be present.
    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(PawConnectApp), findsOneWidget);
    expect(find.text('PawConnect'), findsOneWidget);
    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Регистрация'), findsOneWidget);
    expect(find.text('Войти в аккаунт'), findsOneWidget);
  });

  testWidgets('PawConnect app renders Tab 0 Community feed when authenticated', (WidgetTester tester) async {
    final fakeStorage = FakeAuthStorage();
    await fakeStorage.saveTokens(
      AuthTokens(
        accessToken: 'test-token',
        refreshToken: 'test-refresh',
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ),
    );
    await fakeStorage.saveUser(
      UserAuthModel(
        id: 'usr-1',
        email: 'alex@pawconnect.app',
        name: 'Алексей Иванов',
      ),
    );
    final authService = AuthService(storage: fakeStorage, allowMockFallback: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
        ],
        child: const PawConnectApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('PawConnect'), findsWidgets);
    expect(find.text('Лента'), findsWidgets);
    expect(find.byKey(const ValueKey('feed_refresh_button')), findsOneWidget);
  });
}
