import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/map/widgets/category_marker_widget.dart';
import 'package:pawconnect/features/map/widgets/marker_detail_sheet.dart';
import 'package:pawconnect/features/map/widgets/breach_alert_banner.dart';
import 'package:pawconnect/features/map/widgets/new_marker_modal.dart';
import 'package:pawconnect/models/map_marker_model.dart';

void main() {
  group('Hazard Radar Widget Tests', () {
    testWidgets('CategoryMarkerWidget renders danger icon and color', (tester) async {
      final marker = MapMarkerModel(
        id: 'hazard-1',
        type: 'danger',
        dangerType: 'poison',
        title: 'Отрава в парке',
        latitude: 55.0302,
        longitude: 82.9204,
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

      expect(find.byIcon(Icons.pest_control_rounded), findsOneWidget);
    });

    testWidgets('MarkerDetailSheet renders Hazard Radar deck and verification buttons', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? verifiedId;
      String? verifiedAction;

      final marker = MapMarkerModel(
        id: 'hazard-123',
        type: 'danger',
        dangerType: 'broken_glass',
        title: 'Битое стекло у площадки',
        description: 'Осколки бутылок на траве',
        latitude: 55.0302,
        longitude: 82.9204,
        confirmationsCount: 5,
        clearedCount: 2,
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
                  onVerifyHazard: (id, action) {
                    verifiedId = id;
                    verifiedAction = action;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('РАДАР БЕЗОПАСНОСТИ'), findsOneWidget);
      expect(find.text('Подтверждений: 5  •  Сообщений об очистке: 2'), findsOneWidget);
      expect(find.text('Актуально'), findsOneWidget);
      expect(find.text('Очищено'), findsOneWidget);

      await tester.ensureVisible(find.text('Актуально'));
      await tester.tap(find.text('Актуально'));
      await tester.pump();
      expect(verifiedId, 'hazard-123');
      expect(verifiedAction, 'confirm');

      await tester.ensureVisible(find.text('Очищено'));
      await tester.tap(find.text('Очищено'));
      await tester.pump();
      expect(verifiedAction, 'cleared');

      // Drain toast timer
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('BreachAlertBanner renders proximity hazard warning', (tester) async {
      bool mapTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BreachAlertBanner(
              hazardTitle: 'Отрава у фонтана',
              onNavigateToMap: () => mapTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('РАДАР БЕЗОПАСНОСТИ'), findsOneWidget);
      expect(find.text('Внимание: опасная зона в радиусе 300м (Отрава у фонтана)'), findsOneWidget);
      expect(find.text('На карту'), findsOneWidget);

      await tester.tap(find.text('На карту'));
      await tester.pump();
      expect(mapTapped, isTrue);
    });

    testWidgets('NewMarkerModal allows reporting a danger hazard', (tester) async {
      MapMarkerModel? createdMarker;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NewMarkerModal(
                currentLat: 55.0302,
                currentLng: 82.9204,
                onAdd: (marker) => createdMarker = marker,
              ),
            ),
          ),
        ),
      );

      // Select «⚠️ Опасность»
      await tester.tap(find.text('⚠️ Опасность'));
      await tester.pump();

      // Verify sub-selector appears and breed field is gone
      expect(find.text('Тип угрозы (Радар безопасности):'), findsOneWidget);
      expect(find.text('Порода (необязательно)'), findsNothing);

      // Select «🐕‍🦺 Стая собак»
      await tester.tap(find.text('🐕‍🦺 Стая собак'));
      await tester.pump();

      // Enter title
      await tester.enterText(
        find.widgetWithText(TextField, 'Что произошло? (например, Рассыпан яд на газоне)'),
        'Агрессивная стая у гаражей',
      );
      await tester.pump();

      // Submit
      await tester.tap(find.text('Опубликовать предупреждение'));
      await tester.pump();

      expect(createdMarker, isNotNull);
      expect(createdMarker!.type, 'danger');
      expect(createdMarker!.dangerType, 'aggressive_pack');
      expect(createdMarker!.title, 'Агрессивная стая у гаражей');
      expect(createdMarker!.confirmationsCount, 1);
    });
  });
}
