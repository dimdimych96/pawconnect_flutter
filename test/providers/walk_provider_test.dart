import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pawconnect/providers/walk_provider.dart';
import 'package:pawconnect/services/walk_service.dart';
import 'package:pawconnect/models/walk_session_model.dart';

void main() {
  group('WalkNotifier Tests', () {
    late WalkService service;
    late WalkNotifier notifier;

    setUp(() {
      service = WalkService(dio: Dio(), allowMockFallback: true);
      notifier = WalkNotifier(service);
    });

    tearDown(() {
      notifier.dispose();
    });

    test('Initial state is not walking with default temperament', () {
      expect(notifier.state.isWalking, isFalse);
      expect(notifier.state.activeWalk, isNull);
      expect(notifier.state.userPetTemperament, DogTemperament.playful);
      expect(notifier.state.nearbyCompanions, isEmpty);
    });

    test('loadNearbyCompanions populates nearby walking dogs', () async {
      await notifier.loadNearbyCompanions();
      expect(notifier.state.nearbyCompanions, isNotEmpty);
      expect(notifier.state.isLoading, isFalse);
    });

    test('startWalk updates activeWalk and isWalking flag', () async {
      final success = await notifier.startWalk(
        petId: 'pet-1',
        petName: 'Арчи',
        walkMode: 'open',
        latitude: 55.0302,
        longitude: 82.9204,
        temperament: DogTemperament.energetic,
      );

      expect(success, isTrue);
      expect(notifier.state.isWalking, isTrue);
      expect(notifier.state.activeWalk?.petName, 'Арчи');
      expect(notifier.state.userPetTemperament, DogTemperament.energetic);
    });

    test('stopWalk clears activeWalk and sets isWalking to false', () async {
      await notifier.startWalk(
        petId: 'pet-1',
        petName: 'Арчи',
        latitude: 55.0302,
        longitude: 82.9204,
      );
      expect(notifier.state.isWalking, isTrue);

      final stopped = await notifier.stopWalk();
      expect(stopped, isTrue);
      expect(notifier.state.isWalking, isFalse);
      expect(notifier.state.activeWalk, isNull);
    });

    test('selectCompanion updates selected companion in state', () {
      final companion = WalkingCompanionModel(
        petId: 'pet-c-1',
        petName: 'Майло',
        ownerName: 'Дмитрий',
        temperament: DogTemperament.energetic,
        walkMode: 'open',
        latitude: 55.0310,
        longitude: 82.9220,
        distanceMeters: 150,
        walkStartedAt: DateTime.now(),
        minutesWalking: 10,
      );

      notifier.selectCompanion(companion);
      expect(notifier.state.selectedCompanion?.petName, 'Майло');

      notifier.selectCompanion(null);
      expect(notifier.state.selectedCompanion, isNull);
    });

    test('sendWalkInvite returns true on success', () async {
      final sent = await notifier.sendWalkInvite(
        toPetId: 'pet-companion-1',
        message: 'Пойдем на собачью площадку!',
      );
      expect(sent, isTrue);
    });
  });
}
