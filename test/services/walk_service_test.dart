import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pawconnect/services/walk_service.dart';
import 'package:pawconnect/models/walk_session_model.dart';

void main() {
  group('WalkService Tests', () {
    test('WalkService provides fallback mock data when allowMockFallback is true', () async {
      final dio = Dio();
      final service = WalkService(dio: dio, allowMockFallback: true);

      // Start walk
      final session = await service.startWalk(
        petId: 'pet-archi-1',
        walkMode: 'open',
        latitude: 55.0302,
        longitude: 82.9204,
        note: 'Тестовая прогулка',
      );
      expect(session, isA<WalkSessionModel>());
      expect(session.petId, 'pet-archi-1');
      expect(session.walkMode, 'open');
      expect(session.isActive, true);

      // Get nearby companions
      final companions = await service.getNearbyCompanions(
        latitude: 55.0302,
        longitude: 82.9204,
      );
      expect(companions, isNotEmpty);
      expect(companions.first, isA<WalkingCompanionModel>());
      expect(companions.any((c) => c.temperament == DogTemperament.energetic), true);

      // Send walk invite
      final invite = await service.sendWalkInvite(
        toPetId: companions.first.petId,
        message: 'Пойдем побегаем!',
      );
      expect(invite, isA<WalkInvitationModel>());
      expect(invite.toPetId, companions.first.petId);

      // Stop walk
      final stopped = await service.stopWalk(petId: 'pet-archi-1');
      expect(stopped.isActive, false);
    });

    test('WalkService rethrows error when allowMockFallback is false', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9999/api/v1', connectTimeout: const Duration(milliseconds: 50)));
      final service = WalkService(dio: dio, allowMockFallback: false);

      expect(
        () => service.startWalk(
          petId: 'pet-1',
          latitude: 55.0,
          longitude: 82.0,
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}
