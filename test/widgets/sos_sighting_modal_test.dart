import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawconnect/features/community/widgets/sos_sighting_modal.dart';

void main() {
  testWidgets('SosSightingModal renders and handles form submission', (tester) async {
    double? submittedLat;
    double? submittedLng;
    String? submittedNote;
    String? submittedTime;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SosSightingModal(
              postId: 'post-123',
              petName: 'Арчи',
              defaultLat: 55.0302,
              defaultLng: 82.9204,
              onSubmit: (lat, lng, note, timeAgo) async {
                submittedLat = lat;
                submittedLng = lng;
                submittedNote = note;
                submittedTime = timeAgo;
              },
            ),
          ),
        ),
      ),
    );

    // Verify initial elements
    expect(find.text('Зафиксировать след'), findsOneWidget);
    expect(find.text('Поиск: Арчи'), findsOneWidget);
    expect(find.text('Только что'), findsOneWidget);
    expect(find.text('15–30 мин назад'), findsOneWidget);
    expect(find.text('Отправить сигнал следа'), findsOneWidget);

    // Attempt submission without note -> shows error
    await tester.tap(find.text('Отправить сигнал следа'));
    await tester.pump();
    expect(find.text('Пожалуйста, опишите детали (направление, состояние)'), findsOneWidget);
    expect(submittedNote, isNull);

    // Change time option chip to '15–30 мин назад'
    await tester.tap(find.text('15–30 мин назад'));
    await tester.pump();

    // Enter note text
    await tester.enterText(
      find.byType(TextField),
      'Бежал в сторону сквера Альгамбра, без ошейника',
    );
    await tester.pump();

    // Submit form
    await tester.tap(find.text('Отправить сигнал следа'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(submittedLat, 55.0302);
    expect(submittedLng, 82.9204);
    expect(submittedNote, 'Бежал в сторону сквера Альгамбра, без ошейника');
    expect(submittedTime, '15–30 мин назад');
  });
}
