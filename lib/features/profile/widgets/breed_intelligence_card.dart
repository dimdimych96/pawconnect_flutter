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
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
      accentColor: AppColors.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Интеллект породы',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianGlassSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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
              fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),

          // Activity & Nutrition Quick Stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(10),
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
                          color: AppColors.obsidianCard,
                          borderRadius: BorderRadius.circular(8),
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
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$activityGoal мин/день',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                              overflow: TextOverflow.ellipsis,
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
                  color: AppColors.glassBorderSubtle,
                ),
                const SizedBox(width: 10),
                // Daily Nutrition Target
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.obsidianCard,
                          borderRadius: BorderRadius.circular(8),
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
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '~$kcalTarget ккал (~$foodGrams г)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                              overflow: TextOverflow.ellipsis,
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
                fontWeight: FontWeight.w500,
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
                    borderRadius: BorderRadius.circular(10),
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
                                Flexible(
                                  child: Text(
                                    w.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.obsidianCard,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isHigh ? 'Высокий риск' : 'Контроль',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        w.advice,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
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
                color: AppColors.obsidianGlassSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.accentGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nutritionAdvice,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
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
