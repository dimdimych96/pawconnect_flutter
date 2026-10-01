import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/community_post_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/community_service.dart';

class NewPostModal extends ConsumerStatefulWidget {
  final Future<void> Function(CommunityPostModel) onPublish;
  final CommunityPostModel? initialPost;

  const NewPostModal({
    super.key,
    required this.onPublish,
    this.initialPost,
  });

  @override
  ConsumerState<NewPostModal> createState() => _NewPostModalState();
}

class _NewPostModalState extends ConsumerState<NewPostModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedDistrict = 'Центральный';
  String _selectedCategory = 'general';
  bool _isPublishingAsTeam = false;
  bool _isPublishing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialPost != null) {
      _titleController.text = widget.initialPost!.title;
      _contentController.text = widget.initialPost!.content;
      _selectedDistrict = widget.initialPost!.district;
      _selectedCategory = widget.initialPost!.category;
      _isPublishingAsTeam = widget.initialPost!.isOfficial;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isPublishing) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      setState(() => _errorMessage = 'Введите заголовок публикации');
      return;
    }
    if (content.isEmpty) {
      setState(() => _errorMessage = 'Введите текст публикации');
      return;
    }

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

    final postToSave = widget.initialPost != null
        ? widget.initialPost!.copyWith(
            district: _selectedDistrict,
            category: _selectedCategory,
            title: title,
            content: content,
            isOfficial: _isPublishingAsTeam,
            authorName: authorName,
            authorAvatar: authorAvatar,
          )
        : CommunityPostModel(
            id: 'post-${DateTime.now().millisecondsSinceEpoch}',
            authorId: currentUser?.id,
            authorName: authorName,
            authorAvatar: authorAvatar,
            isOfficial: _isPublishingAsTeam,
            district: _selectedDistrict,
            category: _selectedCategory,
            title: title,
            content: content,
            likesCount: 0,
            isLiked: false,
            createdAt: DateTime.now(),
          );

    try {
      await widget.onPublish(postToSave);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = widget.initialPost != null
            ? 'Не удалось сохранить изменения. Проверьте соединение.'
            : 'Не удалось опубликовать запись. Проверьте соединение.';
        if (e is DioException) {
          if (e.response?.data is Map && e.response?.data['detail'] != null) {
            msg = e.response!.data['detail'].toString();
          } else if (e.response?.statusCode == 401) {
            msg = 'Сессия истекла. Пожалуйста, выполните вход заново.';
          } else if (e.response?.statusCode == 403) {
            msg = 'У вас нет прав для редактирования этой публикации.';
          } else if (e.response?.statusCode == 422) {
            msg = 'Проверьте заполнение всех полей публикации.';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialPost != null ? 'Редактировать запись' : 'Новая запись в ленту',
                  style: const TextStyle(
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
            const SizedBox(height: 16),

            if (currentUser != null && currentUser.canPublishAsTeam) ...[
              const Text(
                'Автор публикации',
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

            // District Selector Dropdown / Menu
            const Text(
              'Выберите район Новосибирска',
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

            // Topic Category Selection
            const Text(
              'Тема публикации',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TopicChip(
                    label: 'Общее',
                    category: 'general',
                    color: AppColors.accentBlue,
                    isSelected: _selectedCategory == 'general',
                    onTap: () => setState(() => _selectedCategory = 'general'),
                  ),
                  const SizedBox(width: 8),
                  _TopicChip(
                    label: '🏥 Здоровье',
                    category: 'health',
                    color: AppColors.accentGreen,
                    isSelected: _selectedCategory == 'health',
                    onTap: () => setState(() => _selectedCategory = 'health'),
                  ),
                  const SizedBox(width: 8),
                  _TopicChip(
                    label: '🦮 Дрессировка',
                    category: 'training',
                    color: AppColors.accentBlue,
                    isSelected: _selectedCategory == 'training',
                    onTap: () => setState(() => _selectedCategory = 'training'),
                  ),
                  const SizedBox(width: 8),
                  _TopicChip(
                    label: '🚨 SOS',
                    category: 'sos',
                    color: AppColors.accentRed,
                    isSelected: _selectedCategory == 'sos',
                    onTap: () => setState(() => _selectedCategory = 'sos'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Заголовок записи...',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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

            // Content Field
            TextField(
              controller: _contentController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Расскажите подробнее сообществу районов...',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
            const SizedBox(height: 20),

            // Publish Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const ValueKey('submit_new_post_button'),
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
                    : Text(
                        widget.initialPost != null ? 'Сохранить изменения' : 'Опубликовать запись',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

class _TopicChip extends StatelessWidget {
  final String label;
  final String category;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.category,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : AppColors.obsidianGlassSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
