import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../models/pet_reminder_model.dart';

class NewReminderModal extends StatefulWidget {
  final Function(PetReminderModel) onAdd;

  const NewReminderModal({
    super.key,
    required this.onAdd,
  });

  @override
  State<NewReminderModal> createState() => _NewReminderModalState();
}

class _NewReminderModalState extends State<NewReminderModal> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'vaccine';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final newReminder = PetReminderModel(
      id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      date: _selectedDate,
      time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      isCompleted: false,
      category: _selectedCategory,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    widget.onAdd(newReminder);
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
                  'Новое напоминание',
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

            // Category Selection
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: '💉 Вакцина',
                    category: 'vaccine',
                    color: AppColors.accentBlue,
                    isSelected: _selectedCategory == 'vaccine',
                    onTap: () => setState(() => _selectedCategory = 'vaccine'),
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: '💊 Таблетки',
                    category: 'pill',
                    color: AppColors.accentGreen,
                    isSelected: _selectedCategory == 'pill',
                    onTap: () => setState(() => _selectedCategory = 'pill'),
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: '🏥 Клиника',
                    category: 'vet',
                    color: AppColors.accentRed,
                    isSelected: _selectedCategory == 'vet',
                    onTap: () => setState(() => _selectedCategory = 'vet'),
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: '✂️ Груминг',
                    category: 'grooming',
                    color: AppColors.accentYellow,
                    isSelected: _selectedCategory == 'grooming',
                    onTap: () => setState(() => _selectedCategory = 'grooming'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title Input
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Продукт / Запись (например, Прививка от бешенства)',
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accentBlue),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Date & Time pickers
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.obsidianGlassSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: AppColors.accentBlue, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.obsidianGlassSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.glassBorderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: AppColors.accentGreen, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notes Input
            TextField(
              controller: _notesController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Заметки или адрес клиники...',
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

            // Submit Button
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
                  'Добавить процедуру',
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final String category;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
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
