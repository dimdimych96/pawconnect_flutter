import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/core/widgets/auth_prompt_modal.dart';
import 'package:pawconnect/main.dart';
import 'package:pawconnect/models/auth_model.dart';
import 'package:pawconnect/providers/auth_provider.dart';
import 'package:pawconnect/services/auth_service.dart';

void main() {
  testWidgets('PawConnect app renders Tab 0 Community feed in Guest Mode when unauthenticated', (WidgetTester tester) async {
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
    await tester.pump(const Duration(milliseconds: 500));

    // The app shell renders Tab 0 directly in guest mode
    expect(find.byType(PawConnectApp), findsOneWidget);
    expect(find.text('PawConnect'), findsWidgets);
    expect(find.byKey(const ValueKey('feed_tab_for_you')), findsOneWidget);
    expect(find.byKey(const ValueKey('feed_guest_login_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('feed_add_post_button')), findsOneWidget);

    // Tapping guest login button routes to AuthScreen
    await tester.tap(find.byKey(const ValueKey('feed_guest_login_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Регистрация'), findsOneWidget);
    expect(find.text('Войти в аккаунт'), findsOneWidget);
    expect(find.text('К ленте'), findsOneWidget);
    expect(find.text('Продолжить как гость'), findsOneWidget);
  });

  testWidgets('Tapping create post as guest displays AuthPromptModal', (WidgetTester tester) async {
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
    await tester.pump(const Duration(milliseconds: 500));

    // Tap + button as guest
    await tester.tap(find.byKey(const ValueKey('feed_add_post_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AuthPromptModal appears
    expect(find.byType(AuthPromptModal), findsOneWidget);
    expect(find.text('Требуется авторизация'), findsOneWidget);
    expect(find.text('Продолжить как гость'), findsOneWidget);
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
    expect(find.byKey(const ValueKey('feed_add_post_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('feed_tab_for_you')), findsOneWidget);
    // Guest login button is hidden when authenticated
    expect(find.byKey(const ValueKey('feed_guest_login_button')), findsNothing);
  });
}
