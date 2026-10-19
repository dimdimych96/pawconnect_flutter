import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/providers/specialist_provider.dart';
import 'package:pawconnect/services/specialist_service.dart';

void main() {
  group('SpecialistsNotifier Tests', () {
    test('Loads specialists and updates profession filter', () async {
      final service = SpecialistService(allowMockFallback: true);
      final notifier = SpecialistsNotifier(service);

      await Future.delayed(const Duration(milliseconds: 50));

      final state = notifier.state;
      expect(state.specialistsAsync.hasValue, isTrue);
      expect(state.specialistsAsync.value!.length, greaterThanOrEqualTo(4));

      // Filter by cynologist
      await notifier.setProfession('cynologist');
      expect(notifier.state.selectedProfession, 'cynologist');
      expect(
        notifier.state.specialistsAsync.value!.every((s) => s.profession == 'cynologist'),
        isTrue,
      );

      // Reset filter
      await notifier.setProfession('all');
      expect(notifier.state.selectedProfession, 'all');
      expect(notifier.state.specialistsAsync.value!.length, greaterThanOrEqualTo(4));
    });

    test('sendInquiry sends booking inquiry successfully', () async {
      final service = SpecialistService(allowMockFallback: true);
      final notifier = SpecialistsNotifier(service);

      final success = await notifier.sendInquiry(
        'spec-anna-melnikova',
        message: 'Добрый день! Интересует выезд на дом.',
      );

      expect(success, isTrue);
    });
  });
}
