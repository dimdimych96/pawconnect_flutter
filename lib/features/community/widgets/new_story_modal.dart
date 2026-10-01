import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/pet_story_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/community_service.dart';

class NewStoryModal extends ConsumerStatefulWidget {
  final Future<void> Function(PetStoryModel) onPublish;

  const NewStoryModal({
    super.key,
    required this.onPublish,
  });

  @override
  ConsumerState<NewStoryModal> createState() => _NewStoryModalState();
}

class _NewStoryModalState extends ConsumerState<NewStoryModal> {
  final _petNameController = TextEditingController();
  final _statusController = TextEditingController();
  final _customUrlController = TextEditingController();

  String _selectedDistrict = 'Центральный';
  String _selectedVisibility = 'district';
  bool _isPublishingAsTeam = false;
  bool _isPublishing = false;
  String? _errorMessage;

  static const List<String> _mediaPresets = [
    'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
  ];

  late String _selectedMediaUrl;

  @override
  void initState() {
    super.initState();
    _selectedMediaUrl = _mediaPresets.first;
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _statusController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isPublishing) return;

    final status = _statusController.text.trim();
    if (status.isEmpty) {
      setState(() => _errorMessage = 'Введите статус или описание выгула');
      return;
    }

    final mediaUrl = _customUrlController.text.trim().isNotEmpty
        ? _customUrlController.text.trim()
        : _selectedMediaUrl;

    setState(() {
      _isPublishing = true;
      _errorMessage = null;
    });

    final currentUser = ref.read(authNotifierProvider).currentUser;
    final authorName = _isPublishingAsTeam ? 'PawConnect Team' : (currentUser?.name ?? 'Владелец');
    final authorAvatar = _isPublishingAsTeam
        ? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80'
        : (currentUser?.avatarUrl ??
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80');

    final petName = _petNameController.text.trim().isNotEmpty
        ? _petNameController.text.trim()
        : (_isPublishingAsTeam ? 'Совет дня' : null);

    final newStory = PetStoryModel(
      id: 'story-${DateTime.now().millisecondsSinceEpoch}',
      authorId: currentUser?.id,
      authorName: authorName,
      isOfficial: _isPublishingAsTeam,
      authorAvatar: authorAvatar,
      petName: petName,
      district: _selectedDistrict,
      mediaUrl: mediaUrl,
      statusText: status,
      visibility: _selectedVisibility,
      createdAt: DateTime.now(),
      isViewed: false,
    );

    try {
      await widget.onPublish(newStory);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Не удалось опубликовать историю. Проверьте соединение.';
        if (e is DioException) {
          if (e.response?.data is Map && e.response?.data['detail'] != null) {
            msg = e.response!.data['detail'].toString();
          } else if (e.response?.statusCode == 401) {
            msg = 'Сессия истекла. Пожалуйста, выполните вход заново.';
          } else if (e.response?.statusCode == 403) {
            msg = 'У вас нет прав для публикации официальной истории.';
          } else if (e.response?.statusCode == 422) {
            msg = 'Проверьте заполнение всех полей истории.';
          }
        }
        setState(() {
          _isPublishing = false;
          _errorMessage = msg;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authNotifierProvider).currentUser;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: GlassCard(
        borderRadius: 28,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Новая история',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Admin Author Switcher (Лично vs PawConnect Team)
              if (currentUser != null && currentUser.canPublishAsTeam) ...[
                const Text(
                  'Автор истории',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianGlassSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorderSubtle),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPublishingAsTeam = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              color: !_isPublishingAsTeam ? AppColors.accentBlue.withValues(alpha: 0.3) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: !_isPublishingAsTeam ? AppColors.accentBlue : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PawAvatar(
                                  url: currentUser.avatarUrl,
                                  radius: 10,
                                  fallbackIcon: Icons.person,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    currentUser.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: !_isPublishingAsTeam ? FontWeight.bold : FontWeight.normal,
                                      color: !_isPublishingAsTeam ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPublishingAsTeam = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _isPublishingAsTeam ? AppColors.accentGreen.withValues(alpha: 0.25) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isPublishingAsTeam ? AppColors.accentGreen : Colors.transparent,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified, size: 15, color: AppColors.accentGreen),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'PawConnect Team',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Error notification banner
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.accentRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Photos Presets Carousel
              const Text(
                'Фотография истории',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final url = _mediaPresets[index];
                    final isSelected = _selectedMediaUrl == url && _customUrlController.text.isEmpty;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMediaUrl = url;
                          _customUrlController.clear();
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.accentBlue : AppColors.glassBorderSubtle,
                            width: isSelected ? 2.5 : 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.obsidianGlassSurface,
                                  child: const Center(
                                    child: Icon(Icons.pets_rounded, color: AppColors.accentBlue, size: 24),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBlue.withValues(alpha: 0.35),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // District Selector
              const Text(
                'Район выгула',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDistrict,
                    isExpanded: true,
                    dropdownColor: AppColors.obsidianCard,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.accentBlue),
                    items: CommunityService.novosibirskDistricts
                        .where((d) => d != 'Все районы')
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDistrict = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Pet Name (optional)
              TextField(
                controller: _petNameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Кличка питомца (необязательно)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  hintText: 'Например: Бадди, Майло...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.obsidianGlassSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.glassBorderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Status / Walk caption
              TextField(
                controller: _statusController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Статус выгула / Чем вы заняты',
                  labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  hintText: 'Гуляем в Нарымском сквере, кто с нами? 🦮',
                  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  filled: true,
                  fillColor: AppColors.obsidianGlassSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.glassBorderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Visibility selection (Discovery vs Followers)
              const Text(
                'Кто может видеть историю',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedVisibility = 'district'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedVisibility == 'district'
                              ? AppColors.accentBlue.withValues(alpha: 0.2)
                              : AppColors.obsidianGlassSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedVisibility == 'district' ? AppColors.accentBlue : AppColors.glassBorderSubtle,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.public_rounded,
                              size: 16,
                              color: _selectedVisibility == 'district' ? AppColors.accentBlue : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Весь район',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _selectedVisibility == 'district' ? FontWeight.bold : FontWeight.normal,
                                  color: _selectedVisibility == 'district' ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedVisibility = 'followers'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedVisibility == 'followers'
                              ? AppColors.accentBlue.withValues(alpha: 0.2)
                              : AppColors.obsidianGlassSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedVisibility == 'followers' ? AppColors.accentBlue : AppColors.glassBorderSubtle,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.group_rounded,
                              size: 16,
                              color: _selectedVisibility == 'followers' ? AppColors.accentBlue : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Подписчики',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _selectedVisibility == 'followers' ? FontWeight.bold : FontWeight.normal,
                                  color: _selectedVisibility == 'followers' ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('submit_new_story_button'),
                  onPressed: _isPublishing ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    disabledBackgroundColor: AppColors.accentBlue.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isPublishing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Опубликовать историю (на 24 часа)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
