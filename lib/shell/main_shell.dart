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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.obsidianCardTranslucent,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map_rounded,
                      label: 'Карта',
                      isSelected: navigationShell.currentIndex == 0,
                      activeColor: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                      onTap: () => _onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.pets_outlined,
                      activeIcon: Icons.pets_rounded,
                      label: 'Паспорт',
                      isSelected: navigationShell.currentIndex == 1,
                      activeColor: AppColors.accentBlue,
                      onTap: () => _onTap(1),
                    ),
                    _NavItem(
                      icon: Icons.forum_outlined,
                      activeIcon: Icons.forum_rounded,
                      label: 'Лента',
                      isSelected: navigationShell.currentIndex == 2,
                      activeColor: AppColors.accentYellow,
                      onTap: () => _onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings_rounded,
                      label: 'Настройки',
                      isSelected: navigationShell.currentIndex == 3,
                      activeColor: AppColors.textPrimary,
                      onTap: () => _onTap(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
