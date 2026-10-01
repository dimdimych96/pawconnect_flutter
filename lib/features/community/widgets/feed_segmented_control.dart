import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';

/// Apple Liquid Glass Segmented Control for switching feed streams.
///
/// Features:
/// - 3 streams: «Для вас», «Мой район», «SOS 🚨».
/// - Smooth animated sliding highlight indicator synchronized with TabController animation.
/// - Pulsing red beacon indicator for active SOS alerts.
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
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.8,
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
                        color: _getActiveColor(controller.index).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _getActiveColor(controller.index).withValues(alpha: 0.45),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getActiveColor(controller.index).withValues(alpha: 0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
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

  Color _getActiveColor(int index) {
    switch (index) {
      case 0:
        return AppColors.accentBlue;
      case 1:
        return AppColors.accentGreen;
      case 2:
        return AppColors.accentRed;
      default:
        return AppColors.accentBlue;
    }
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
    final activeColor = _getActiveColor(index);

    return SizedBox(
      width: tabWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(index == 0
              ? 'feed_tab_for_you'
              : (index == 1 ? 'feed_tab_district' : 'feed_tab_sos')),
          borderRadius: BorderRadius.circular(18),
          splashColor: activeColor.withValues(alpha: 0.15),
          highlightColor: Colors.transparent,
          onTap: () {
            HapticFeedback.selectionClick();
            controller.animateTo(index);
            onTabChanged?.call();
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isActive ? activeColor : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.textSecondary,
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
                      boxShadow: [
                        BoxShadow(
                          color: (badgeColor ?? AppColors.accentRed).withValues(alpha: 0.6),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
