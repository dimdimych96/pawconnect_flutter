import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/breed_model.dart';
import 'package:pawconnect/models/pet_health_profile_model.dart';

void main() {
  group('Breed and Health Profile Models Tests', () {
    test('BreedModel parses json and watchouts correctly', () {
      final json = {
        'id': 'corgi',
        'name': 'Вельш-корги пемброк',
        'category': 'Пастушьи',
        'origin': 'Великобритания',
        'ideal_weight_min': 10.0,
        'ideal_weight_max': 12.5,
        'activity_min_minutes': 60,
        'default_temperament': 'playful',
        'health_watchouts': [
          {
            'title': 'Позвоночник и суставы (IVDD)',
            'risk_level': 'high',
            'advice': 'Избегайте прыжков с высоты',
          },
          {
            'title': 'Контроль веса',
            'risk_level': 'moderate',
            'advice': 'Не перекармливайте лакомствами',
          }
        ],
        'nutrition_advice': 'Склонны к перееданию',
      };

      final breed = BreedModel.fromJson(json);
      expect(breed.id, 'corgi');
      expect(breed.idealWeightRange, '10.0 – 12.5 кг');
      expect(breed.healthWatchouts.length, 2);
      expect(breed.healthWatchouts.first.isHighRisk, isTrue);

      final serialized = breed.toJson();
      expect(serialized['id'], 'corgi');
      expect((serialized['health_watchouts'] as List).length, 2);
    });

    test('BodyConditionHelper calculates kcal, food grams and evaluates BCS', () {
      expect(BodyConditionHelper.getLabel(3), 'Дефицит массы');
      expect(BodyConditionHelper.getLabel(5), 'Идеальная кондиция');
      expect(BodyConditionHelper.getLabel(6), 'Легкий избыток');
      expect(BodyConditionHelper.getLabel(8), 'Выраженное ожирение');

      // Calorie calculations
      final kcalIdeal = BodyConditionHelper.calculateDailyKcal(weightKg: 11.4, bcsScore: 5);
      expect(kcalIdeal, greaterThan(600));
      expect(kcalIdeal, lessThan(800));

      final foodGrams = BodyConditionHelper.estimateFoodGrams(kcalIdeal);
      expect(foodGrams, greaterThan(150));
      expect(foodGrams, lessThan(250));
    });

    test('ParasiteProtectionModel calculates progress ratio correctly', () {
      final json = {
        'product_name': 'Симпарика',
        'status': 'active',
        'days_remaining': 15,
        'total_days': 30,
        'last_applied_date': '2026-10-04T00:00:00Z',
        'next_due_date': '2026-11-03T00:00:00Z',
      };

      final parasite = ParasiteProtectionModel.fromJson(json);
      expect(parasite.productName, 'Симпарика');
      expect(parasite.daysRemaining, 15);
      expect(parasite.progressRatio, closeTo(0.5, 0.01));
    });

    test('PetHealthProfileModel serializes and updates via copyWith', () {
      final json = {
        'pet_id': 'pet-123',
        'pet_name': 'Арчи',
        'breed_id': 'corgi',
        'breed_name': 'Вельш-корги',
        'weight_kg': 11.4,
        'target_weight_kg': 11.0,
        'bcs_score': 5,
        'condition_label': 'Идеальная кондиция',
        'daily_kcal_target': 680,
        'daily_food_grams_estimate': 185,
        'activity_goal_minutes': 60,
        'ideal_weight_range': '10.0 – 12.5 кг',
        'milestones': [
          {
            'id': 'm-1',
            'title': 'Вакцинация DHPPi',
            'category': 'vaccine',
            'status': 'active',
            'due_date': '2027-04-12T00:00:00Z',
            'is_completed': false,
          }
        ],
      };

      final profile = PetHealthProfileModel.fromJson(json);
      expect(profile.petName, 'Арчи');
      expect(profile.weightKg, 11.4);
      expect(profile.milestones.length, 1);

      final copy = profile.copyWith(weightKg: 11.6, bcsScore: 5);
      expect(copy.weightKg, 11.6);
      expect(copy.petName, 'Арчи');
    });
  });
}
