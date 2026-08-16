import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Left Header Liquid Glass Control Rail (100% mirror of RightControlRail)
/// Features Search input expansion and Map Layer Filter drawer sliding.
class LeftHeaderRail extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final Set<String> activeFilters;
  final ValueChanged<String> onToggleFilter;
  final VoidCallback onClearSearch;

  const LeftHeaderRail({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.activeFilters,
    required this.onToggleFilter,
    required this.onClearSearch,
  });

  @override
  State<LeftHeaderRail> createState() => _LeftHeaderRailState();
}

class _LeftHeaderRailState extends State<LeftHeaderRail> {
  bool _isSearchExpanded = false;
  bool _isLayersExpanded = false;

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _isLayersExpanded = false;
      }
    });
  }

  void _toggleLayers() {
    setState(() {
      _isLayersExpanded = !_isLayersExpanded;
      if (_isLayersExpanded) {
        _isSearchExpanded = false;
      }
    });
  }

  void closeAll() {
    if (_isSearchExpanded || _isLayersExpanded) {
      setState(() {
        _isSearchExpanded = false;
        _isLayersExpanded = false;
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFiltersCount = widget.activeFilters.length;
    final hasFilterActive = activeFiltersCount < 3;
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicSearchWidth = (screenWidth - 76.0).clamp(240.0, 340.0);
    final railHeight = _isLayersExpanded ? 195.0 : (_isSearchExpanded ? 48.0 : 86.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      height: railHeight,
      child: Stack(
        alignment: Alignment.topLeft,
        clipBehavior: Clip.none,
        children: [
        // 1. Sliding Search Bar (Expands to the right of the top button)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          top: 4.0,
          left: _isSearchExpanded ? 52.0 : 4.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isSearchExpanded ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_isSearchExpanded,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: dynamicSearchWidth,
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xD8121814),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.45),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.accentGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: widget.searchController,
                            onChanged: widget.onSearchChanged,
                            autofocus: _isSearchExpanded,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            cursorColor: AppColors.accentGreen,
                            decoration: const InputDecoration(
                              hintText: 'Поиск по карте...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (widget.searchController.text.isNotEmpty) {
                              widget.onClearSearch();
                            } else {
                              closeAll();
                            }
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 13,
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

        // 2. Sliding Map Layers Drawer Card (Slides to the right of the lower button)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          top: 4.0,
          left: _isLayersExpanded ? 52.0 : 4.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isLayersExpanded ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_isLayersExpanded,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xEA16181C),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.75),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Title & Active Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Слои карты',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$activeFiltersCount активны',
                              style: TextStyle(
                                color: hasFilterActive ? AppColors.accentGreen : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Layer 1: Lost Pets
                        _LayerRowItem(
                          icon: Icons.warning_amber_rounded,
                          title: 'Потерянные питомцы',
                          isActive: widget.activeFilters.contains('lost_pet'),
                          onToggle: () => widget.onToggleFilter('lost_pet'),
                        ),
                        const SizedBox(height: 6),

                        // Layer 2: Playgrounds
                        _LayerRowItem(
                          icon: Icons.park_rounded,
                          title: 'Площадки для собак',
                          isActive: widget.activeFilters.contains('playground'),
                          onToggle: () => widget.onToggleFilter('playground'),
                        ),
                        const SizedBox(height: 6),

                        // Layer 3: Companions
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

        // 3. Base Left Control Rail (Liquid Glass Monolith)
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
                  // Upper Section: Search Button
                  _HeaderRailIconButton(
                    icon: Icons.search_rounded,
                    tooltip: 'Поиск по карте',
                    isSelected: _isSearchExpanded,
                    onTap: _toggleSearch,
                  ),
                  // Lower section collapses while search is open so the rail
                  // shrinks to the top button height (48) without overflowing.
                  if (!_isSearchExpanded) ...[
                    const SizedBox(height: 2),

                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 2),

                    // Lower Section: Layer Filter Button
                    _HeaderRailIconButton(
                      icon: Icons.layers_rounded,
                      tooltip: 'Слои и фильтры карты',
                      isSelected: _isLayersExpanded,
                      hasActiveBadge: hasFilterActive,
                      onTap: _toggleLayers,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
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
                    color: Colors.white.withValues(alpha: 0.85),
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
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 17,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accentGreen : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 13,
                  height: 13,
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

class _HeaderRailIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final bool hasActiveBadge;
  final VoidCallback onTap;

  const _HeaderRailIconButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    this.hasActiveBadge = false,
    required this.onTap,
  });

  @override
  State<_HeaderRailIconButton> createState() => _HeaderRailIconButtonState();
}

class _HeaderRailIconButtonState extends State<_HeaderRailIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
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
                        AppColors.accentGreen.withValues(alpha: 0.30),
                        AppColors.accentGreen.withValues(alpha: 0.15),
                      ],
                    )
                  : null,
              border: isSelected
                  ? Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.60),
                      width: 1.0,
                    )
                  : Border.all(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: isSelected ? AppColors.accentGreen : Colors.white.withValues(alpha: 0.85),
                  size: 18,
                ),
                if (widget.hasActiveBadge && !isSelected)
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGreen,
                            blurRadius: 4,
                          ),
                        ],
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
