import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pawconnect/providers/health_provider.dart';
import 'package:pawconnect/services/health_service.dart';

void main() {
  group('HealthNotifier Tests', () {
    late HealthService service;
    late HealthNotifier notifier;

    setUp(() {
      service = HealthService(dio: Dio(), allowMockFallback: true);
      notifier = HealthNotifier(service);
    });

    tearDown(() {
      notifier.dispose();
    });

    test('Initial state loads default profile and breed', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(notifier.state.profile, isNotNull);
      expect(notifier.state.profile?.petName, 'Арчи');
      expect(notifier.state.currentBreed, isNotNull);
      expect(notifier.state.currentBreed?.id, 'corgi');
    });

    test('updateCondition updates weight and recalculates condition', () async {
      final success = await notifier.updateCondition(
        petId: 'pet-archi-1',
        weightKg: 12.2,
        bcsScore: 6,
      );

      expect(success, isTrue);
      expect(notifier.state.profile?.weightKg, 12.2);
      expect(notifier.state.profile?.bcsScore, 6);
      expect(notifier.state.profile?.conditionLabel, 'Легкий избыток');
    });

    test('applyStandardMilestones updates milestones in profile', () async {
      final success = await notifier.applyStandardMilestones('pet-archi-1');
      expect(success, isTrue);
      expect(notifier.state.profile?.milestones, isNotEmpty);
    });
  });
}
