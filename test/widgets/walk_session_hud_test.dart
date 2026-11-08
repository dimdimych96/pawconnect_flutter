import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/map/widgets/walk_session_hud.dart';
import 'package:pawconnect/models/walk_session_model.dart';

void main() {
  group('WalkSessionHud Widget Tests', () {
    testWidgets('WalkSessionHud displays pet name, mode, temperament icon and calls onStopWalk', (tester) async {
      bool stopped = false;
      final session = WalkSessionModel(
        id: 'session-hud-1',
        petId: 'pet-archi-1',
        userId: 'usr-1',
        walkMode: 'open',
        latitude: 55.0302,
        longitude: 82.9204,
        startedAt: DateTime.now().subtract(const Duration(minutes: 5, seconds: 30)),
        petName: 'Арчи',
        petBreed: 'Вельш-корги',
        temperament: DogTemperament.playful,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WalkSessionHud(
                  session: session,
                  temperament: DogTemperament.playful,
                  onStopWalk: () => stopped = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      // Check pet name, mode, and vector icon in temperament color
      expect(find.text('Арчи'), findsOneWidget);
      expect(find.text('Открытый'), findsOneWidget);
      expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.pets_rounded));
      expect(iconWidget.color, equals(DogTemperament.playful.color));
      expect(find.text('• На радаре'), findsOneWidget);

      // Check stop button
      final stopBtn = find.text('Завершить');
      expect(stopBtn, findsOneWidget);

      await tester.tap(stopBtn);
      await tester.pump();

      expect(stopped, isTrue);
    });

    testWidgets('WalkSessionHud handles private mode correctly', (tester) async {
      final session = WalkSessionModel(
        id: 'session-hud-2',
        petId: 'pet-milo-2',
        userId: 'usr-2',
        walkMode: 'private',
        latitude: 55.0302,
        longitude: 82.9204,
        startedAt: DateTime.now(),
        petName: 'Майло',
        temperament: DogTemperament.shy,
        isPrivate: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                WalkSessionHud(
                  session: session,
                  temperament: DogTemperament.shy,
                  onStopWalk: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Майло'), findsOneWidget);
      expect(find.text('Приватный'), findsOneWidget);
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.pets_rounded));
      expect(iconWidget.color, equals(DogTemperament.shy.color));
    });
  });
}
