import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/map_marker_model.dart';
import '../../../models/walk_session_model.dart';

class CompanionWalkMarker extends StatefulWidget {
  final MapMarkerModel marker;
  final VoidCallback onTap;

  const CompanionWalkMarker({
    super.key,
    required this.marker,
    required this.onTap,
  });

  @override
  State<CompanionWalkMarker> createState() => _CompanionWalkMarkerState();
}

class _CompanionWalkMarkerState extends State<CompanionWalkMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _alphaAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );
    _alphaAnimation = Tween<double>(begin: 0.55, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temperament = DogTemperament.fromString(widget.marker.temperament);
    final isPrivate = widget.marker.walkMode == 'private';
    final auraColor = isPrivate ? const Color(0xFFA78BFA) : AppColors.accentGreen;

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Radar Pulse Aura
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: auraColor.withValues(alpha: _alphaAnimation.value),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: auraColor.withValues(alpha: _alphaAnimation.value * 0.7),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 2. Avatar Container
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.obsidianCardTranslucent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: auraColor,
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: auraColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: PawAvatar(
                    url: widget.marker.image,
                    radius: 21,
                    fallbackColor: auraColor,
                    fallbackIcon: Icons.pets_rounded,
                  ),
                ),

                // 3. Temperament Emoji Badge
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.obsidianCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: temperament.color.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      temperament.emoji,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),

                // 4. Privacy Shield (if private walk)
                if (isPrivate)
                  Positioned(
                    left: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA78BFA),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(12, 6),
            painter: _MarkerTrianglePainter(color: auraColor),
          ),
        ],
      ),
    );
  }
}

class _MarkerTrianglePainter extends CustomPainter {
  final Color color;

  _MarkerTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
