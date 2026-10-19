import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/map/widgets/start_walk_modal.dart';
import 'package:pawconnect/models/walk_session_model.dart';

void main() {
  group('StartWalkModal Widget Tests', () {
    testWidgets('StartWalkModal selects mode, temperament, and calls onStart', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? chosenMode;
      DogTemperament? chosenTemp;
      String? chosenNote;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartWalkModal(
              currentLat: 55.0302,
              currentLng: 82.9204,
              petName: 'Арчи',
              petBreed: 'Вельш-корги',
              defaultTemperament: DogTemperament.playful,
              onStart: ({
                required String petId,
                required String petName,
                required String walkMode,
                required double latitude,
                required double longitude,
                required DogTemperament temperament,
                String? note,
              }) async {
                chosenMode = walkMode;
                chosenTemp = temperament;
                chosenNote = note;
                return true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Радар прогулок'), findsOneWidget);
      expect(find.text('Арчи • Вельш-корги'), findsOneWidget);

      // Check mode cards
      expect(find.text('Открытый выгул'), findsOneWidget);
      expect(find.text('Приватный выгул'), findsOneWidget);
      expect(find.text('Тренировка'), findsOneWidget);

      // Tap "Приватный выгул"
      await tester.tap(find.text('Приватный выгул'));
      await tester.pumpAndSettle();

      // Tap "Энергичный" temperament
      await tester.tap(find.text('Энергичный'));
      await tester.pumpAndSettle();

      // Enter note
      await tester.enterText(find.byType(TextField), 'Гуляем у фонтана');
      await tester.pumpAndSettle();

      // Tap Start Walk
      final submitBtn = find.text('Выйти на прогулку');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(chosenMode, equals('private'));
      expect(chosenTemp, equals(DogTemperament.energetic));
      expect(chosenNote, equals('Гуляем у фонтана'));
    });
  });
}
