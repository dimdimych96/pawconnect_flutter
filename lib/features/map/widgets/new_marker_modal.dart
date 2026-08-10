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
      breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
      age: 'Не указан',
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
            Row(
              children: [
                _TypeChip(
                  label: '🚨 Потеряшка',
                  type: 'lost_pet',
                  color: AppColors.accentRed,
                  isSelected: _selectedType == 'lost_pet',
                  onTap: () => setState(() => _selectedType = 'lost_pet'),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: '🦮 Площадка',
                  type: 'playground',
                  color: AppColors.accentGreen,
                  isSelected: _selectedType == 'playground',
                  onTap: () => setState(() => _selectedType = 'playground'),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: '🐾 Прогулка',
                  type: 'companion',
                  color: AppColors.accentBlue,
                  isSelected: _selectedType == 'companion',
                  onTap: () => setState(() => _selectedType = 'companion'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Название (например, Пропал хаски Арчи)',
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

            // Breed Field
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
                  backgroundColor: AppColors.accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Опубликовать метку',
                  style: TextStyle(
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
