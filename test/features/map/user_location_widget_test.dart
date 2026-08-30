import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/map/widgets/user_marker_widget.dart';

void main() {
  testWidgets('UserMarkerWidget renders with avatar and label badge', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: UserMarkerWidget(
              ownerName: 'Алексей Иванов',
              avatarUrl: null,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    // Verify badge text "Я 📍"
    expect(find.text('Я 📍'), findsOneWidget);

    // Tap marker
    await tester.tap(find.byType(UserMarkerWidget));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
