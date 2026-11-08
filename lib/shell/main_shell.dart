import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/colors.dart';
import '../features/map/widgets/breach_alert_banner.dart';
import '../providers/map_provider.dart';
import '../providers/user_provider.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    final userState = ref.watch(userNotifierProvider);

    final gpsDevice = mapState.gpsDevice;
    final isBreached = (gpsDevice?.isBreached ?? false) || userState.isSimulatingBreach;
    final isSheetOrNavActive = mapState.selectedMarker != null ||
        mapState.activeRoute != null ||
        mapState.isNavigating;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Active Screen Branch
          navigationShell,

          // Global Floating Liquid Glass Tab Bar (Quiet Graphite Chrome)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: isSheetOrNavActive,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: const Cubic(0.22, 1.0, 0.36, 1.0),
                offset: isSheetOrNavActive ? const Offset(0, 1.5) : Offset.zero,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.obsidianCardTranslucent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.glassBorder,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _NavItem(
                                  icon: Icons.view_agenda_outlined,
                                  activeIcon: Icons.view_agenda_rounded,
                                  label: 'Лента',
                                  isSelected: navigationShell.currentIndex == 0,
                                  activeColor: AppColors.textPrimary,
                                  onTap: () => _onTap(0),
                                ),
                                const SizedBox(width: 4),
                                _NavItem(
                                  icon: Icons.map_outlined,
                                  activeIcon: Icons.map_rounded,
                                  label: 'Карта',
                                  isSelected: navigationShell.currentIndex == 1,
                                  activeColor: isBreached ? AppColors.accentRed : AppColors.textPrimary,
                                  onTap: () => _onTap(1),
                                ),
                                const SizedBox(width: 4),
                                _NavItem(
                                  icon: Icons.search_outlined,
                                  activeIcon: Icons.search_rounded,
                                  label: 'Поиск',
                                  isSelected: navigationShell.currentIndex == 2,
                                  activeColor: AppColors.textPrimary,
                                  onTap: () => _onTap(2),
                                ),
                                const SizedBox(width: 4),
                                _NavItem(
                                  icon: Icons.pets_outlined,
                                  activeIcon: Icons.pets_rounded,
                                  label: 'Паспорт',
                                  isSelected: navigationShell.currentIndex == 3,
                                  activeColor: AppColors.textPrimary,
                                  onTap: () => _onTap(3),
                                ),
                                const SizedBox(width: 4),
                                _NavItem(
                                  icon: Icons.settings_outlined,
                                  activeIcon: Icons.settings_rounded,
                                  label: 'Настройки',
                                  isSelected: navigationShell.currentIndex == 4,
                                  activeColor: AppColors.textPrimary,
                                  onTap: () => _onTap(4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Global Top Emergency Geofence Breach Banner or Hazard Proximity Warning
          if (isBreached || mapState.activeHazardNearby != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BreachAlertBanner(
                petName: isBreached ? (gpsDevice?.petName ?? 'Макс') : null,
                hazardTitle: !isBreached ? mapState.activeHazardNearby?.title : null,
                onNavigateToMap: () {
                  navigationShell.goBranch(1);
                  if (!isBreached && mapState.activeHazardNearby != null) {
                    ref.read(mapNotifierProvider.notifier).selectMarker(mapState.activeHazardNearby);
                  } else {
                    ref.read(mapNotifierProvider.notifier).selectMarker(null);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final activeColor = widget.activeColor;
    final iconColor = isSelected ? activeColor : AppColors.textTertiary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: widget.label,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: const Cubic(0.22, 1.0, 0.36, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: const Cubic(0.22, 1.0, 0.36, 1.0),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected ? AppColors.obsidianGlassSurface : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.glassBorder : Colors.transparent,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? widget.activeIcon : widget.icon,
                    color: iconColor,
                    size: 18,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: activeColor,
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
