import 'dart:math' as math;
import 'package:flutter/material.dart';

class HealthWatchoutModel {
  final String title;
  final String riskLevel; // 'high', 'moderate'
  final String advice;

  HealthWatchoutModel({
    required this.title,
    required this.riskLevel,
    required this.advice,
  });

  factory HealthWatchoutModel.fromJson(Map<String, dynamic> json) {
    return HealthWatchoutModel(
      title: json['title'] ?? '',
      riskLevel: json['risk_level'] ?? json['riskLevel'] ?? 'moderate',
      advice: json['advice'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'risk_level': riskLevel,
        'advice': advice,
      };

  bool get isHighRisk => riskLevel.toLowerCase() == 'high';
}

class BreedModel {
  final String id;
  final String name;
  final String? nameEn;
  final String category;
  final String origin;
  final double idealWeightMin;
  final double idealWeightMax;
  final int activityMinMinutes;
  final String defaultTemperament;
  final List<HealthWatchoutModel> healthWatchouts;
  final String nutritionAdvice;
  final String? description;

  BreedModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.category,
    required this.origin,
    required this.idealWeightMin,
    required this.idealWeightMax,
    required this.activityMinMinutes,
    required this.defaultTemperament,
    required this.healthWatchouts,
    required this.nutritionAdvice,
    this.description,
  });

  factory BreedModel.fromJson(Map<String, dynamic> json) {
    final watchoutsRaw = json['health_watchouts'] ?? json['healthWatchouts'] ?? [];
    return BreedModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? json['nameEn'],
      category: json['category'] ?? 'Компаньоны',
      origin: json['origin'] ?? '',
      idealWeightMin: (json['ideal_weight_min'] as num?)?.toDouble() ?? (json['idealWeightMin'] as num?)?.toDouble() ?? 10.0,
      idealWeightMax: (json['ideal_weight_max'] as num?)?.toDouble() ?? (json['idealWeightMax'] as num?)?.toDouble() ?? 15.0,
      activityMinMinutes: (json['activity_min_minutes'] as num?)?.toInt() ?? (json['activityMinMinutes'] as num?)?.toInt() ?? 60,
      defaultTemperament: json['default_temperament'] ?? json['defaultTemperament'] ?? 'playful',
      healthWatchouts: (watchoutsRaw as List<dynamic>).map((w) => HealthWatchoutModel.fromJson(w as Map<String, dynamic>)).toList(),
      nutritionAdvice: json['nutrition_advice'] ?? json['nutritionAdvice'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
        'category': category,
        'origin': origin,
        'ideal_weight_min': idealWeightMin,
        'ideal_weight_max': idealWeightMax,
        'activity_min_minutes': activityMinMinutes,
        'default_temperament': defaultTemperament,
        'health_watchouts': healthWatchouts.map((w) => w.toJson()).toList(),
        'nutrition_advice': nutritionAdvice,
        'description': description,
      };

  String get idealWeightRange => '${idealWeightMin.toStringAsFixed(1)} – ${idealWeightMax.toStringAsFixed(1)} кг';
}

class BodyConditionHelper {
  static String getLabel(int bcs) {
    if (bcs <= 3) return 'Дефицит массы';
    if (bcs <= 5) return 'Идеальная кондиция';
    if (bcs <= 7) return 'Легкий избыток';
    return 'Выраженное ожирение';
  }

  static Color getColor(int bcs) {
    if (bcs <= 3) return const Color(0xFF60A5FA); // Blue
    if (bcs <= 5) return const Color(0xFF34D399); // Emerald Green
    if (bcs <= 7) return const Color(0xFFFBBF24); // Amber Yellow
    return const Color(0xFFF87171); // Red
  }

  static String getAdvice(int bcs) {
    if (bcs <= 3) {
      return 'Ребра и кости таза легко прощупываются без жировой прослойки. Рекомендуется увеличить суточную калорийность на 15–20%.';
    }
    if (bcs <= 5) {
      return 'Ребра легко прощупываются, выраженная талия сверху и подтянутый живот сбоку. Прекрасная спортивная форма!';
    }
    if (bcs <= 7) {
      return 'Ребра прощупываются с трудом под слоем жира, линия талии сглажена. Сократите объем лакомств на 25%.';
    }
    return 'Выраженные жировые отложения в области поясницы и шеи. Высокий риск диабета и болезней суставов. Необходима ветеринарная диета.';
  }

  static int calculateDailyKcal({
    required double weightKg,
    required int bcsScore,
    int activityMinutes = 60,
  }) {
    final validWeight = weightKg > 0 ? weightKg : 10.0;
    final rer = 70.0 * math.pow(validWeight, 0.75);

    double factor;
    if (bcsScore <= 3) {
      factor = 1.8;
    } else if (bcsScore <= 5) {
      factor = activityMinutes > 90 ? 1.8 : 1.6;
    } else if (bcsScore <= 7) {
      factor = 1.3;
    } else {
      factor = 1.1;
    }

    return (rer * factor).round();
  }

  static int estimateFoodGrams(int dailyKcal) {
    // Average premium dry kibble contains ~370 kcal per 100g (~3.7 kcal/g)
    return (dailyKcal / 3.7).round();
  }
}
