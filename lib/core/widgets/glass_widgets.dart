import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Apple Liquid Glass Container with BackdropFilter blur and subtle specular borders
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
    this.borderRadius = 20.0,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.obsidianCardTranslucent;
    final effectiveBorder = borderColor ?? AppColors.glassBorder;

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        // Translucent dark base — the blurred content behind stays visible
        // through the glass (roughly 35% opacity, see obsidianCardTranslucent).
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Liquid Glass specular sheen
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: AppColors.glassSpecular,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );

    Widget glass = Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: glass,
      );
    }

    return glass;
  }
}

/// Glass Card helper with interactive tap animation
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
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: padding,
      borderRadius: borderRadius,
      onTap: onTap,
      borderColor: accentColor != null ? accentColor!.withValues(alpha: 0.3) : AppColors.glassBorder,
      child: child,
    );
  }
}

/// Floating Capsule for filters and tabs
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
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = activeColor ?? AppColors.accentBlue;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: padding,
            decoration: BoxDecoration(
              color: isActive ? effectiveColor.withValues(alpha: 0.25) : AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isActive ? effectiveColor : AppColors.glassBorderSubtle,
                width: isActive ? 1.5 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: effectiveColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
