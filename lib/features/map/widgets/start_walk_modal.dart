import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../models/walk_session_model.dart';

class StartWalkModal extends StatefulWidget {
  final double currentLat;
  final double currentLng;
  final String petName;
  final String petBreed;
  final DogTemperament defaultTemperament;
  final Future<bool> Function({
    required String petId,
    required String petName,
    required String walkMode,
    required double latitude,
    required double longitude,
    required DogTemperament temperament,
    String? note,
  }) onStart;

  const StartWalkModal({
    super.key,
    required this.currentLat,
    required this.currentLng,
    this.petName = 'Макс',
    this.petBreed = 'Золотистый ретривер',
    this.defaultTemperament = DogTemperament.playful,
    required this.onStart,
  });

  @override
  State<StartWalkModal> createState() => _StartWalkModalState();
}

class _StartWalkModalState extends State<StartWalkModal> {
  String _selectedMode = 'open'; // 'open', 'private', 'training'
  late DogTemperament _selectedTemperament;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedTemperament = widget.defaultTemperament;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    setState(() => _isSubmitting = true);
    final note = _noteController.text.trim();
    final success = await widget.onStart(
      petId: 'pet-archi-1',
      petName: widget.petName,
      walkMode: _selectedMode,
      latitude: widget.currentLat,
      longitude: widget.currentLng,
      temperament: _selectedTemperament,
      note: note.isNotEmpty ? note : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Радар прогулок',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.petName} • ${widget.petBreed}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.obsidianRaised,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Walk Mode Cards
              const Text(
                'Режим прогулки',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildModeCard(
                mode: 'open',
                icon: Icons.public_rounded,
                title: 'Открытый выгул',
                subtitle: 'Точные координаты на радаре, видно соседям для совместных игр',
                color: AppColors.accentGreen,
              ),
              const SizedBox(height: 8),
              _buildModeCard(
                mode: 'private',
                icon: Icons.shield_outlined,
                title: 'Приватный выгул',
                subtitle: 'Размытие координат (~120м). Никто не видит точную точку выгула',
                color: const Color(0xFFA78BFA),
              ),
              const SizedBox(height: 8),
              _buildModeCard(
                mode: 'training',
                icon: Icons.explore_rounded,
                title: 'Тренировка',
                subtitle: 'Отработка команд. Значок просит держать дистанцию и не отвлекать',
                color: const Color(0xFFFBBF24),
              ),
              const SizedBox(height: 16),

              // Temperament Selector
              const Text(
                'Темперамент на прогулке',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DogTemperament.values.map((temp) {
                  final isSelected = _selectedTemperament == temp;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTemperament = temp),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? temp.color.withValues(alpha: 0.16)
                            : AppColors.obsidianRaised,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? temp.color : AppColors.glassBorder,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: temp.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            temp.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? temp.color : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Note text field
              TextField(
                controller: _noteController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Заметка (напр., гуляем с мячом у фонтана)',
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: AppColors.obsidianRaised,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.accentGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Start Walk Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleStart,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.black),
                  label: Text(
                    _isSubmitting ? 'Активация' : 'Выйти на прогулку',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String mode,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.10) : AppColors.obsidianRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : AppColors.glassBorder,
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 18, color: color)
            else
              const Icon(Icons.circle_outlined, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
