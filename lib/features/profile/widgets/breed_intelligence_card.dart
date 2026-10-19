import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../models/breed_model.dart';
import '../../../models/pet_health_profile_model.dart';

class BreedIntelligenceCard extends StatelessWidget {
  final BreedModel? breed;
  final PetHealthProfileModel? profile;

  const BreedIntelligenceCard({
    super.key,
    this.breed,
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    if (breed == null && profile?.healthWatchouts.isEmpty == true) {
      return const SizedBox.shrink();
    }

    final breedName = breed?.name ?? profile?.breedName ?? 'Порода питомца';
    final category = breed?.category ?? 'Компаньон';
    final origin = breed?.origin;
    final activityGoal = breed?.activityMinMinutes ?? profile?.activityGoalMinutes ?? 60;
    final watchouts = breed?.healthWatchouts.isNotEmpty == true
        ? breed!.healthWatchouts
        : (profile?.healthWatchouts ?? []);
    final nutritionAdvice = breed?.nutritionAdvice.isNotEmpty == true
        ? breed!.nutritionAdvice
        : profile?.nutritionAdvice;

    // Daily food estimation
    final kcalTarget = profile?.dailyKcalTarget ?? (breed != null
        ? BodyConditionHelper.calculateDailyKcal(
            weightKg: breed!.idealWeightMin,
            bcsScore: 5,
            activityMinutes: activityGoal,
          )
        : 600);
    final foodGrams = profile?.dailyFoodGramsEstimate ?? BodyConditionHelper.estimateFoodGrams(kcalTarget);

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      accentColor: AppColors.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: AppColors.accentBlue, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Интеллект породы',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.accentBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Breed Name & Origin
          Text(
            breedName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (origin != null && origin.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Родина: $origin',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Activity & Nutrition Quick Stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: Row(
              children: [
                // Activity Goal
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.accentYellow, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Активность',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              '$activityGoal мин/день',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.glassBorder,
                ),
                const SizedBox(width: 10),
                // Daily Nutrition Target
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restaurant_rounded, color: AppColors.accentGreen, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Суточная норма',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              '~$kcalTarget ккал (~$foodGrams г)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Health Watchouts Section
          if (watchouts.isNotEmpty) ...[
            const Text(
              'Зоны внимания здоровья породы',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...watchouts.map((w) {
              final isHigh = w.isHighRisk;
              final badgeColor = isHigh ? AppColors.accentRed : AppColors.accentYellow;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianGlassSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isHigh
                          ? AppColors.accentRed.withValues(alpha: 0.35)
                          : AppColors.glassBorderSubtle,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  isHigh ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                                  color: badgeColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    w.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isHigh ? 'Высокий риск' : 'Контроль',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        w.advice,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Nutrition Advice Callout
          if (nutritionAdvice != null && nutritionAdvice.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.accentGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nutritionAdvice,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
