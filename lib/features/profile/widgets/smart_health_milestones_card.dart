import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../core/widgets/pill_toast.dart';
import '../../../models/pet_health_profile_model.dart';
import '../../../providers/health_provider.dart';

class SmartHealthMilestonesCard extends ConsumerWidget {
  final PetHealthProfileModel profile;

  const SmartHealthMilestonesCard({
    super.key,
    required this.profile,
  });

  Color _getMilestoneColor(String category) {
    switch (category) {
      case 'parasite':
        return AppColors.accentGreen;
      case 'vaccine':
        return AppColors.accentBlue;
      case 'deworming':
        return AppColors.accentYellow;
      default:
        return AppColors.accentBlue;
    }
  }

  IconData _getMilestoneIcon(String category) {
    switch (category) {
      case 'parasite':
        return Icons.shield_outlined;
      case 'vaccine':
        return Icons.vaccines_rounded;
      case 'deworming':
        return Icons.medication_liquid_rounded;
      default:
        return Icons.event_available_rounded;
    }
  }

  Future<void> _handleAutoMilestones(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(healthNotifierProvider.notifier)
        .applyStandardMilestones(profile.petId);

    if (context.mounted) {
      if (success) {
        PawToast.show(
          context,
          title: 'Вехи вакцинации и обработки автоматически заполнены',
          type: ToastType.success,
        );
      } else {
        PawToast.show(
          context,
          title: 'Не удалось обновить календарь вех',
          type: ToastType.alert,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parasite = profile.parasiteProtection;
    final milestones = profile.milestones;
    final healthState = ref.watch(healthNotifierProvider);

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
      accentColor: AppColors.accentGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (without 'Протокол 2026' marketing badge)
          const Row(
            children: [
              Icon(Icons.health_and_safety_rounded, color: AppColors.textSecondary, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Умные вехи & Защита',
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
          const SizedBox(height: 16),

          // Seasonal Parasite / Tick Protection Section
          if (parasite != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
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
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.obsidianCard,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shield_rounded, color: AppColors.accentGreen, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    parasite.productName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Защита от клещей и блох',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (parasite.daysRemaining > 7
                                  ? AppColors.accentGreen
                                  : AppColors.accentYellow)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          parasite.daysRemaining > 0
                              ? 'Осталось ${parasite.daysRemaining} дн.'
                              : 'Требуется обработка',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: parasite.daysRemaining > 7
                                ? AppColors.accentGreen
                                : AppColors.accentYellow,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: parasite.progressRatio,
                      minHeight: 6,
                      backgroundColor: AppColors.obsidianCard,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        parasite.daysRemaining > 7 ? AppColors.accentGreen : AppColors.accentYellow,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Обработан: ${parasite.lastAppliedDate.day}.${parasite.lastAppliedDate.month}.${parasite.lastAppliedDate.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Следующая: ${parasite.nextDueDate.day}.${parasite.nextDueDate.month}.${parasite.nextDueDate.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Core Milestones List
          if (milestones.isNotEmpty) ...[
            const Text(
              'План вакцинаций и процедур',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...milestones.map((milestone) {
              final catColor = _getMilestoneColor(milestone.category);
              final catIcon = _getMilestoneIcon(milestone.category);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianGlassSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.obsidianCard,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(catIcon, color: catColor, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              milestone.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: milestone.isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                decoration: milestone.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Срок: ${milestone.dueDate.day}.${milestone.dueDate.month}.${milestone.dueDate.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: catColor,
                                fontWeight: FontWeight.w500,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.obsidianCard,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              milestone.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                              size: 13,
                              color: milestone.isCompleted ? AppColors.accentGreen : catColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              milestone.isCompleted ? 'Сделано' : 'Запланировано',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: milestone.isCompleted ? AppColors.accentGreen : catColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
          ],

          // Auto-Fill Milestones Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: healthState.isUpdating ? null : () => _handleAutoMilestones(context, ref),
              icon: healthState.isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGreen),
                    )
                  : const Icon(Icons.event_available_rounded, color: AppColors.accentGreen, size: 18),
              label: Text(
                healthState.isUpdating
                    ? 'Применение протокола...'
                    : 'Автозаполнение вех по породе и возрасту',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.glassBorder),
                backgroundColor: AppColors.obsidianGlassSurface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
