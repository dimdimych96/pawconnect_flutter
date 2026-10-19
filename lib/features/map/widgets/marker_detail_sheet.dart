import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../core/widgets/pill_toast.dart';
import '../../../models/map_marker_model.dart';
import '../../../models/walk_session_model.dart';

class MarkerDetailSheet extends StatelessWidget {
  final MapMarkerModel marker;
  final VoidCallback onClose;
  final VoidCallback? onBuildRoute;
  final void Function(String markerId, String action)? onVerifyHazard;
  final DogTemperament? userTemperament;
  final void Function(String markerId)? onInviteWalk;

  const MarkerDetailSheet({
    super.key,
    required this.marker,
    required this.onClose,
    this.onBuildRoute,
    this.onVerifyHazard,
    this.userTemperament,
    this.onInviteWalk,
  });

  Color _getBadgeColor() {
    switch (marker.type) {
      case 'lost_pet':
        return AppColors.accentRed;
      case 'playground':
        return AppColors.accentGreen;
      case 'companion':
        return AppColors.accentGreen;
      case 'danger':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.accentBlue;
    }
  }

  String _getDangerTypeName(String type) {
    switch (type) {
      case 'poison':
        return '☠️ Отрава / Догхантеры';
      case 'aggressive_pack':
        return '🐕‍🦺 Агрессивная стая';
      case 'broken_glass':
        return '⚠️ Битое стекло';
      default:
        return '⚠️ Опасный участок';
    }
  }

  List<String> _getMockGalleryImages() {
    if (marker.type == 'danger') {
      return [];
    }
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
                                PawToast.show(
                                  context,
                                  title: 'Координаты скопированы',
                                  subtitle: '${marker.latitude.toStringAsFixed(5)}, ${marker.longitude.toStringAsFixed(5)}',
                                  type: ToastType.success,
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

              // Hazard Radar Verification Deck (for danger markers)
              if (marker.type == 'danger') ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 6),
                          const Text(
                            'РАДАР БЕЗОПАСНОСТИ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF59E0B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            marker.dangerType != null ? _getDangerTypeName(marker.dangerType!) : 'Опасная зона',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Подтверждений: ${marker.confirmationsCount}  •  Сообщений об очистке: ${marker.clearedCount}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                onVerifyHazard?.call(marker.id, 'confirm');
                                PawToast.show(
                                  context,
                                  title: 'Актуальность опасности подтверждена (+1)',
                                  type: ToastType.info,
                                );
                              },
                              icon: const Icon(Icons.thumb_up_alt_rounded, size: 14, color: Color(0xFFF59E0B)),
                              label: const Text(
                                'Актуально',
                                style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                onVerifyHazard?.call(marker.id, 'cleared');
                                PawToast.show(
                                  context,
                                  title: 'Отметка об очистке принята',
                                  type: ToastType.success,
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.accentGreen),
                              label: const Text(
                                'Очищено',
                                style: TextStyle(color: AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accentGreen.withValues(alpha: 0.4)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Walk Radar & Compatibility Deck (for companion or walking markers)
              if (marker.type == 'companion' || marker.isWalking) ...[
                _buildWalkRadarCompanionDeck(context),
              ],

              // 4. Primary Action Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (onBuildRoute != null) {
                          onBuildRoute!();
                        }
                        onClose();
                        PawToast.show(
                          context,
                          title: 'Маршрут к "${marker.title}" построен',
                          type: ToastType.info,
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
                          PawToast.show(
                            context,
                            title: 'Ссылка на место скопирована',
                            type: ToastType.success,
                          );
                        } else {
                          PawToast.show(
                            context,
                            title: 'Установка соединения',
                            subtitle: 'Вызываем владельца метки',
                            type: ToastType.info,
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

  Widget _buildWalkRadarCompanionDeck(BuildContext context) {
    final otherTemperament = DogTemperament.fromString(marker.temperament);
    final myTemperament = userTemperament ?? DogTemperament.playful;
    final compat = myTemperament.checkCompatibility(otherTemperament);
    final isPrivate = marker.walkMode == 'private';
    final walkTimeMin = marker.walkStartedAt != null
        ? DateTime.now().difference(marker.walkStartedAt!).inMinutes.clamp(1, 180)
        : 20;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge
          Row(
            children: [
              const Icon(Icons.radar_rounded, size: 16, color: AppColors.accentGreen),
              const SizedBox(width: 6),
              const Text(
                'РАДАР ПРОГУЛОК',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPrivate ? const Color(0xFFA78BFA) : AppColors.accentGreen).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPrivate ? '🛡️ Приватный выгул' : '🌿 Открытый выгул',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPrivate ? const Color(0xFFA78BFA) : AppColors.accentGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Walk telemetry chips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Гуляет ~$walkTimeMin мин',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: otherTemperament.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(otherTemperament.emoji, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      otherTemperament.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: otherTemperament.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Compatibility Matrix Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: compat.badgeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: compat.badgeColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(compat.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compat.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: compat.badgeColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        compat.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Invite to Walk Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                onInviteWalk?.call(marker.id);
                PawToast.show(
                  context,
                  title: 'Приглашение отправлено!',
                  subtitle: 'Владелец получит уведомление на радаре прогулок',
                  type: ToastType.success,
                );
              },
              icon: const Icon(Icons.pets_rounded, size: 15, color: Colors.black),
              label: const Text(
                'Позвать на совместный выгул',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
