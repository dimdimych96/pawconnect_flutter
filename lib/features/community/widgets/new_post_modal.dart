import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../models/community_post_model.dart';
import '../../../services/community_service.dart';

class NewPostModal extends StatefulWidget {
  final Function(CommunityPostModel) onPublish;

  const NewPostModal({
    super.key,
    required this.onPublish,
  });

  @override
  State<NewPostModal> createState() => _NewPostModalState();
}

class _NewPostModalState extends State<NewPostModal> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedDistrict = 'Центральный';
  String _selectedCategory = 'general';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) return;

    final newPost = CommunityPostModel(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Вы (Алексей)',
      authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      district: _selectedDistrict,
      category: _selectedCategory,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      likesCount: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    );

    widget.onPublish(newPost);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Новая запись в ленту',
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
            const SizedBox(height: 16),

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
                hintText: 'Заголовок посты...',
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Опубликовать пост',
                  style: TextStyle(
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
