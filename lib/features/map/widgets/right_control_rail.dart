import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class RightControlRail extends StatefulWidget {
  final String petName;
  final int distanceMeters;
  final bool isBreached;
  final bool isPetFocus;
  final Set<String> activeFilters;
  final ValueChanged<String> onToggleFilter;
  final VoidCallback onPetFocus;
  final VoidCallback onUserFocus;
  final VoidCallback onAddEvent;
  final VoidCallback onBuildRoute;
  final VoidCallback? onOpenThemeSandbox;
  final VoidCallback? onStartWalk;
  final bool isWalking;

  const RightControlRail({
    super.key,
    required this.petName,
    required this.distanceMeters,
    required this.isBreached,
    required this.isPetFocus,
    required this.activeFilters,
    required this.onToggleFilter,
    required this.onPetFocus,
    required this.onUserFocus,
    required this.onAddEvent,
    required this.onBuildRoute,
    this.onOpenThemeSandbox,
    this.onStartWalk,
    this.isWalking = false,
  });

  @override
  State<RightControlRail> createState() => _RightControlRailState();
}

class _RightControlRailState extends State<RightControlRail> {
  bool _isLayersExpanded = false;

  void _toggleLayers() {
    setState(() {
      _isLayersExpanded = !_isLayersExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeGreen = widget.isBreached ? AppColors.accentRed : AppColors.accentGreen;
    final isPetFocus = widget.isPetFocus;
    final activeFiltersCount = widget.activeFilters.length;
    final hasFilterActive = activeFiltersCount < 3;

    return Stack(
      alignment: Alignment.centerRight,
      clipBehavior: Clip.none,
      children: [
        // 1. Sliding Map Layers Drawer Card (Slides out to the left when Layers is clicked)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          top: 4.0,
          right: _isLayersExpanded ? 56.0 : 38.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isLayersExpanded ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_isLayersExpanded,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.obsidianCardTranslucent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Слои карты',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$activeFiltersCount активны',
                              style: TextStyle(
                                color: hasFilterActive ? AppColors.accentGreen : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _LayerRowItem(
                          icon: Icons.warning_amber_rounded,
                          title: 'Потерянные питомцы',
                          isActive: widget.activeFilters.contains('lost_pet'),
                          onToggle: () => widget.onToggleFilter('lost_pet'),
                        ),
                        const SizedBox(height: 6),
                        _LayerRowItem(
                          icon: Icons.park_rounded,
                          title: 'Площадки для собак',
                          isActive: widget.activeFilters.contains('playground'),
                          onToggle: () => widget.onToggleFilter('playground'),
                        ),
                        const SizedBox(height: 6),
                        _LayerRowItem(
                          icon: Icons.people_alt_rounded,
                          title: 'Поиск компаньонов',
                          isActive: widget.activeFilters.contains('companion'),
                          onToggle: () => widget.onToggleFilter('companion'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. Unified Calm Graphite Distance & Quick Route Badge (Left of the rail when Pet mode is active)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          top: 48.0,
          right: isPetFocus ? 56.0 : 38.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (isPetFocus && !_isLayersExpanded) ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !(isPetFocus && !_isLayersExpanded),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.obsidianCardTranslucent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: activeGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.petName}: ${widget.distanceMeters} м',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: AppColors.glassBorder,
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onBuildRoute,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.directions_rounded,
                                    color: AppColors.accentGreen,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Путь',
                                    style: TextStyle(
                                      color: AppColors.accentGreen,
                                      fontSize: 12,
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
        ),

        // 3. Single Right Control Rail (48px width, single clean border)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.obsidianCardTranslucent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Map Layer Filter Button
                  _RailIconButton(
                    icon: Icons.layers_rounded,
                    tooltip: 'Слои и фильтры карты',
                    isSelected: _isLayersExpanded,
                    hasActiveBadge: hasFilterActive,
                    activeColor: AppColors.accentGreen,
                    onTap: _toggleLayers,
                  ),
                  const SizedBox(height: 4),
                  // Pet Focus Button
                  _RailIconButton(
                    icon: Icons.pets_rounded,
                    tooltip: 'Центрировать на питомце (${widget.petName})',
                    isSelected: isPetFocus,
                    activeColor: activeGreen,
                    onTap: () {
                      setState(() => _isLayersExpanded = false);
                      widget.onPetFocus();
                    },
                  ),
                  const SizedBox(height: 4),
                  // User Focus Button
                  _RailIconButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Моя геопозиция',
                    isSelected: !isPetFocus,
                    activeColor: AppColors.accentBlue,
                    onTap: () {
                      setState(() => _isLayersExpanded = false);
                      widget.onUserFocus();
                    },
                  ),
                  if (widget.onOpenThemeSandbox != null) ...[
                    const SizedBox(height: 4),
                    // Map Theme Sandbox Tuner Button
                    _RailIconButton(
                      icon: Icons.palette_rounded,
                      tooltip: 'Тюнинг темы и цветов карты',
                      isSelected: false,
                      activeColor: AppColors.accentGreen,
                      onTap: () {
                        setState(() => _isLayersExpanded = false);
                        widget.onOpenThemeSandbox!();
                      },
                    ),
                  ],

                  // Hairline divider between focus controls and actions
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    color: AppColors.glassBorder,
                  ),

                  // Walk Radar Button (Start Walk / Walk Radar)
                  _RailIconButton(
                    icon: Icons.radar_rounded,
                    tooltip: 'Радар прогулок • Выйти на выгул',
                    isSelected: widget.isWalking,
                    activeColor: AppColors.accentGreen,
                    onTap: () {
                      setState(() => _isLayersExpanded = false);
                      widget.onStartWalk?.call();
                    },
                  ),
                  const SizedBox(height: 4),

                  // Lower Section: Add Event (+) Button
                  _RailIconButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Добавить событие или метку на карту',
                    isSelected: false,
                    isAccentAdd: true,
                    activeColor: activeGreen,
                    onTap: () {
                      setState(() => _isLayersExpanded = false);
                      widget.onAddEvent();
                    },
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

class _LayerRowItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onToggle;

  const _LayerRowItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.obsidianRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.glassBorderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 30,
              height: 18,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accentGreen : Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final bool isAccentAdd;
  final bool hasActiveBadge;
  final Color activeColor;
  final VoidCallback onTap;

  const _RailIconButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    this.isAccentAdd = false,
    this.hasActiveBadge = false,
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
      iconColor = AppColors.textSecondary;
    }

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 140),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.obsidianRaised
                  : (isAccentAdd
                      ? AppColors.accentGreen.withValues(alpha: 0.14)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.45)
                    : (isAccentAdd
                        ? AppColors.accentGreen.withValues(alpha: 0.35)
                        : Colors.transparent),
                width: 1.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: iconColor,
                  size: isAccentAdd ? 20 : 18,
                ),
                if (widget.hasActiveBadge && !isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
