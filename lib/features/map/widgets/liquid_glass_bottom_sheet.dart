import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../models/route_model.dart';

class LiquidGlassBottomSheet extends StatelessWidget {
  final ActiveRouteModel route;
  final String activeMode;
  final Function(String mode) onModeSelected;
  final VoidCallback onStartNavigation;
  final VoidCallback onClose;

  const LiquidGlassBottomSheet({
    super.key,
    required this.route,
    required this.activeMode,
    required this.onModeSelected,
    required this.onStartNavigation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.88),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Grabber handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Header: Destination & Close
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accentBlue.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.navigation,
                      color: AppColors.accentBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.destinationTitle,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accentGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${route.durationMinutes} мин • ${route.distanceMeters} м • Безопасный путь',
                              style: const TextStyle(
                                color: AppColors.accentGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorderSubtle),
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Pure Vector Transport Mode Selector (Walk, Park Safe, Drive)
              Row(
                children: [
                  Expanded(
                    child: _buildModeCard(
                      modeKey: 'walk',
                      title: 'Пешком',
                      duration: '${route.durationMinutes} мин',
                      icon: LucideIcons.footprints,
                      isSelected: activeMode == 'walk',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModeCard(
                      modeKey: 'park_safe',
                      title: 'Парк / Выгул',
                      duration: '${(route.durationMinutes * 1.15).ceil()} мин',
                      icon: LucideIcons.trees,
                      isSelected: activeMode == 'park_safe',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModeCard(
                      modeKey: 'drive',
                      title: 'На авто',
                      duration: '${(route.durationMinutes / 3).ceil().clamp(1, 60)} мин',
                      icon: LucideIcons.car,
                      isSelected: activeMode == 'drive',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Primary CTA: Apple Green Button "В путь"
              GestureDetector(
                onTap: onStartNavigation,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.navigation,
                        color: Colors.black,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'В путь (Начать навигацию)',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String modeKey,
    required String title,
    required String duration,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onModeSelected(modeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.glassBorderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              duration,
              style: TextStyle(
                color: isSelected ? AppColors.accentBlue : AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
