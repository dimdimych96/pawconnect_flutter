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
      bottomNavigationBar: IgnorePointer(
        ignoring: mapState.selectedMarker != null,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          offset: mapState.selectedMarker != null ? const Offset(0, 1.5) : Offset.zero,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.obsidianCardTranslucent,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
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
                    child: Stack(
                      children: [
                        // Specular sheen along the top edge — the only "frost"
                        // on the glass; the rest is pure blur of what's behind.
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: AppColors.glassSpecular,
                              ),
                            ),
                          ),
                        ),
                        Row(
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
    final color = isSelected ? activeColor : AppColors.textSecondary;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        // Interactive glass: the item dips slightly while pressed.
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  // Active tab "morphs" into a glowing glass pill.
                  color: activeColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeColor.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 0.5,
                    ),
                  ],
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
                child: Icon(
                  isSelected ? widget.activeIcon : widget.icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
