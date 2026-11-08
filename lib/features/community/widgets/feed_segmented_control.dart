import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';

/// Apple Liquid Glass Segmented Control for switching feed streams.
///
/// Features:
/// - 3 streams: «Для вас», «Мой район», «SOS».
/// - Smooth animated sliding highlight indicator synchronized with TabController animation.
/// - Quiet red dot indicator for active SOS alerts.
/// - Zero BackdropFilter for GPU budget compliance.
class FeedSegmentedControl extends StatelessWidget {
  final TabController controller;
  final int sosCount;
  final VoidCallback? onTabChanged;

  const FeedSegmentedControl({
    super.key,
    required this.controller,
    this.sosCount = 0,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 3;

          return AnimatedBuilder(
            animation: controller.animation ?? controller,
            builder: (context, _) {
              final animValue = controller.animation?.value ?? controller.index.toDouble();

              return Stack(
                children: [
                  // Sliding Active Tab Highlight Pill
                  Positioned(
                    left: animValue * tabWidth,
                    width: tabWidth,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.obsidianGlassSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),

                  // Tab Buttons Row
                  Row(
                    children: [
                      _buildTabItem(
                        context,
                        index: 0,
                        label: 'Для вас',
                        icon: Icons.auto_awesome_rounded,
                        tabWidth: tabWidth,
                        isActive: controller.index == 0,
                      ),
                      _buildTabItem(
                        context,
                        index: 1,
                        label: 'Мой район',
                        icon: Icons.location_on_rounded,
                        tabWidth: tabWidth,
                        isActive: controller.index == 1,
                      ),
                      _buildTabItem(
                        context,
                        index: 2,
                        label: 'SOS',
                        icon: Icons.warning_amber_rounded,
                        tabWidth: tabWidth,
                        isActive: controller.index == 2,
                        badgeColor: AppColors.accentRed,
                        showPulseBadge: true,
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    required double tabWidth,
    required bool isActive,
    Color? badgeColor,
    bool showPulseBadge = false,
  }) {
    return SizedBox(
      width: tabWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(index == 0
              ? 'feed_tab_for_you'
              : (index == 1 ? 'feed_tab_district' : 'feed_tab_sos')),
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withValues(alpha: 0.06),
          highlightColor: Colors.transparent,
          onTap: () {
            HapticFeedback.selectionClick();
            controller.animateTo(index);
            onTabChanged?.call();
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (showPulseBadge && sosCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.accentRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
