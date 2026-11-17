import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../models/route_model.dart';

class TurnByTurnHud extends StatelessWidget {
  final ActiveRouteModel route;
  final int currentStepIndex;
  final VoidCallback onNextStep;
  final VoidCallback onPrevStep;
  final VoidCallback onEndNavigation;

  const TurnByTurnHud({
    super.key,
    required this.route,
    required this.currentStepIndex,
    required this.onNextStep,
    required this.onPrevStep,
    required this.onEndNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = (currentStepIndex >= 0 && currentStepIndex < route.steps.length)
        ? route.steps[currentStepIndex]
        : (route.steps.isNotEmpty ? route.steps.first : null);

    final instruction = currentStep?.instruction ?? 'Следуйте по маршруту на карте';
    final streetName = currentStep?.streetName ?? route.destinationTitle;
    final stepDistance = currentStep?.distanceMeters ?? route.distanceMeters;
    final maneuverType = currentStep?.maneuverType ?? ManeuverType.straight;

    // Format arrival time
    final now = DateTime.now();
    final arrivalTime = now.add(Duration(minutes: route.durationMinutes));
    final arrivalStr = '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';

    return Stack(
      children: [
        // 1. Top Maneuver Capsule
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianGlassBackground,
                    borderRadius: BorderRadius.circular(22.0),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Maneuver Icon Box
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.accentGreen.withValues(alpha: 0.35),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getManeuverIcon(maneuverType),
                            color: AppColors.accentGreen,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Turn text & Street name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Через $stepDistance м $instruction',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              streetName,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Step switcher buttons (Prev/Next simulation) with min 44x44 touch targets
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentStepIndex > 0)
                            Semantics(
                              button: true,
                              label: 'Предыдущий шаг маневра',
                              child: InkWell(
                                onTap: onPrevStep,
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chevron_left_rounded,
                                      color: AppColors.textSecondary,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (currentStepIndex < route.steps.length - 1)
                            Semantics(
                              button: true,
                              label: 'Следующий шаг маневра',
                              child: InkWell(
                                onTap: onNextStep,
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGreen.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.accentGreen,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. Live Walking Pace Indicator (Left Side Pill)
        Positioned(
          top: 104,
          left: 16,
          child: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianGlassBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorderSubtle),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed_rounded, color: AppColors.accentGreen, size: 14),
                      SizedBox(width: 6),
                      Text(
                        '4.8 км/ч',
                        style: TextStyle(
                          color: AppColors.accentGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '• темп шага',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 3. Bottom ETA Bar & Exit Navigation Button
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianGlassBackground,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ETA & Distance
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${route.durationMinutes} мин',
                                  style: const TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${route.distanceMeters} м',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Прибытие в $arrivalStr • ${route.destinationTitle}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Red Glass "Завершить" Button with min 44x44 touch target
                      Semantics(
                        button: true,
                        label: 'Завершить навигацию',
                        child: InkWell(
                          onTap: onEndNavigation,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.accentRed.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.accentRed.withValues(alpha: 0.4),
                                width: 1.0,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cancel_rounded,
                                  color: AppColors.accentRed,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Завершить',
                                  style: TextStyle(
                                    color: AppColors.accentRed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getManeuverIcon(ManeuverType type) {
    switch (type) {
      case ManeuverType.turnRight:
        return Icons.turn_right_rounded;
      case ManeuverType.turnLeft:
        return Icons.turn_left_rounded;
      case ManeuverType.slightRight:
        return Icons.turn_slight_right_rounded;
      case ManeuverType.slightLeft:
        return Icons.turn_slight_left_rounded;
      case ManeuverType.arrive:
        return Icons.location_on_rounded;
      case ManeuverType.straight:
        return Icons.straight_rounded;
    }
  }
}
