import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/auth_prompt_modal.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../core/widgets/paw_image.dart';
import '../../core/widgets/pill_toast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/map_provider.dart';
import '../../providers/reminders_provider.dart';
import 'widgets/body_condition_weight_card.dart';
import 'widgets/breed_intelligence_card.dart';
import 'widgets/new_reminder_modal.dart';
import 'widgets/smart_health_milestones_card.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'vaccine':
        return AppColors.accentBlue;
      case 'pill':
        return AppColors.accentGreen;
      case 'vet':
        return AppColors.accentRed;
      case 'grooming':
        return AppColors.accentYellow;
      default:
        return AppColors.accentBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'vaccine':
        return Icons.vaccines_rounded;
      case 'pill':
        return Icons.medication_rounded;
      case 'vet':
        return Icons.local_hospital_rounded;
      case 'grooming':
        return Icons.content_cut_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  void _openNewReminderModal(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    if (!authState.isAuthenticated) {
      AuthPromptModal.show(context, action: 'добавлять ветеринарные напоминания');
      return;
    }
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewReminderModal(
        onAdd: (newReminder) {
          ref.read(remindersNotifierProvider.notifier).addReminder(newReminder);
          PawToast.show(
            context,
            title: 'Напоминание "${newReminder.title}" добавлено',
            type: ToastType.info,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final mapState = ref.watch(mapNotifierProvider);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    final gpsDevice = mapState.gpsDevice;
    final remindersState = ref.watch(remindersNotifierProvider);
    final remindersNotifier = ref.read(remindersNotifierProvider.notifier);
    final healthState = ref.watch(healthNotifierProvider);

    final isBreached = gpsDevice?.isBreached ?? false;
    final currentRadius = gpsDevice?.safeZoneRadius ?? 350.0;
    final safeRadius = currentRadius.toInt();
    final batteryLevel = gpsDevice?.batteryLevel ?? 88;
    final isConnected = gpsDevice?.isConnected ?? true;

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              const Text(
                'Паспорт & Ошейник',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Guest Mode Invitation Banner
              if (!authState.isAuthenticated) ...[
                GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  accentColor: AppColors.accentBlue,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.obsidianGlassSurface,
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(Icons.pets_rounded, color: AppColors.accentBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Демо-просмотр паспорта',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Войдите, чтобы подключить ошейник и настроить зоны безопасности',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => context.push('/auth'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Войти', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Pet Passport Card
              GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(20),
                accentColor: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Pet Avatar with Safety Ring
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            PawAvatar(
                              url: gpsDevice?.photoUrl,
                              radius: 36,
                              fallbackColor: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Pet Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      gpsDevice?.petName ?? 'Макс',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isBreached ? AppColors.accentRed : AppColors.accentGreen).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isBreached ? 'Тревога геозоны' : 'В безопасности',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Золотистый ретривер • 2 года',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                children: [
                                  Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.textSecondary),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Чип: 643094100284912',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Health Profile & Breed Intelligence
              if (healthState.profile != null) ...[
                const SizedBox(height: 16),
                BodyConditionWeightCard(profile: healthState.profile!),
                const SizedBox(height: 16),
                SmartHealthMilestonesCard(profile: healthState.profile!),
                const SizedBox(height: 16),
                BreedIntelligenceCard(
                  breed: healthState.currentBreed,
                  profile: healthState.profile,
                ),
              ],

              const SizedBox(height: 16),

              // 3. GPS Collar Controls Block
              GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.watch_rounded, color: AppColors.textSecondary, size: 18),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'GPS-Ошейник PawConnect',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Connection Status Dot
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isConnected ? AppColors.accentGreen : AppColors.accentYellow,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConnected ? 'В сети' : 'Оффлайн',
                              style: TextStyle(
                                fontSize: 12,
                                color: isConnected ? AppColors.accentGreen : AppColors.accentYellow,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Battery Indicator Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.obsidianGlassSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.battery_charging_full_rounded, color: AppColors.accentGreen, size: 18),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Заряд аккумулятора',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$batteryLevel%',
                            style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Geofence Radius Adjustment with - and +
                    const Text(
                      'Безопасная геозона (Радиус)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.obsidianGlassSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Button Minus (-10m)
                          Semantics(
                            button: true,
                            label: 'Уменьшить радиус геозоны',
                            child: InkWell(
                              onTap: () {
                                if (currentRadius > 50.0) {
                                  mapNotifier.updateSafeZoneRadius(currentRadius - 10.0);
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.obsidianCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: const Icon(Icons.remove, color: AppColors.textPrimary, size: 20),
                              ),
                            ),
                          ),

                          // Radius Display
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$safeRadius м',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  const Text(
                                    'Шаг: ±10 м',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Button Plus (+10m)
                          Semantics(
                            button: true,
                            label: 'Увеличить радиус геозоны',
                            child: InkWell(
                              onTap: () {
                                if (currentRadius < 2000.0) {
                                  mapNotifier.updateSafeZoneRadius(currentRadius + 10.0);
                                }
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.obsidianCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Button "Настроить центр на карте"
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.go('/map');
                        },
                        icon: const Icon(Icons.my_location_rounded, color: AppColors.accentGreen, size: 18),
                        label: const Text(
                          'Настроить центр на карте',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.glassBorder),
                          backgroundColor: AppColors.obsidianGlassSurface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Personal Reminders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Личные напоминания',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Добавить личное напоминание',
                    child: IconButton(
                      onPressed: () => _openNewReminderModal(context, ref),
                      icon: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.obsidianGlassSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(Icons.add, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Reminders List
              if (remindersState.reminders.isEmpty)
                const GlassCard(
                  child: Center(
                    child: Text('Нет запланированных процедур', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else
                ...remindersState.reminders.map((reminder) {
                  final catColor = _getCategoryColor(reminder.category);
                  final catIcon = _getCategoryIcon(reminder.category);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      accentColor: reminder.isCompleted ? AppColors.glassBorder : catColor,
                      child: Row(
                        children: [
                          // Category Icon Box
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.obsidianGlassSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(catIcon, color: catColor, size: 20),
                          ),
                          const SizedBox(width: 12),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: reminder.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                                    decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.event_outlined, size: 14, color: catColor),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${reminder.date.day}.${reminder.date.month}.${reminder.date.year} • ${reminder.time}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: catColor,
                                          fontWeight: FontWeight.w500,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (reminder.notes != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    reminder.notes!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          Switch.adaptive(
                            value: reminder.isCompleted,
                            activeTrackColor: AppColors.accentGreen,
                            onChanged: (val) {
                              remindersNotifier.toggleReminder(reminder.id, val);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
