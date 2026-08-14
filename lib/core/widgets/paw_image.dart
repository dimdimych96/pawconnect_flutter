import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PawAvatar extends StatelessWidget {
  final String? url;
  final String fallbackInitial;
  final double radius;
  final Color? borderColor;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const PawAvatar({
    super.key,
    required this.url,
    this.fallbackInitial = '🐾',
    this.radius = 24.0,
    this.borderColor,
    this.fallbackIcon = Icons.pets_rounded,
    this.fallbackColor = AppColors.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 2.0)
            : Border.all(color: AppColors.glassBorder, width: 1.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fallbackColor.withValues(alpha: 0.25),
            AppColors.obsidianCard,
          ],
        ),
      ),
      child: ClipOval(
        child: (url != null && url!.isNotEmpty)
            ? Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Icon(
        fallbackIcon,
        color: fallbackColor,
        size: radius * 0.9,
      ),
    );
  }
}

class PawImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final IconData fallbackIcon;
  final Color fallbackColor;

  const PawImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 16.0,
    this.fallbackIcon = Icons.pets_rounded,
    this.fallbackColor = AppColors.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _buildFallback();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.obsidianCardTranslucent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.glassBorderSubtle),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fallbackColor.withValues(alpha: 0.20),
            AppColors.obsidianCard,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          color: fallbackColor,
          size: (height != null && height! < 60) ? 22 : 36,
        ),
      ),
    );
  }
}
