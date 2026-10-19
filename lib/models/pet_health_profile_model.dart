import 'breed_model.dart';

class ParasiteProtectionModel {
  final String productName;
  final String status; // 'active', 'expiring_soon', 'expired'
  final int daysRemaining;
  final int totalDays;
  final DateTime lastAppliedDate;
  final DateTime nextDueDate;

  ParasiteProtectionModel({
    required this.productName,
    required this.status,
    required this.daysRemaining,
    required this.totalDays,
    required this.lastAppliedDate,
    required this.nextDueDate,
  });

  factory ParasiteProtectionModel.fromJson(Map<String, dynamic> json) {
    return ParasiteProtectionModel(
      productName: json['product_name'] ?? json['productName'] ?? 'Симпарика',
      status: json['status'] ?? 'active',
      daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? (json['daysRemaining'] as num?)?.toInt() ?? 18,
      totalDays: (json['total_days'] as num?)?.toInt() ?? (json['totalDays'] as num?)?.toInt() ?? 35,
      lastAppliedDate: DateTime.tryParse(json['last_applied_date'] ?? json['lastAppliedDate'] ?? '') ?? DateTime.now().subtract(const Duration(days: 17)),
      nextDueDate: DateTime.tryParse(json['next_due_date'] ?? json['nextDueDate'] ?? '') ?? DateTime.now().add(const Duration(days: 18)),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_name': productName,
        'status': status,
        'days_remaining': daysRemaining,
        'total_days': totalDays,
        'last_applied_date': lastAppliedDate.toIso8601String(),
        'next_due_date': nextDueDate.toIso8601String(),
      };

  double get progressRatio => (totalDays - daysRemaining).clamp(0, totalDays) / totalDays;
}

class HealthMilestoneModel {
  final String id;
  final String title;
  final String category; // 'vaccine', 'parasite', 'deworming', 'vet'
  final String status; // 'active', 'due_soon', 'overdue', 'completed'
  final DateTime dueDate;
  final bool isCompleted;

  HealthMilestoneModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory HealthMilestoneModel.fromJson(Map<String, dynamic> json) {
    return HealthMilestoneModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'vaccine',
      status: json['status'] ?? 'active',
      dueDate: DateTime.tryParse(json['due_date'] ?? json['dueDate'] ?? '') ?? DateTime.now(),
      isCompleted: json['is_completed'] ?? json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'status': status,
        'due_date': dueDate.toIso8601String(),
        'is_completed': isCompleted,
      };
}

class PetHealthProfileModel {
  final String petId;
  final String petName;
  final String? breedId;
  final String? breedName;
  final double? weightKg;
  final double? targetWeightKg;
  final int bcsScore;
  final String conditionLabel;
  final int dailyKcalTarget;
  final int dailyFoodGramsEstimate;
  final int activityGoalMinutes;
  final String? idealWeightRange;
  final ParasiteProtectionModel? parasiteProtection;
  final List<HealthMilestoneModel> milestones;
  final List<HealthWatchoutModel> healthWatchouts;
  final String? nutritionAdvice;

  PetHealthProfileModel({
    required this.petId,
    required this.petName,
    this.breedId,
    this.breedName,
    this.weightKg,
    this.targetWeightKg,
    this.bcsScore = 5,
    required this.conditionLabel,
    required this.dailyKcalTarget,
    required this.dailyFoodGramsEstimate,
    this.activityGoalMinutes = 60,
    this.idealWeightRange,
    this.parasiteProtection,
    this.milestones = const [],
    this.healthWatchouts = const [],
    this.nutritionAdvice,
  });

  factory PetHealthProfileModel.fromJson(Map<String, dynamic> json) {
    final milestonesRaw = (json['milestones'] as List<dynamic>?) ?? [];
    final watchoutsRaw = (json['health_watchouts'] as List<dynamic>?) ??
        (json['healthWatchouts'] as List<dynamic>?) ??
        [];
    final parasiteRaw = json['parasite_protection'] ?? json['parasiteProtection'];

    return PetHealthProfileModel(
      petId: json['pet_id']?.toString() ?? json['petId']?.toString() ?? '',
      petName: json['pet_name'] ?? json['petName'] ?? '',
      breedId: json['breed_id'] ?? json['breedId'],
      breedName: json['breed_name'] ?? json['breedName'],
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? (json['weightKg'] as num?)?.toDouble(),
      targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble() ?? (json['targetWeightKg'] as num?)?.toDouble(),
      bcsScore: (json['bcs_score'] as num?)?.toInt() ?? (json['bcsScore'] as num?)?.toInt() ?? 5,
      conditionLabel: json['condition_label'] ?? json['conditionLabel'] ?? 'Идеальная кондиция',
      dailyKcalTarget: (json['daily_kcal_target'] as num?)?.toInt() ?? (json['dailyKcalTarget'] as num?)?.toInt() ?? 680,
      dailyFoodGramsEstimate: (json['daily_food_grams_estimate'] as num?)?.toInt() ?? (json['dailyFoodGramsEstimate'] as num?)?.toInt() ?? 185,
      activityGoalMinutes: (json['activity_goal_minutes'] as num?)?.toInt() ?? (json['activityGoalMinutes'] as num?)?.toInt() ?? 60,
      idealWeightRange: json['ideal_weight_range'] ?? json['idealWeightRange'],
      parasiteProtection: parasiteRaw != null ? ParasiteProtectionModel.fromJson(parasiteRaw as Map<String, dynamic>) : null,
      milestones: milestonesRaw.map((m) => HealthMilestoneModel.fromJson(m as Map<String, dynamic>)).toList(),
      healthWatchouts: watchoutsRaw.map((w) => HealthWatchoutModel.fromJson(w as Map<String, dynamic>)).toList(),
      nutritionAdvice: json['nutrition_advice'] ?? json['nutritionAdvice'],
    );
  }

  Map<String, dynamic> toJson() => {
        'pet_id': petId,
        'pet_name': petName,
        'breed_id': breedId,
        'breed_name': breedName,
        'weight_kg': weightKg,
        'target_weight_kg': targetWeightKg,
        'bcs_score': bcsScore,
        'condition_label': conditionLabel,
        'daily_kcal_target': dailyKcalTarget,
        'daily_food_grams_estimate': dailyFoodGramsEstimate,
        'activity_goal_minutes': activityGoalMinutes,
        'ideal_weight_range': idealWeightRange,
        'parasite_protection': parasiteProtection?.toJson(),
        'milestones': milestones.map((m) => m.toJson()).toList(),
        'health_watchouts': healthWatchouts.map((w) => w.toJson()).toList(),
        'nutrition_advice': nutritionAdvice,
      };

  PetHealthProfileModel copyWith({
    String? petId,
    String? petName,
    String? breedId,
    String? breedName,
    double? weightKg,
    double? targetWeightKg,
    int? bcsScore,
    String? conditionLabel,
    int? dailyKcalTarget,
    int? dailyFoodGramsEstimate,
    int? activityGoalMinutes,
    String? idealWeightRange,
    ParasiteProtectionModel? parasiteProtection,
    List<HealthMilestoneModel>? milestones,
    List<HealthWatchoutModel>? healthWatchouts,
    String? nutritionAdvice,
  }) {
    return PetHealthProfileModel(
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      breedId: breedId ?? this.breedId,
      breedName: breedName ?? this.breedName,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      bcsScore: bcsScore ?? this.bcsScore,
      conditionLabel: conditionLabel ?? this.conditionLabel,
      dailyKcalTarget: dailyKcalTarget ?? this.dailyKcalTarget,
      dailyFoodGramsEstimate: dailyFoodGramsEstimate ?? this.dailyFoodGramsEstimate,
      activityGoalMinutes: activityGoalMinutes ?? this.activityGoalMinutes,
      idealWeightRange: idealWeightRange ?? this.idealWeightRange,
      parasiteProtection: parasiteProtection ?? this.parasiteProtection,
      milestones: milestones ?? this.milestones,
      healthWatchouts: healthWatchouts ?? this.healthWatchouts,
      nutritionAdvice: nutritionAdvice ?? this.nutritionAdvice,
    );
  }
}
