import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../core/widgets/paw_image.dart';
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
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 10.0,
              bottom: 32.0 + MediaQuery.of(context).padding.bottom,
            ),
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

              // 2. Close Button Header
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
              const SizedBox(height: 8),

              // 3. Title, breed, distance
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (marker.image != null)
                    PawImage(
                      url: marker.image,
                      width: 72,
                      height: 72,
                      borderRadius: 16,
                      fallbackColor: badgeColor,
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
                        if (marker.address != null) ...[
                          Text(
                            marker.address!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (marker.breed != null) ...[
                          Text(
                            '${marker.breed}${marker.age != null ? ' • ${marker.age}' : ''}',
                            style: const TextStyle(
                              fontSize: 13,
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
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                  text: '${marker.latitude}, ${marker.longitude}',
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Координаты скопированы! 📋'),
                                    backgroundColor: AppColors.accentGreen,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Text(
                                '${marker.latitude.toStringAsFixed(5)}, ${marker.longitude.toStringAsFixed(5)}',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
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
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Маршрут к "${marker.title}" построен! 🗺'),
                            backgroundColor: AppColors.accentGreen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Маршрут • 5 мин',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (marker.type == 'playground') {
                          Clipboard.setData(ClipboardData(
                            text: 'PawConnect: ${marker.title} - ${marker.address ?? ""}',
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ссылка на место скопирована! 🔗'),
                              backgroundColor: AppColors.accentGreen,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Установка соединения... 📞'),
                              backgroundColor: AppColors.accentBlue,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.obsidianGlassSurface,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          marker.type == 'playground' ? 'Поделиться' : 'Связаться',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: -16,
                        child: Text(
                          '“',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            color: badgeColor.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 22, top: 6),
                        child: Text(
                          marker.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                      child: PawImage(
                        url: mockGallery[idx],
                        width: 100,
                        height: 100,
                        borderRadius: 12,
                        fallbackColor: badgeColor,
                      ),
                    );
                  },
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mockReviews.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final rev = entry.value;
                  final isLast = idx == mockReviews.length - 1;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            rev['author'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.15),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            children: List.generate(5, (starIdx) {
                              return Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: starIdx < (rev['rating'] as int)
                                    ? AppColors.accentYellow
                                    : Colors.white12,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rev['text'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 20,
                          color: AppColors.glassBorderSubtle,
                        )
                      else
                        const SizedBox(height: 8),
                    ],
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
