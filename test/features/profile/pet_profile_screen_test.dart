import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/profile/pet_profile_screen.dart';
import 'package:pawconnect/features/profile/widgets/body_condition_weight_card.dart';
import 'package:pawconnect/features/profile/widgets/breed_intelligence_card.dart';
import 'package:pawconnect/features/profile/widgets/smart_health_milestones_card.dart';
import 'package:pawconnect/models/breed_model.dart';
import 'package:pawconnect/models/pet_health_profile_model.dart';
import 'package:pawconnect/models/pet_reminder_model.dart';
import 'package:pawconnect/providers/health_provider.dart';
import 'package:pawconnect/providers/reminders_provider.dart';
import 'package:pawconnect/services/health_service.dart';
import 'package:pawconnect/services/reminder_service.dart';

class FakeReminderService extends ReminderService {
  @override
  Future<List<PetReminderModel>> getReminders() async => ReminderService.mockReminders;
}

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
        advice: 'Избегайте прыжков с диванов.',
      ),
    ],
    nutritionAdvice: 'Склонны к перееданию.',
  );

  final testProfile = PetHealthProfileModel(
    petId: 'pet-archi-1',
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
        id: 'm-1',
        title: 'Вакцинация от бешенства (Rabies)',
        category: 'vaccine',
        status: 'active',
        dueDate: DateTime(2026, 11, 15),
      ),
    ],
    healthWatchouts: testBreed.healthWatchouts,
    nutritionAdvice: testBreed.nutritionAdvice,
  );

  testWidgets('PetProfileScreen renders passport, health BCS card, smart milestones, and breed intelligence', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reminderServiceProvider.overrideWithValue(FakeReminderService()),
          healthServiceProvider.overrideWithValue(
            FakeHealthService(profile: testProfile, breed: testBreed),
          ),
        ],
        child: const MaterialApp(
          home: PetProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Passport Header
    expect(find.text('Паспорт & Ошейник'), findsOneWidget);

    // Health cards rendered
    expect(find.byType(BodyConditionWeightCard), findsOneWidget);
    expect(find.byType(SmartHealthMilestonesCard), findsOneWidget);
    expect(find.byType(BreedIntelligenceCard), findsOneWidget);

    // Health contents
    expect(find.text('Шкала кондиции & Вес'), findsOneWidget);
    expect(find.text('Умные вехи & Защита'), findsOneWidget);
    expect(find.text('Интеллект породы'), findsOneWidget);
    expect(find.text('Вельш-корги пемброк'), findsOneWidget);

    // Collar & Reminders sections
    expect(find.text('GPS-Ошейник PawConnect'), findsOneWidget);
    expect(find.text('Вет-календарь'), findsOneWidget);
  });
}
