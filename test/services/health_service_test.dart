import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pawconnect/services/health_service.dart';
import 'package:pawconnect/models/breed_model.dart';
import 'package:pawconnect/models/pet_health_profile_model.dart';

void main() {
  group('HealthService Tests', () {
    test('HealthService returns fallback breed and health profile when allowMockFallback is true', () async {
      final dio = Dio();
      final service = HealthService(dio: dio, allowMockFallback: true);

      final breeds = await service.getBreeds();
      expect(breeds, isNotEmpty);
      expect(breeds.first, isA<BreedModel>());
      expect(breeds.first.id, 'corgi');

      final corgi = await service.getBreedDetail('corgi');
      expect(corgi.name, contains('корги'));
      expect(corgi.healthWatchouts, isNotEmpty);

      final profile = await service.getPetHealthProfile('pet-archi-1');
      expect(profile, isA<PetHealthProfileModel>());
      expect(profile.petName, 'Арчи');
      expect(profile.bcsScore, 5);

      final updated = await service.updatePetCondition('pet-archi-1', weightKg: 12.0, bcsScore: 6);
      expect(updated.weightKg, 12.0);
      expect(updated.bcsScore, 6);
      expect(updated.conditionLabel, 'Легкий избыток');

      final milestonesProfile = await service.applyStandardMilestones('pet-archi-1');
      expect(milestonesProfile.milestones, isNotEmpty);
    });

    test('HealthService rethrows error when allowMockFallback is false', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:9999/api/v1', connectTimeout: const Duration(milliseconds: 50)));
      final service = HealthService(dio: dio, allowMockFallback: false);

      expect(() => service.getBreeds(), throwsA(isA<DioException>()));
    });
  });
}
