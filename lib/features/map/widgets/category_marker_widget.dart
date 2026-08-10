import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../models/map_marker_model.dart';

class CategoryMarkerWidget extends StatelessWidget {
  final MapMarkerModel marker;
  final VoidCallback onTap;

  const CategoryMarkerWidget({
    super.key,
    required this.marker,
    required this.onTap,
  });

  Color _getBadgeColor() {
    switch (marker.type) {
      case 'lost_pet':
        return AppColors.accentRed;
      case 'playground':
        return AppColors.accentGreen;
      case 'companion':
        return AppColors.accentBlue;
      default:
        return AppColors.accentBlue;
    }
  }

  IconData _getIcon() {
    switch (marker.type) {
      case 'lost_pet':
        return Icons.warning_rounded;
      case 'playground':
        return Icons.park_rounded;
      case 'companion':
        return Icons.pets_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.obsidianCardTranslucent,
              shape: BoxShape.circle,
              border: Border.all(
                color: badgeColor,
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: marker.image != null
                  ? Image.network(
                      marker.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(_getIcon(), color: badgeColor, size: 22),
                    )
                  : Icon(_getIcon(), color: badgeColor, size: 22),
            ),
          ),
          CustomPaint(
            size: const Size(12, 6),
            painter: _TrianglePainter(color: badgeColor),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

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
