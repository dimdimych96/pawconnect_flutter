import 'package:flutter/material.dart';

/// An interactive overlay that wraps a widget (typically a post photo)
/// and triggers a spring/bounce heart burst animation on double-tap or
/// programmatically via [triggerBurst].
class HeartBurstOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDoubleTap;
  final Color? heartColor;
  final double heartSize;
  final Duration duration;

  const HeartBurstOverlay({
    super.key,
    required this.child,
    this.onDoubleTap,
    this.heartColor,
    this.heartSize = 96.0,
    this.duration = const Duration(milliseconds: 500),
  });

  /// Finds the [HeartBurstOverlayState] from the given [context].
  static HeartBurstOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<HeartBurstOverlayState>();
  }

  @override
  HeartBurstOverlayState createState() => HeartBurstOverlayState();
}

class HeartBurstOverlayState extends State<HeartBurstOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Spring/bounce burst animation scaling from 0.0 to 1.3
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    // Smooth fade out towards the end of the burst duration
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Programmatically triggers the spring/bounce heart burst animation.
  void triggerBurst() {
    _controller.forward(from: 0.0);
  }

  void _handleDoubleTap() {
    triggerBurst();
    widget.onDoubleTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _handleDoubleTap,
          child: widget.child,
        ),
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              if (_controller.value == 0.0 && !_controller.isAnimating) {
                return const SizedBox.shrink();
              }

              final opacity = _opacityAnimation.value.clamp(0.0, 1.0);
              final scale = _scaleAnimation.value;

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: Icon(
              Icons.favorite_rounded,
              size: widget.heartSize,
              color: widget.heartColor ?? Colors.white,
              shadows: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Color(0x55F87171),
                  blurRadius: 30,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
