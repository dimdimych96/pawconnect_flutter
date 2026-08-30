import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../core/widgets/paw_image.dart';
import '../../core/widgets/pill_toast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/edit_profile_modal.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openEditProfileModal(BuildContext context, WidgetRef ref, String currentName, String currentAvatar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModal(
        currentName: currentName,
        currentAvatar: currentAvatar,
        onSave: (newName, newAvatar) {
          ref.read(userNotifierProvider.notifier).updateProfile(newName, newAvatar);
          ref.read(authNotifierProvider.notifier).updateProfile(newName, newAvatar);
          PawToast.show(
            context,
            title: 'Профиль владельца обновлен',
            type: ToastType.success,
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.obsidianCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Выход из аккаунта', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text(
          'Вы действительно хотите выйти? Данные GPS-ошейника Макса останутся привязаны к вашему профилю.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                PawToast.show(
                  context,
                  title: 'Выполнен выход из аккаунта',
                  type: ToastType.alert,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Выйти', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    final ownerName = authState.currentUser?.name ?? userState.ownerName;
    final ownerAvatar = authState.currentUser?.avatarUrl ?? userState.ownerAvatar;
    final ownerEmail = authState.currentUser?.email ?? 'alex@pawconnect.app';

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
          children: [
            const Text(
              'Настройки',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Owner Profile Card
            GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(18),
              onTap: () => _openEditProfileModal(context, ref, ownerName, ownerAvatar),
              child: Row(
                children: [
                  PawAvatar(
                    url: ownerAvatar,
                    radius: 30,
                    fallbackColor: AppColors.accentBlue,
                    fallbackIcon: Icons.person_rounded,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ownerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$ownerEmail • Редактировать',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_rounded, color: AppColors.accentBlue, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Preferences & Notifications
            GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _ToggleRow(
                    label: 'Push-уведомления о питомце',
                    subtitle: 'Оповещения о геозоне, заряде ошейника и событиях',
                    value: userState.pushNotificationsEnabled,
                    icon: Icons.notifications_active_rounded,
                    activeColor: AppColors.accentGreen,
                    onChanged: (val) {
                      userNotifier.togglePushNotifications(val);
                      PawToast.show(
                        context,
                        title: val ? 'Push-уведомления включены' : 'Push-уведомления выключены',
                        type: ToastType.info,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Diagnostics & System Info
            GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Диагностика системы',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _DiagnosticRow(
                    label: 'GPS-модем ошейника',
                    value: 'Подключен (LTE-M)',
                    icon: Icons.satellite_alt_rounded,
                    color: AppColors.accentGreen,
                  ),
                  Divider(height: 16, color: AppColors.glassBorderSubtle),
                  _DiagnosticRow(
                    label: 'Бэкенд REST API',
                    value: 'Online (JWT Session Active)',
                    icon: Icons.cloud_done_rounded,
                    color: AppColors.accentGreen,
                  ),
                  Divider(height: 16, color: AppColors.glassBorderSubtle),
                  const _DiagnosticRow(
                    label: 'Задержка сети (Ping)',
                    value: '24 ms',
                    icon: Icons.speed_rounded,
                    color: AppColors.accentGreen,
                  ),
                  Divider(height: 16, color: AppColors.glassBorderSubtle),
                  const _DiagnosticRow(
                    label: 'Версия приложения',
                    value: 'v1.0.4-liquid-glass',
                    icon: Icons.info_outline_rounded,
                    color: AppColors.accentYellow,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
                label: const Text(
                  'Выйти из аккаунта',
                  style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accentRed.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final IconData icon;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentBlue, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

