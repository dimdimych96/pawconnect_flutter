import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class HeartPopButton extends StatefulWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onTap;

  const HeartPopButton({
    super.key,
    required this.isLiked,
    required this.likesCount,
    required this.onTap,
  });

  @override
  State<HeartPopButton> createState() => _HeartPopButtonState();
}

class _HeartPopButtonState extends State<HeartPopButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final heartColor = widget.isLiked ? AppColors.accentRed : AppColors.textSecondary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isLiked ? AppColors.accentRed.withValues(alpha: 0.15) : AppColors.obsidianGlassSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isLiked ? AppColors.accentRed.withValues(alpha: 0.4) : AppColors.glassBorderSubtle,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: heartColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.likesCount}',
                style: TextStyle(
                  color: heartColor,
                  fontWeight: widget.isLiked ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
