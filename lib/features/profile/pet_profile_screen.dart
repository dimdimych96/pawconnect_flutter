import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../providers/map_provider.dart';
import '../../providers/reminders_provider.dart';
import 'widgets/new_reminder_modal.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewReminderModal(
        onAdd: (newReminder) {
          ref.read(remindersNotifierProvider.notifier).addReminder(newReminder);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Напоминание "${newReminder.title}" добавлено!'),
              backgroundColor: AppColors.accentBlue,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapNotifierProvider);
    final mapNotifier = ref.read(mapNotifierProvider.notifier);
    final gpsDevice = mapState.gpsDevice;
    final remindersState = ref.watch(remindersNotifierProvider);
    final remindersNotifier = ref.read(remindersNotifierProvider.notifier);

    final isBreached = gpsDevice?.isBreached ?? false;
    final currentRadius = gpsDevice?.safeZoneRadius ?? 350.0;
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
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Pet Passport Card
              GlassCard(
                borderRadius: 24,
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
                                  width: 3.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isBreached ? AppColors.accentRed : AppColors.accentGreen).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                            ClipOval(
                              child: Image.network(
                                gpsDevice?.photoUrl ?? 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=400&q=80',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppColors.accentGreen,
                                  child: Icon(Icons.pets, size: 36, color: Colors.black),
                                ),
                              ),
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
                                  Text(
                                    gpsDevice?.petName ?? 'Макс',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isBreached ? AppColors.accentRed : AppColors.accentGreen).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                                      ),
                                    ),
                                    child: Text(
                                      isBreached ? '⚠️ ТРЕВОГА' : '🛡 В БЕЗОПАСНОСТИ',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isBreached ? AppColors.accentRed : AppColors.accentGreen,
                                      ),
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
                                  Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.accentBlue),
                                  SizedBox(width: 6),
                                  Text(
                                    'Чип: 643094100284912',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.accentBlue,
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. GPS Collar Controls Block
              GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.watch_rounded, color: AppColors.accentGreen, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'GPS-Ошейник PawConnect',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        // Connection Status Dot
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isConnected ? AppColors.accentGreen : AppColors.accentYellow,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConnected ? 'В сети' : 'Оффлайн',
                              style: TextStyle(
                                fontSize: 13,
                                color: isConnected ? AppColors.accentGreen : AppColors.accentYellow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Battery Indicator Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.obsidianGlassSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.battery_charging_full_rounded, color: AppColors.accentGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Заряд аккумулятора',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                          Text(
                            '$batteryLevel%',
                            style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.obsidianGlassSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Button Minus (-10m)
                          InkWell(
                            onTap: () {
                              if (currentRadius > 50.0) {
                                mapNotifier.updateSafeZoneRadius(currentRadius - 10.0);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.obsidianCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: const Icon(Icons.remove, color: AppColors.textPrimary, size: 20),
                            ),
                          ),

                          // Radius Display
                          Column(
                            children: [
                              Text(
                                '${currentRadius.toInt()} метров',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Шаг: ±10м',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          // Button Plus (+10m)
                          InkWell(
                            onTap: () {
                              if (currentRadius < 2000.0) {
                                mapNotifier.updateSafeZoneRadius(currentRadius + 10.0);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.obsidianCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
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
                        icon: const Icon(Icons.my_location_rounded, color: AppColors.accentGreen),
                        label: const Text(
                          'Настроить центр на карте',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accentGreen),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Vet Calendar Reminders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Вет-календарь',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openNewReminderModal(context, ref),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
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
                      borderRadius: 20,
                      padding: const EdgeInsets.all(16),
                      accentColor: reminder.isCompleted ? AppColors.glassBorder : catColor,
                      child: Row(
                        children: [
                          // Category Icon Box
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: catColor.withValues(alpha: 0.5)),
                            ),
                            child: Icon(catIcon, color: catColor, size: 22),
                          ),
                          const SizedBox(width: 14),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: reminder.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                                    decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.event_outlined, size: 14, color: catColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${reminder.date.day}.${reminder.date.month}.${reminder.date.year} • ${reminder.time}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: catColor,
                                        fontWeight: FontWeight.w600,
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
                            activeColor: AppColors.accentGreen,
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
