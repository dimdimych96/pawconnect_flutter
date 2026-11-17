import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../core/widgets/pill_toast.dart';
import '../../../models/map_marker_model.dart';
import '../../../models/walk_session_model.dart';

class MarkerDetailSheet extends StatelessWidget {
  final MapMarkerModel marker;
  final LatLng? userLocation;
  final VoidCallback onClose;
  final VoidCallback? onBuildRoute;
  final void Function(String markerId, String action)? onVerifyHazard;
  final DogTemperament? userTemperament;
  final void Function(String markerId)? onInviteWalk;

  const MarkerDetailSheet({
    super.key,
    required this.marker,
    this.userLocation,
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
        return AppColors.accentYellow;
      default:
        return AppColors.accentBlue;
    }
  }

  String _getDangerTypeName(String type) {
    switch (type) {
      case 'poison':
        return 'Отрава / Догхантеры';
      case 'aggressive_pack':
        return 'Агрессивная стая';
      case 'broken_glass':
        return 'Битое стекло';
      default:
        return 'Опасный участок';
    }
  }

  IconData _getDangerTypeIcon(String? type) {
    switch (type) {
      case 'poison':
        return Icons.science_outlined;
      case 'aggressive_pack':
        return Icons.pets_rounded;
      case 'broken_glass':
        return Icons.warning_amber_rounded;
      default:
        return Icons.report_problem_outlined;
    }
  }

  String? _getDistanceText() {
    if (userLocation == null) return null;
    final meters = const Distance().as(
      LengthUnit.Meter,
      userLocation!,
      LatLng(marker.latitude, marker.longitude),
    ).round();
    if (meters < 1000) {
      return '$meters м от вас';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} км от вас';
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();
    final hasImage = marker.image != null && marker.image!.isNotEmpty;
    final distText = _getDistanceText();

    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.16,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.16, 0.32, 0.85],
      builder: (BuildContext context, ScrollController scrollController) {
        return GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: 20.0,
          borderColor: AppColors.glassBorder,
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 12.0,
              bottom: 32.0 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 2. Close Button Header
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Semantics(
                    button: true,
                    label: 'Закрыть карточку',
                    child: InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.obsidianRaised,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // 3. Header Info (Type badge, Title, Distance, Coords)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type Badge (Clean, sentence case)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            marker.type == 'lost_pet'
                                ? 'Потерялся питомец'
                                : marker.type == 'playground'
                                    ? 'Площадка для выгула'
                                    : marker.type == 'companion'
                                        ? 'Ищу компанию'
                                        : marker.type == 'danger'
                                            ? 'Зона опасности'
                                            : 'Метка',
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          marker.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
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
                            if (distText != null) ...[
                              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.accentGreen),
                              const SizedBox(width: 4),
                              Text(
                                distText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.accentGreen.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '•',
                                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Semantics(
                              button: true,
                              label: 'Скопировать координаты',
                              child: GestureDetector(
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
                                child: Row(
                                  children: [
                                    const Icon(Icons.copy_rounded, size: 12, color: AppColors.textTertiary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${marker.latitude.toStringAsFixed(4)}, ${marker.longitude.toStringAsFixed(4)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textTertiary,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
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
                    color: AppColors.obsidianRaised,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accentYellow.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: AppColors.accentYellow),
                          const SizedBox(width: 6),
                          const Text(
                            'Радар безопасности',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentYellow,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _getDangerTypeIcon(marker.dangerType),
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            marker.dangerType != null ? _getDangerTypeName(marker.dangerType!) : 'Опасная зона',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Подтверждений: ${marker.confirmationsCount}  •  Сообщений об очистке: ${marker.clearedCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                              icon: const Icon(Icons.thumb_up_alt_rounded, size: 14, color: AppColors.accentYellow),
                              label: const Text(
                                'Актуально',
                                style: TextStyle(color: AppColors.accentYellow, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accentYellow.withValues(alpha: 0.4)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
                                style: TextStyle(color: AppColors.accentGreen, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accentGreen.withValues(alpha: 0.4)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
                    child: Semantics(
                      button: true,
                      label: 'Построить маршрут',
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
                          height: 44,
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.4),
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Маршрут',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: marker.type == 'playground' ? 'Поделиться ссылкой' : 'Связаться с автором',
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
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.obsidianRaised,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            marker.type == 'playground' ? 'Поделиться' : 'Связаться',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Description Block (Clean text, no decorative Georgia quote or italic)
              if (marker.description != null && marker.description!.isNotEmpty) ...[
                const Text(
                  'Описание',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  marker.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 6. Photo Block (Shown only if marker has a real image URL)
              if (hasImage) ...[
                const Text(
                  'Фотография',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                PawImage(
                  url: marker.image,
                  width: double.infinity,
                  height: 160,
                  borderRadius: 12,
                  fallbackColor: badgeColor,
                ),
                const SizedBox(height: 16),
              ],
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
    final modeColor = isPrivate ? const Color(0xFF8B7FD1) : AppColors.accentGreen;
    final walkTimeMin = marker.walkStartedAt != null
        ? DateTime.now().difference(marker.walkStartedAt!).inMinutes.clamp(1, 180)
        : 20;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.obsidianRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge (Sentence case, vector icons)
          Row(
            children: [
              const Icon(Icons.radar_rounded, size: 16, color: AppColors.accentGreen),
              const SizedBox(width: 6),
              const Text(
                'Радар прогулок',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentGreen,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPrivate ? Icons.shield_outlined : Icons.public_rounded,
                      size: 13,
                      color: modeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPrivate ? 'Приватный выгул' : 'Открытый выгул',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: modeColor,
                      ),
                    ),
                  ],
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
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Гуляет ~$walkTimeMin мин',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: otherTemperament.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: otherTemperament.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
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
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: compat.badgeColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_rounded, size: 18, color: compat.badgeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compat.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: compat.badgeColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        compat.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.3,
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
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                onInviteWalk?.call(marker.id);
                PawToast.show(
                  context,
                  title: 'Приглашение отправлено',
                  subtitle: 'Владелец получит уведомление на радаре прогулок',
                  type: ToastType.success,
                );
              },
              icon: const Icon(Icons.pets_rounded, size: 16, color: Colors.black),
              label: const Text(
                'Позвать на совместный выгул',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
