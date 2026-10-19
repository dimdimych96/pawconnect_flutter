import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/search/search_screen.dart';
import 'package:pawconnect/features/search/widgets/specialist_card.dart';
import 'package:pawconnect/features/search/widgets/specialist_inquiry_modal.dart';
import 'package:pawconnect/models/specialist_model.dart';
import 'package:pawconnect/providers/specialist_provider.dart';
import 'package:pawconnect/services/specialist_service.dart';

class FakeSpecialistService extends SpecialistService {
  @override
  Future<List<SpecialistModel>> getSpecialists({
    String? profession,
    String? district,
    String? query,
  }) async {
    return SpecialistService.mockSpecialists.where((s) {
      if (profession != null && profession != 'all' && s.profession != profession) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<bool> sendInquiry(
    String specialistId, {
    required String message,
    String? petId,
    String? preferredDate,
  }) async {
    return true;
  }
}

void main() {
  Widget createSearchScreen() {
    return ProviderScope(
      overrides: [
        specialistServiceProvider.overrideWithValue(FakeSpecialistService()),
      ],
      child: const MaterialApp(
        home: SearchScreen(),
      ),
    );
  }

  testWidgets('SearchScreen renders filter chips and displays verified specialists', (tester) async {
    await tester.pumpWidget(createSearchScreen());
    await tester.pumpAndSettle();

    // Verify chips exist
    expect(find.byKey(const ValueKey('search_chip_all')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_chip_cynologist')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_chip_dogsitter')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_chip_groomer')), findsOneWidget);
    expect(find.byKey(const ValueKey('search_chip_vet')), findsOneWidget);

    // Verify specialist cards rendered in 'all' view
    expect(find.byType(SpecialistCard), findsWidgets);
    expect(find.text('Анна Мельникова'), findsOneWidget);

    // Filter by Cynologist
    await tester.tap(find.byKey(const ValueKey('search_chip_cynologist')));
    await tester.pumpAndSettle();

    expect(find.text('Анна Мельникова'), findsOneWidget);
    expect(find.text('Елена Смирнова'), findsNothing);

    // Filter by Dogsitter
    await tester.tap(find.byKey(const ValueKey('search_chip_dogsitter')));
    await tester.pumpAndSettle();

    expect(find.text('Елена Смирнова'), findsOneWidget);
    expect(find.text('Анна Мельникова'), findsNothing);

    // Tap «Связаться» on Elena Smirnova card to open Inquiry modal
    final inquireBtn = find.text('Связаться');
    expect(inquireBtn, findsOneWidget);
    await tester.tap(inquireBtn);
    await tester.pumpAndSettle();

    expect(find.byType(SpecialistInquiryModal), findsOneWidget);
    expect(find.text('Тема обращения'), findsOneWidget);
    expect(find.text('Отправить заявку'), findsOneWidget);
  });
}
