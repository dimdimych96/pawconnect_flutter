import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/map/widgets/companion_walk_marker.dart';
import 'package:pawconnect/features/map/widgets/category_marker_widget.dart';
import 'package:pawconnect/features/map/widgets/marker_detail_sheet.dart';
import 'package:pawconnect/models/map_marker_model.dart';
import 'package:pawconnect/models/walk_session_model.dart';

void main() {
  group('Companion Walk Marker and Deck Widget Tests', () {
    testWidgets('CompanionWalkMarker renders temperament badge and privacy indicator', (tester) async {
      bool tapped = false;
      final marker = MapMarkerModel(
        id: 'companion-1',
        type: 'companion',
        title: 'Шериф на прогулке',
        latitude: 55.0302,
        longitude: 82.9204,
        temperament: 'reactive',
        walkMode: 'private',
        isWalking: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompanionWalkMarker(
              marker: marker,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Verify temperament emoji
      expect(find.text('⛔'), findsOneWidget);
      // Verify private shield icon
      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);

      await tester.tap(find.byType(CompanionWalkMarker));
      expect(tapped, isTrue);
    });

    testWidgets('CategoryMarkerWidget delegates to CompanionWalkMarker for walking companions', (tester) async {
      final marker = MapMarkerModel(
        id: 'companion-2',
        type: 'companion',
        title: 'Майло гуляет',
        latitude: 55.0302,
        longitude: 82.9204,
        temperament: 'energetic',
        walkMode: 'open',
        isWalking: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryMarkerWidget(
              marker: marker,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CompanionWalkMarker), findsOneWidget);
      expect(find.text('⚡'), findsOneWidget);
    });

    testWidgets('MarkerDetailSheet renders Walk Radar companion deck and compatibility matrix', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? invitedMarkerId;
      final marker = MapMarkerModel(
        id: 'marker-buddy-1',
        type: 'companion',
        title: 'Бадди',
        breed: 'Золотистый ретривер',
        age: '2 года',
        latitude: 55.0302,
        longitude: 82.9204,
        temperament: 'playful',
        walkMode: 'open',
        isWalking: true,
        walkStartedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                MarkerDetailSheet(
                  marker: marker,
                  onClose: () {},
                  userTemperament: DogTemperament.energetic,
                  onInviteWalk: (id) => invitedMarkerId = id,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check walk radar header
      expect(find.text('РАДАР ПРОГУЛОК'), findsOneWidget);
      expect(find.text('🌿 Открытый выгул'), findsOneWidget);
      expect(find.text('Гуляет ~25 мин'), findsOneWidget);
      expect(find.text('Игривый'), findsOneWidget);

      // Check temperament compatibility (energetic + playful = high compatibility)
      expect(find.text('Отличная совместимость!'), findsOneWidget);

      // Check invite button
      final inviteBtn = find.text('Позвать на совместный выгул');
      expect(inviteBtn, findsOneWidget);

      await tester.ensureVisible(inviteBtn);
      await tester.tap(inviteBtn);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      expect(invitedMarkerId, equals('marker-buddy-1'));
    });
  });
}
