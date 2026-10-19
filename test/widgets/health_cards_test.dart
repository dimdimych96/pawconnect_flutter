import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/profile/widgets/body_condition_weight_card.dart';
import 'package:pawconnect/features/profile/widgets/breed_intelligence_card.dart';
import 'package:pawconnect/features/profile/widgets/smart_health_milestones_card.dart';
import 'package:pawconnect/models/breed_model.dart';
import 'package:pawconnect/models/pet_health_profile_model.dart';
import 'package:pawconnect/providers/health_provider.dart';
import 'package:pawconnect/services/health_service.dart';

class FakeHealthService extends HealthService {
  final PetHealthProfileModel profile;
  final BreedModel breed;

  FakeHealthService({required this.profile, required this.breed});

  @override
  Future<PetHealthProfileModel> getPetHealthProfile(String petId) async => profile;

  @override
  Future<BreedModel> getBreedDetail(String breedId) async => breed;

  @override
  Future<BreedModel?> matchBreedByName(String query) async => breed;

  @override
  Future<PetHealthProfileModel> updatePetCondition(
    String petId, {
    double? weightKg,
    double? targetWeightKg,
    int? bcsScore,
    int? activityGoalMinutes,
  }) async {
    return profile.copyWith(
      weightKg: weightKg,
      targetWeightKg: targetWeightKg,
      bcsScore: bcsScore,
      activityGoalMinutes: activityGoalMinutes,
    );
  }

  @override
  Future<PetHealthProfileModel> applyStandardMilestones(String petId) async => profile;
}

void main() {
  final testBreed = BreedModel(
    id: 'corgi',
    name: 'Вельш-корги пемброк',
    category: 'Пастушьи собаки',
    origin: 'Уэльс, Великобритания',
    idealWeightMin: 10.0,
    idealWeightMax: 14.0,
    activityMinMinutes: 75,
    defaultTemperament: 'playful',
    healthWatchouts: [
      HealthWatchoutModel(
        title: 'Позвоночник и суставы (IVDD)',
        riskLevel: 'high',
        advice: 'Избегайте прыжков с диванов и крутых лестниц.',
      ),
    ],
    nutritionAdvice: 'Склонны к перееданию. Контролируйте калории.',
  );

  final testProfile = PetHealthProfileModel(
    petId: 'pet-1',
    petName: 'Арчи',
    breedId: 'corgi',
    breedName: 'Вельш-корги пемброк',
    weightKg: 11.4,
    targetWeightKg: 11.0,
    bcsScore: 5,
    conditionLabel: 'Идеальная кондиция',
    dailyKcalTarget: 680,
    dailyFoodGramsEstimate: 184,
    activityGoalMinutes: 75,
    idealWeightRange: '10.0 – 14.0 кг',
    parasiteProtection: ParasiteProtectionModel(
      productName: 'Симпарика',
      status: 'active',
      daysRemaining: 18,
      totalDays: 35,
      lastAppliedDate: DateTime(2026, 9, 20),
      nextDueDate: DateTime(2026, 10, 25),
    ),
    milestones: [
      HealthMilestoneModel(
        id: 'v-1',
        title: 'Вакцинация от бешенства (Rabies)',
        category: 'vaccine',
        status: 'active',
        dueDate: DateTime(2026, 11, 15),
        isCompleted: false,
      ),
    ],
    healthWatchouts: testBreed.healthWatchouts,
    nutritionAdvice: testBreed.nutritionAdvice,
  );

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        healthServiceProvider.overrideWithValue(
          FakeHealthService(profile: testProfile, breed: testBreed),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  group('BodyConditionWeightCard Tests', () {
    testWidgets('renders weight metrics and BCS score 5', (tester) async {
      await tester.pumpWidget(createTestWidget(BodyConditionWeightCard(profile: testProfile)));
      await tester.pumpAndSettle();

      expect(find.text('Шкала кондиции & Вес'), findsOneWidget);
      expect(find.text('11.4'), findsOneWidget);
      expect(find.textContaining('10.0 – 14.0 кг'), findsOneWidget);
      expect(find.textContaining('5/9 • Идеальная кондиция'), findsOneWidget);
      expect(find.text('Записать'), findsOneWidget);
    });

    testWidgets('tapping "Записать" opens weight logger bottom sheet', (tester) async {
      await tester.pumpWidget(createTestWidget(BodyConditionWeightCard(profile: testProfile)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Записать'));
      await tester.pumpAndSettle();

      expect(find.text('Запись веса и кондиции'), findsOneWidget);
      expect(find.text('Сохранить изменения'), findsOneWidget);
    });
  });

  group('SmartHealthMilestonesCard Tests', () {
    testWidgets('renders parasite protection and milestones', (tester) async {
      await tester.pumpWidget(createTestWidget(SmartHealthMilestonesCard(profile: testProfile)));
      await tester.pumpAndSettle();

      expect(find.text('Умные вехи & Защита'), findsOneWidget);
      expect(find.text('Симпарика'), findsOneWidget);
      expect(find.text('Осталось 18 дн.'), findsOneWidget);
      expect(find.text('Вакцинация от бешенства (Rabies)'), findsOneWidget);
      expect(find.text('Автозаполнение вех по породе и возрасту'), findsOneWidget);
    });
  });

  group('BreedIntelligenceCard Tests', () {
    testWidgets('renders breed traits, watchouts and nutrition advice', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BreedIntelligenceCard(
                breed: testBreed,
                profile: testProfile,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Интеллект породы'), findsOneWidget);
      expect(find.text('Вельш-корги пемброк'), findsOneWidget);
      expect(find.text('75 мин/день'), findsOneWidget);
      expect(find.text('Позвоночник и суставы (IVDD)'), findsOneWidget);
      expect(find.text('Высокий риск'), findsOneWidget);
      expect(find.textContaining('Контролируйте калории'), findsOneWidget);
    });
  });
}
