// Smoke test for the PawConnect app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pawconnect/main.dart';

void main() {
  testWidgets('PawConnect app renders', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PawConnectApp(),
      ),
    );
    // Let the first frame settle. Avoid pumpAndSettle: providers kick off
    // network fetches (with fallback to mock data) that keep timers alive.
    await tester.pump(const Duration(milliseconds: 500));

    // The app shell should be present.
    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(PawConnectApp), findsOneWidget);
  });
}
