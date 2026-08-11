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

  List<String> _getMockGalleryImages() {
    if (marker.type == 'lost_pet' || marker.type == 'companion') {
      return [
        marker.image ?? 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1534361960057-19889db9621e?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=300&q=80',
      ];
    } else {
      return [
        'https://images.unsplash.com/photo-1596492784531-6e6eb5ea9993?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=300&q=80',
        'https://images.unsplash.com/photo-1530281700549-e82e7bf110d6?auto=format&fit=crop&w=300&q=80',
      ];
    }
  }

  List<Map<String, dynamic>> _getMockReviews() {
    if (marker.type == 'playground') {
      return [
        {'author': 'Мария', 'rating': 5, 'text': 'Отличное место, всегда чисто и много дружелюбных собак.'},
        {'author': 'Алексей', 'rating': 4, 'text': 'Есть барьеры для тренировок, но вечером бывает людно.'},
      ];
    } else if (marker.type == 'lost_pet') {
      return [
        {'author': 'Анна', 'rating': 5, 'text': 'Видела похожего пса полчаса назад около Центрального парка!'},
        {'author': 'Игорь', 'rating': 4, 'text': 'Надеюсь, малыш найдется. Сделал репост в чат района.'},
      ];
    } else {
      return [
        {'author': 'Елена', 'rating': 5, 'text': 'Отличный напарник для утренних пробежек в парке.'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();
    final mockGallery = _getMockGalleryImages();
    final mockReviews = _getMockReviews();

    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.16,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.16, 0.32, 0.85],
      builder: (BuildContext context, ScrollController scrollController) {
        return GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: 24.0,
          borderColor: badgeColor.withValues(alpha: 0.35),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Badge & Close Button Header
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
                        fontSize: 11,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Title, breed, distance
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (marker.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        marker.image!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: AppColors.obsidianGlassSurface,
                          child: Icon(Icons.pets, color: badgeColor, size: 32),
                        ),
                      ),
                    ),
                  if (marker.image != null) const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (marker.breed != null) ...[
                          Text(
                            '${marker.breed}${marker.age != null ? ' • ${marker.age}' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.accentGreen),
                            const SizedBox(width: 4),
                            Text(
                              '~450 м от вас',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.accentGreen.withValues(alpha: 0.9),
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
              const SizedBox(height: 16),

              // 4. Primary Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Маршрут к "${marker.title}" построен! 🗺'),
                            backgroundColor: AppColors.accentGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.directions_rounded, color: Colors.black, size: 20),
                      label: const Text('Маршрут', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Установка соединения... 📞'),
                            backgroundColor: AppColors.accentBlue,
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone_rounded, color: AppColors.textPrimary, size: 18),
                      label: const Text('Связаться', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.glassBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Description Block
              if (marker.description != null) ...[
                const Text(
                  'Описание',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    marker.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 6. Photo Gallery Block
              const Text(
                'Фотогалерея',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mockGallery.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          mockGallery[idx],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: AppColors.obsidianGlassSurface,
                            child: const Icon(Icons.image_rounded, color: Colors.white24, size: 30),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 7. Coordinates & Location Card
              const Text(
                'Адрес и координаты',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.map_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            marker.type == 'playground'
                                ? 'Новосибирск, Центральный район'
                                : 'Новосибирск, в радиусе 1 км от центра',
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: AppColors.glassBorderSubtle),
                    Text(
                      'Широта: ${marker.latitude.toStringAsFixed(6)}\nДолгота: ${marker.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 8. Reviews / Info Block
              Text(
                marker.type == 'playground' ? 'Отзывы собаководов' : 'Последние обновления',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: mockReviews.map((rev) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rev['author'] as String,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Row(
                                children: List.generate(5, (starIdx) {
                                  return Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: starIdx < (rev['rating'] as int) ? AppColors.accentYellow : Colors.white12,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rev['text'] as String,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
