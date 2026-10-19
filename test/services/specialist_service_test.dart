import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/specialist_model.dart';
import 'package:pawconnect/services/specialist_service.dart';

void main() {
  group('SpecialistService Tests', () {
    test('SpecialistService returns mockSpecialists when allowMockFallback is true', () async {
      final service = SpecialistService(allowMockFallback: true);
      final specialists = await service.getSpecialists();

      expect(specialists, isNotEmpty);
      expect(specialists.length, greaterThanOrEqualTo(4));
      expect(specialists.any((s) => s.profession == 'cynologist'), isTrue);
      expect(specialists.any((s) => s.profession == 'dogsitter'), isTrue);
    });

    test('SpecialistService filters by profession locally in fallback mode', () async {
      final service = SpecialistService(allowMockFallback: true);
      final cynologists = await service.getSpecialists(profession: 'cynologist');

      expect(cynologists.every((s) => s.profession == 'cynologist'), isTrue);
    });

    test('SpecialistService.sendInquiry succeeds in fallback mode', () async {
      final service = SpecialistService(allowMockFallback: true);
      final result = await service.sendInquiry(
        'spec-anna-melnikova',
        message: 'Хотим записаться на занятие',
      );

      expect(result, isTrue);
    });
  });
}
