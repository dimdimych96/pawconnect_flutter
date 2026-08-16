import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../models/route_model.dart';

class RouteBannerWidget extends StatelessWidget {
  final ActiveRouteModel route;
  final Function(String mode) onModeChanged;
  final VoidCallback onClose;

  const RouteBannerWidget({
    super.key,
    required this.route,
    required this.onModeChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final firstStep = route.steps.isNotEmpty ? route.steps.first.instruction : 'Следуйте по маршруту на карте';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(16.0),
          borderRadius: 20.0,
          borderColor: AppColors.accentBlue.withValues(alpha: 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Destination & Close
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: AppColors.accentBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Маршрут: ${route.destinationTitle}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${route.durationMinutes} мин • ${route.distanceMeters} м',
                          style: const TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mode Selector (Walk, Drive, Dog Run)
              Row(
                children: [
                  _buildModeChip('walk', '🚶 Пешком', route.transportMode == 'walk'),
                  const SizedBox(width: 8),
                  _buildModeChip('drive', '🚗 На авто', route.transportMode == 'drive'),
                  const SizedBox(width: 8),
                  _buildModeChip('dog_run', '🐕 Бег', route.transportMode == 'dog_run'),
                ],
              ),
              const SizedBox(height: 10),

              // Instruction Step
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.turn_right_rounded, color: AppColors.accentGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        firstStep,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeChip(String modeKey, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(modeKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accentBlue : AppColors.glassBorderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
