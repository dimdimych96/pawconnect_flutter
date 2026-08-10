import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../models/map_marker_model.dart';

class MarkerDetailSheet extends StatelessWidget {
  final MapMarkerModel marker;
  final VoidCallback onClose;

  const MarkerDetailSheet({
    super.key,
    required this.marker,
    required this.onClose,
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

  String _getTypeLabel() {
    switch (marker.type) {
      case 'lost_pet':
        return '🚨 ПОТЕРЯШКА';
      case 'playground':
        return '🦮 ПЛОЩАДКА';
      case 'companion':
        return '🐾 КОМПАНЬОН';
      default:
        return 'МЕТКА';
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassCard(
        accentColor: badgeColor,
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handle bar & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    _getTypeLabel(),
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: onClose,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image & Header Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (marker.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      marker.image!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.obsidianGlassSurface,
                        child: Icon(Icons.pets, color: badgeColor, size: 36),
                      ),
                    ),
                  ),
                if (marker.image != null) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marker.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (marker.breed != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${marker.breed}${marker.age != null ? ' • ${marker.age}' : ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppColors.accentGreen),
                          SizedBox(width: 4),
                          Text(
                            '~450 м от вас',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (marker.description != null) ...[
              const SizedBox(height: 14),
              Text(
                marker.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Маршрут к "${marker.title}" построен!'),
                          backgroundColor: AppColors.accentGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_rounded, color: Colors.black),
                    label: const Text('Маршрут', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Вызов контакта...'),
                          backgroundColor: AppColors.accentBlue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_rounded, color: AppColors.textPrimary),
                    label: const Text('Связаться', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.glassBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
