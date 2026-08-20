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

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      extendBody: true,
      body: Stack(
        children: [
          // Active Screen Branch
          navigationShell,

          // Global Floating Liquid Glass Tab Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: mapState.selectedMarker != null,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                offset: mapState.selectedMarker != null ? const Offset(0, 1.5) : Offset.zero,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xC8121814),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  blurRadius: 36,
                                  offset: const Offset(0, 16),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  blurRadius: 0,
                                  spreadRadius: 0,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _NavItem(
                                  icon: Icons.map_outlined,
                                  activeIcon: Icons.map_rounded,
                                  label: 'Карта',
                                  isSelected: navigationShell.currentIndex == 0,
                                  activeColor: isBreached ? AppColors.accentRed : const Color(0xFF34D399),
                                  onTap: () => _onTap(0),
                                ),
                                const SizedBox(width: 6),
                                _NavItem(
                                  icon: Icons.search_outlined,
                                  activeIcon: Icons.search_rounded,
                                  label: 'Поиск',
                                  isSelected: navigationShell.currentIndex == 1,
                                  activeColor: AppColors.accentGreen,
                                  onTap: () => _onTap(1),
                                ),
                                const SizedBox(width: 6),
                                _NavItem(
                                  icon: Icons.pets_outlined,
                                  activeIcon: Icons.pets_rounded,
                                  label: 'Паспорт',
                                  isSelected: navigationShell.currentIndex == 2,
                                  activeColor: AppColors.accentBlue,
                                  onTap: () => _onTap(2),
                                ),
                                const SizedBox(width: 6),
                                _NavItem(
                                  icon: Icons.forum_outlined,
                                  activeIcon: Icons.forum_rounded,
                                  label: 'Лента',
                                  isSelected: navigationShell.currentIndex == 3,
                                  activeColor: AppColors.accentYellow,
                                  onTap: () => _onTap(3),
                                ),
                                const SizedBox(width: 6),
                                _NavItem(
                                  icon: Icons.settings_outlined,
                                  activeIcon: Icons.settings_rounded,
                                  label: 'Настройки',
                                  isSelected: navigationShell.currentIndex == 4,
                                  activeColor: const Color(0xFF34D399),
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

          // Global Top Emergency Geofence Breach Banner
          if (isBreached)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BreachAlertBanner(
                petName: gpsDevice?.petName ?? 'Макс',
                onNavigateToMap: () {
                  navigationShell.goBranch(0);
                  ref.read(mapNotifierProvider.notifier).selectMarker(null);
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
    final iconColor = isSelected ? activeColor : Colors.white.withValues(alpha: 0.60);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.4, 0.0, 0.2, 1.0),
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 11,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      activeColor.withValues(alpha: 0.25),
                      activeColor.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            border: isSelected
                ? Border.all(
                    color: activeColor.withValues(alpha: 0.45),
                    width: 1.0,
                  )
                : Border.all(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? widget.activeIcon : widget.icon,
                color: iconColor,
                size: 20,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activeColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
