import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class RightControlRail extends StatelessWidget {
  final String petName;
  final int distanceMeters;
  final bool isBreached;
  final bool isPetFocus;
  final VoidCallback onPetFocus;
  final VoidCallback onUserFocus;
  final VoidCallback onAddEvent;
  final VoidCallback onBuildRoute;

  const RightControlRail({
    super.key,
    required this.petName,
    required this.distanceMeters,
    required this.isBreached,
    required this.isPetFocus,
    required this.onPetFocus,
    required this.onUserFocus,
    required this.onAddEvent,
    required this.onBuildRoute,
  });

  @override
  Widget build(BuildContext context) {
    final activeGreen = isBreached ? AppColors.accentRed : AppColors.accentGreen;

    return Stack(
      alignment: Alignment.centerRight,
      clipBehavior: Clip.none,
      children: [
        // 1. Sliding Distance & Quick Route Badge (Left of the rail when Pet mode is active)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          top: 4.0,
          right: isPetFocus ? 52.0 : 34.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isPetFocus ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !isPetFocus,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xD8121814),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: activeGreen.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: activeGreen.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Pulsing status dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: activeGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: activeGreen.withValues(alpha: 0.75),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '$petName: $distanceMeters м',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quick Route Icon Button inside badge
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onBuildRoute,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.accentBlue.withValues(alpha: 0.55),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentBlue.withValues(alpha: 0.20),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.directions_rounded,
                                    color: AppColors.accentBlue,
                                    size: 13,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Путь',
                                    style: TextStyle(
                                      color: AppColors.accentBlue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
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
        ),

        // 2. Single Right Control Rail (Unified Liquid Glass Monolith)
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xC8121814),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Upper Segmented Section: Pet Focus vs User Focus
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pet Focus Button
                        _RailIconButton(
                          icon: Icons.pets_rounded,
                          tooltip: 'Центрировать на питомце ($petName)',
                          isSelected: isPetFocus,
                          activeColor: activeGreen,
                          onTap: onPetFocus,
                        ),
                        const SizedBox(height: 4),
                        // User Focus Button
                        _RailIconButton(
                          icon: Icons.my_location_rounded,
                          tooltip: 'Моя геопозиция',
                          isSelected: !isPetFocus,
                          activeColor: AppColors.accentBlue,
                          onTap: onUserFocus,
                        ),
                      ],
                    ),
                  ),

                  // Divider between focus toggle and action section
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                    color: Colors.white.withValues(alpha: 0.10),
                  ),

                  // Lower Section: Add Event (+) Button
                  _RailIconButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Добавить событие или метку на карту',
                    isSelected: false,
                    isAccentAdd: true,
                    activeColor: activeGreen,
                    onTap: onAddEvent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RailIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final bool isAccentAdd;
  final Color activeColor;
  final VoidCallback onTap;

  const _RailIconButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    this.isAccentAdd = false,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_RailIconButton> createState() => _RailIconButtonState();
}

class _RailIconButtonState extends State<_RailIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final activeColor = widget.activeColor;
    final isAccentAdd = widget.isAccentAdd;

    Color iconColor;
    if (isAccentAdd) {
      iconColor = AppColors.accentGreen;
    } else if (isSelected) {
      iconColor = activeColor;
    } else {
      iconColor = Colors.white.withValues(alpha: 0.60);
    }

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        activeColor.withValues(alpha: 0.30),
                        activeColor.withValues(alpha: 0.15),
                      ],
                    )
                  : (isAccentAdd
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentGreen.withValues(alpha: 0.22),
                            AppColors.accentGreen.withValues(alpha: 0.10),
                          ],
                        )
                      : null),
              border: isSelected
                  ? Border.all(
                      color: activeColor.withValues(alpha: 0.60),
                      width: 1.0,
                    )
                  : (isAccentAdd
                      ? Border.all(
                          color: AppColors.accentGreen.withValues(alpha: 0.45),
                          width: 1.0,
                        )
                      : Border.all(
                          color: Colors.transparent,
                          width: 1.0,
                        )),
              boxShadow: (isSelected || isAccentAdd)
                  ? [
                      BoxShadow(
                        color: (isSelected ? activeColor : AppColors.accentGreen).withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: iconColor,
                size: isAccentAdd ? 20 : 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
