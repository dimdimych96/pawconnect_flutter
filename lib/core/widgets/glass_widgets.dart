import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Floating Glass Container with BackdropFilter blur strictly for navigation chrome & overlays.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double blur;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.blur = 16.0,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.obsidianCardTranslucent;
    final effectiveBorder = borderColor ?? AppColors.glassBorder;

    final Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: 1.0,
        ),
      ),
      child: child,
    );

    final Widget glass = Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: blur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: content,
              )
            : content,
      ),
    );

    if (onTap != null) {
      return Semantics(
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: glass,
        ),
      );
    }

    return glass;
  }
}

/// Content Card surface without expensive GPU BackdropFilter blur or neon borders.
/// Follows Apple Liquid Glass & Unslop rules: content sits on calm graphite surfaces
/// with a 1px hairline border; glass blur is reserved strictly for floating chrome.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accentColor;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accentColor,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.0,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Semantics(
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Compact control button / filter chip without neon glow or scroll-jank blur.
class GlassCapsule extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const GlassCapsule({
    super.key,
    required this.child,
    this.isActive = false,
    this.activeColor,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = activeColor ?? AppColors.textPrimary;

    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: const Cubic(0.22, 1.0, 0.36, 1.0),
          padding: padding,
          decoration: BoxDecoration(
            color: isActive
                ? effectiveColor.withValues(alpha: 0.14)
                : AppColors.obsidianGlassSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? effectiveColor.withValues(alpha: 0.35)
                  : AppColors.glassBorderSubtle,
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
