import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../models/breed_model.dart';
import '../models/pet_health_profile_model.dart';

class HealthService {
  final Dio _dio;
  final bool _allowMockFallback;

  HealthService({Dio? dio, bool? allowMockFallback})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 4),
              ),
            ),
        _allowMockFallback = allowMockFallback ?? AppConfig.enableOfflineMocks;

  static final BreedModel mockCorgiBreed = BreedModel(
    id: 'corgi',
    name: 'Вельш-корги пемброк',
    nameEn: 'Welsh Corgi Pembroke',
    category: 'Пастушьи',
    origin: 'Великобритания',
    idealWeightMin: 10.0,
    idealWeightMax: 12.5,
    activityMinMinutes: 60,
    defaultTemperament: 'playful',
    healthWatchouts: [
      HealthWatchoutModel(
        title: 'Позвоночник и суставы (IVDD)',
        riskLevel: 'high',
        advice: 'Избегайте прыжков с диванов и крутых лестниц. Укрепляйте мышечный корсет плаванием и равномерной ходьбой.',
      ),
      HealthWatchoutModel(
        title: 'Склонность к набору веса',
        riskLevel: 'high',
        advice: 'Даже +1 кг дает избыточную нагрузку на спину. Взвешивайте порции на кухонных весах.',
      ),
      HealthWatchoutModel(
        title: 'Чувствительные уши',
        riskLevel: 'moderate',
        advice: 'Осматривайте ушные раковины после выгула в высокой траве и скверах.',
      ),
    ],
    nutritionAdvice: 'Склонны к перееданию. Рекомендуется рацион с белком 24–28% и добавками Омега-3 для гибкости суставов.',
    description: 'Энергичная, жизнерадостная собака с высоким интеллектом и преданным характером.',
  );

  static final PetHealthProfileModel mockHealthProfile = PetHealthProfileModel(
    petId: 'pet-archi-1',
    petName: 'Арчи',
    breedId: 'corgi',
    breedName: 'Вельш-корги пемброк',
    weightKg: 11.4,
    targetWeightKg: 11.0,
    bcsScore: 5,
    conditionLabel: 'Идеальная кондиция',
    dailyKcalTarget: 680,
    dailyFoodGramsEstimate: 185,
    activityGoalMinutes: 60,
    idealWeightRange: '10.0 – 12.5 кг',
    parasiteProtection: ParasiteProtectionModel(
      productName: 'Симпарика',
      status: 'active',
      daysRemaining: 18,
      totalDays: 35,
      lastAppliedDate: DateTime.now().subtract(const Duration(days: 17)),
      nextDueDate: DateTime.now().add(const Duration(days: 18)),
    ),
    milestones: [
      HealthMilestoneModel(
        id: 'rem-std-1',
        title: 'Комплексная вакцинация (DHPPi + Rabies)',
        category: 'vaccine',
        status: 'active',
        dueDate: DateTime.now().add(const Duration(days: 210)),
        isCompleted: false,
      ),
      HealthMilestoneModel(
        id: 'rem-std-2',
        title: 'Защита от клещей и блох (Симпарика)',
        category: 'parasite',
        status: 'active',
        dueDate: DateTime.now().add(const Duration(days: 18)),
        isCompleted: false,
      ),
      HealthMilestoneModel(
        id: 'rem-std-3',
        title: 'Профилактическая дегельминтизация',
        category: 'deworming',
        status: 'active',
        dueDate: DateTime.now().add(const Duration(days: 55)),
        isCompleted: false,
      ),
    ],
    healthWatchouts: mockCorgiBreed.healthWatchouts,
    nutritionAdvice: mockCorgiBreed.nutritionAdvice,
  );

  Future<List<BreedModel>> getBreeds({String? query, String? category}) async {
    try {
      final response = await _dio.get(
        '/breeds',
        queryParameters: {
          if (query != null) 'query': query,
          if (category != null) 'category': category,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((b) => BreedModel.fromJson(b as Map<String, dynamic>)).toList();
      }
    } on DioException catch (_) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    return [mockCorgiBreed];
  }

  Future<BreedModel> getBreedDetail(String breedId) async {
    try {
      final response = await _dio.get('/breeds/$breedId');
      if (response.statusCode == 200 && response.data != null) {
        return BreedModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (_) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    return mockCorgiBreed;
  }

  Future<BreedModel?> matchBreedByName(String name) async {
    try {
      final response = await _dio.get(
        '/breeds/match/by-name',
        queryParameters: {'name': name},
      );
      if (response.statusCode == 200 && response.data != null) {
        return BreedModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (_) {
      if (!_allowMockFallback) {
        rethrow;
      }
      return mockCorgiBreed;
    }
  }

  Future<PetHealthProfileModel> getPetHealthProfile(String petId) async {
    try {
      final response = await _dio.get('/health/pets/$petId');
      if (response.statusCode == 200 && response.data != null) {
        return PetHealthProfileModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (_) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    return mockHealthProfile;
  }

  Future<PetHealthProfileModel> updatePetCondition(
    String petId, {
    double? weightKg,
    double? targetWeightKg,
    int? bcsScore,
    int? activityGoalMinutes,
  }) async {
    try {
      final response = await _dio.put(
        '/health/pets/$petId/condition',
        data: {
          if (weightKg != null) 'weight_kg': weightKg,
          if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
          if (bcsScore != null) 'bcs_score': bcsScore,
          if (activityGoalMinutes != null) 'activity_goal_minutes': activityGoalMinutes,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return PetHealthProfileModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (_) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }

    final newWeight = weightKg ?? mockHealthProfile.weightKg ?? 11.4;
    final newBcs = bcsScore ?? mockHealthProfile.bcsScore;
    final kcal = BodyConditionHelper.calculateDailyKcal(weightKg: newWeight, bcsScore: newBcs);

    return mockHealthProfile.copyWith(
      weightKg: newWeight,
      targetWeightKg: targetWeightKg ?? mockHealthProfile.targetWeightKg,
      bcsScore: newBcs,
      conditionLabel: BodyConditionHelper.getLabel(newBcs),
      dailyKcalTarget: kcal,
      dailyFoodGramsEstimate: BodyConditionHelper.estimateFoodGrams(kcal),
      activityGoalMinutes: activityGoalMinutes ?? mockHealthProfile.activityGoalMinutes,
    );
  }

  Future<PetHealthProfileModel> applyStandardMilestones(String petId) async {
    try {
      final response = await _dio.post('/health/pets/$petId/apply-milestones');
      if (response.statusCode == 200 && response.data != null) {
        return PetHealthProfileModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (_) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
    return mockHealthProfile;
  }
}
