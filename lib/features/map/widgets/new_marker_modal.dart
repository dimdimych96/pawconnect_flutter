import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../models/map_marker_model.dart';

class NewMarkerModal extends StatefulWidget {
  final double currentLat;
  final double currentLng;
  final Function(MapMarkerModel) onAdd;

  const NewMarkerModal({
    super.key,
    required this.currentLat,
    required this.currentLng,
    required this.onAdd,
  });

  @override
  State<NewMarkerModal> createState() => _NewMarkerModalState();
}

class _NewMarkerModalState extends State<NewMarkerModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _breedController = TextEditingController();
  String _selectedType = 'lost_pet';
  String _selectedDangerType = 'poison';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final newMarker = MapMarkerModel(
      id: 'marker-${DateTime.now().millisecondsSinceEpoch}',
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      latitude: widget.currentLat + (0.001 - (0.002 * (DateTime.now().millisecond / 1000))),
      longitude: widget.currentLng + (0.001 - (0.002 * (DateTime.now().microsecond / 1000))),
      breed: _selectedType == 'danger' ? null : (_breedController.text.trim().isEmpty ? null : _breedController.text.trim()),
      age: 'Не указан',
      dangerType: _selectedType == 'danger' ? _selectedDangerType : null,
      confirmationsCount: _selectedType == 'danger' ? 1 : 0,
      createdAt: DateTime.now(),
    );

    widget.onAdd(newMarker);
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
                  'Новое объявление на карте',
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

            // Type Segmented Selection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TypeChip(
                  label: '🚨 Потеряшка',
                  type: 'lost_pet',
                  color: AppColors.accentRed,
                  isSelected: _selectedType == 'lost_pet',
                  onTap: () => setState(() => _selectedType = 'lost_pet'),
                ),
                _TypeChip(
                  label: '🦮 Площадка',
                  type: 'playground',
                  color: AppColors.accentGreen,
                  isSelected: _selectedType == 'playground',
                  onTap: () => setState(() => _selectedType = 'playground'),
                ),
                _TypeChip(
                  label: '🐾 Прогулка',
                  type: 'companion',
                  color: AppColors.accentBlue,
                  isSelected: _selectedType == 'companion',
                  onTap: () => setState(() => _selectedType = 'companion'),
                ),
                _TypeChip(
                  label: '⚠️ Опасность',
                  type: 'danger',
                  color: const Color(0xFFF59E0B),
                  isSelected: _selectedType == 'danger',
                  onTap: () => setState(() => _selectedType = 'danger'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Danger Type Sub-selector (if danger selected)
            if (_selectedType == 'danger') ...[
              const Text(
                'Тип угрозы (Радар безопасности):',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ChoiceChip(
                    label: const Text('☠️ Отрава / яд', style: TextStyle(fontSize: 11)),
                    selected: _selectedDangerType == 'poison',
                    onSelected: (val) {
                      if (val) setState(() => _selectedDangerType = 'poison');
                    },
                    selectedColor: const Color(0xFFF59E0B),
                    backgroundColor: AppColors.obsidianGlassSurface,
                    showCheckmark: false,
                  ),
                  ChoiceChip(
                    label: const Text('🐕‍🦺 Стая собак', style: TextStyle(fontSize: 11)),
                    selected: _selectedDangerType == 'aggressive_pack',
                    onSelected: (val) {
                      if (val) setState(() => _selectedDangerType = 'aggressive_pack');
                    },
                    selectedColor: const Color(0xFFF59E0B),
                    backgroundColor: AppColors.obsidianGlassSurface,
                    showCheckmark: false,
                  ),
                  ChoiceChip(
                    label: const Text('⚠️ Битое стекло', style: TextStyle(fontSize: 11)),
                    selected: _selectedDangerType == 'broken_glass',
                    onSelected: (val) {
                      if (val) setState(() => _selectedDangerType = 'broken_glass');
                    },
                    selectedColor: const Color(0xFFF59E0B),
                    backgroundColor: AppColors.obsidianGlassSurface,
                    showCheckmark: false,
                  ),
                  ChoiceChip(
                    label: const Text('❓ Другое', style: TextStyle(fontSize: 11)),
                    selected: _selectedDangerType == 'other',
                    onSelected: (val) {
                      if (val) setState(() => _selectedDangerType = 'other');
                    },
                    selectedColor: const Color(0xFFF59E0B),
                    backgroundColor: AppColors.obsidianGlassSurface,
                    showCheckmark: false,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Title Field
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: _selectedType == 'danger'
                    ? 'Что произошло? (например, Рассыпан яд на газоне)'
                    : 'Название (например, Пропал хаски Арчи)',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accentGreen),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Breed Field (only for lost pet or companion)
            if (_selectedType != 'danger') ...[
              TextField(
                controller: _breedController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Порода (необязательно)',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
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
            ],

            // Description Field
            TextField(
              controller: _descController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Подробное описание и ориентиры...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
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

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == 'danger' ? const Color(0xFFF59E0B) : AppColors.accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _selectedType == 'danger' ? 'Опубликовать предупреждение' : 'Опубликовать метку',
                  style: const TextStyle(
                    color: Colors.black,
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

class _TypeChip extends StatelessWidget {
  final String label;
  final String type;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.type,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : AppColors.obsidianGlassSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
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
