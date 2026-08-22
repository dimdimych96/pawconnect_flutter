import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pawconnect/core/theme/app_theme.dart';
import 'package:pawconnect/features/map/widgets/liquid_glass_bottom_sheet.dart';
import 'package:pawconnect/features/map/widgets/turn_by_turn_hud.dart';
import 'package:pawconnect/models/route_model.dart';

void main() {
  testWidgets('LiquidGlassBottomSheet renders with pure vector icons and triggers navigation', (tester) async {
    bool startedNavigation = false;
    String selectedMode = 'walk';

    final testRoute = ActiveRouteModel(
      destinationTitle: 'Ошейник Макса',
      destinationType: 'collar',
      startPoint: const LatLng(55.0285, 82.9165),
      endPoint: const LatLng(55.0302, 82.9204),
      waypoints: const [
        LatLng(55.0285, 82.9165),
        LatLng(55.0302, 82.9204),
      ],
      distanceMeters: 320,
      durationMinutes: 4,
      transportMode: 'walk',
      steps: const [
        RouteStep(
          instruction: 'Двигайтесь прямо',
          streetName: 'Аллея',
          distanceMeters: 80,
          maneuverType: ManeuverType.straight,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: LiquidGlassBottomSheet(
            route: testRoute,
            activeMode: selectedMode,
            onModeSelected: (mode) => selectedMode = mode,
            onStartNavigation: () => startedNavigation = true,
            onClose: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Stats
    expect(find.text('Ошейник Макса'), findsOneWidget);
    expect(find.text('4 мин • 320 м • Безопасный путь'), findsOneWidget);

    // Verify Vector Mode Cards exist
    expect(find.text('Пешком'), findsOneWidget);
    expect(find.text('Парк / Выгул'), findsOneWidget);
    expect(find.text('На авто'), findsOneWidget);

    // Verify CTA Button
    expect(find.text('В путь (Начать навигацию)'), findsOneWidget);

    // Tap CTA
    await tester.tap(find.text('В путь (Начать навигацию)'));
    await tester.pump();

    expect(startedNavigation, isTrue);
  });

  testWidgets('TurnByTurnHud renders top maneuver capsule and bottom ETA bar', (tester) async {
    bool endedNavigation = false;

    final testRoute = ActiveRouteModel(
      destinationTitle: 'Ошейник Макса',
      destinationType: 'collar',
      startPoint: const LatLng(55.0285, 82.9165),
      endPoint: const LatLng(55.0302, 82.9204),
      waypoints: const [
        LatLng(55.0285, 82.9165),
        LatLng(55.0302, 82.9204),
      ],
      distanceMeters: 320,
      durationMinutes: 4,
      transportMode: 'walk',
      steps: const [
        RouteStep(
          instruction: 'направо на аллею',
          streetName: 'Аллея Центрального парка',
          distanceMeters: 80,
          maneuverType: ManeuverType.turnRight,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: TurnByTurnHud(
            route: testRoute,
            currentStepIndex: 0,
            onNextStep: () {},
            onPrevStep: () {},
            onEndNavigation: () => endedNavigation = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify maneuver text
    expect(find.text('Через 80 м направо на аллею'), findsOneWidget);
    expect(find.text('Аллея Центрального парка'), findsOneWidget);

    // Verify pace indicator
    expect(find.text('4.8 км/ч'), findsOneWidget);

    // Verify ETA & End Button
    expect(find.text('4 мин'), findsOneWidget);
    expect(find.text('Завершить'), findsOneWidget);

    // Tap End
    await tester.tap(find.text('Завершить'));
    await tester.pump();

    expect(endedNavigation, isTrue);
  });
}
