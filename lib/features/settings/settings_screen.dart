import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/glass_widgets.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Профиль владельца обновлен!'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Выполнен выход из аккаунта'),
                  backgroundColor: AppColors.accentRed,
                ),
              );
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
              onTap: () => _openEditProfileModal(context, ref, userState.ownerName, userState.ownerAvatar),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.accentBlue,
                    backgroundImage: NetworkImage(userState.ownerAvatar),
                    child: null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userState.ownerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Владелец Макса • Редактировать',
                          style: TextStyle(
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
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_rounded, color: AppColors.accentBlue),
                    title: const Text('Push-уведомления геозоны', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Мгновенные оповещения при побеге', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    trailing: Switch.adaptive(
                      value: userState.pushNotificationsEnabled,
                      activeThumbColor: AppColors.accentGreen,
                      onChanged: (val) => userNotifier.togglePushNotifications(val),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.glassBorderSubtle),
                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded, color: AppColors.accentRed),
                    title: const Text('Симуляция тревоги (Тест Аларма)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Вызов аварийного баннера поверх экрана', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    trailing: Switch.adaptive(
                      value: userState.isSimulatingBreach,
                      activeThumbColor: AppColors.accentRed,
                      onChanged: (val) => userNotifier.toggleSimulateBreach(val),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. System Diagnostics Panel
            const Text(
              'Диагностика системы',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const GlassCard(
              borderRadius: 24,
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  _DiagnosticRow(
                    label: 'Платформа',
                    value: 'Flutter Web (Dart 3.x)',
                    icon: Icons.computer_rounded,
                    color: AppColors.accentBlue,
                  ),
                  Divider(height: 16, color: AppColors.glassBorderSubtle),
                  _DiagnosticRow(
                    label: 'Бэкенд REST API',
                    value: 'Online (Mock Active)',
                    icon: Icons.cloud_done_rounded,
                    color: AppColors.accentGreen,
                  ),
                  Divider(height: 16, color: AppColors.glassBorderSubtle),
                  _DiagnosticRow(
                    label: 'Задержка сети (Ping)',
                    value: '24 ms',
                    icon: Icons.speed_rounded,
                    color: AppColors.accentGreen,
                  ),
                  Divider(height: 16, color: AppColors.glassBorderSubtle),
                  _DiagnosticRow(
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
                onPressed: () => _showLogoutDialog(context),
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
