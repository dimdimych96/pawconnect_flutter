import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/auth_prompt_modal.dart';
import '../../../core/widgets/pill_toast.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/community_provider.dart';

/// Liquid Glass modal sheet for reporting a pet sighting («Замечен здесь»).
/// Allows volunteers and neighbors to drop a timestamped clue on the map
/// to narrow down the search area.
class SosSightingModal extends ConsumerStatefulWidget {
  final String postId;
  final String petName;
  final double defaultLat;
  final double defaultLng;
  final Future<void> Function(double lat, double lng, String note, String timeAgoStr)? onSubmit;

  const SosSightingModal({
    super.key,
    required this.postId,
    required this.petName,
    this.defaultLat = 55.0302,
    this.defaultLng = 82.9204,
    this.onSubmit,
  });

  /// Static helper to display the sighting modal with authentication guard.
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String postId,
    required String petName,
    double? defaultLat,
    double? defaultLng,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (!authState.isAuthenticated) {
      AuthPromptModal.show(context, action: 'отправить отметку следа');
      return;
    }

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SosSightingModal(
        postId: postId,
        petName: petName,
        defaultLat: defaultLat ?? 55.0302,
        defaultLng: defaultLng ?? 82.9204,
      ),
    );
  }

  @override
  ConsumerState<SosSightingModal> createState() => _SosSightingModalState();
}

class _SosSightingModalState extends ConsumerState<SosSightingModal> {
  final _noteController = TextEditingController();
  late double _latitude;
  late double _longitude;
  String _selectedTimeAgo = 'Только что';
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _timeOptions = [
    'Только что',
    '15–30 мин назад',
    '1–2 часа назад',
    'Более 3 часов назад',
  ];

  @override
  void initState() {
    super.initState();
    _latitude = widget.defaultLat;
    _longitude = widget.defaultLng;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final note = _noteController.text.trim();
    if (note.isEmpty) {
      setState(() => _errorMessage = 'Пожалуйста, опишите детали (направление, состояние)');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(_latitude, _longitude, note, _selectedTimeAgo);
      } else {
        await ref.read(communityNotifierProvider.notifier).reportSighting(
          postId: widget.postId,
          latitude: _latitude,
          longitude: _longitude,
          note: note,
          timeAgoStr: _selectedTimeAgo,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
        PawToast.show(
          context,
          title: 'Отметка следа сохранена! Отряд оповещён',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Не удалось отправить отметку. Попробуйте позже.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.obsidianBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pin_drop_rounded,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Зафиксировать след',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Поиск: ${widget.petName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Помогите отряду сузить зону поиска. Каждая отметка следа критически важна для спасения!',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Time selector
            const Text(
              'Когда вы видели питомца?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeOptions.map((option) {
                final isSelected = _selectedTimeAgo == option;
                return ChoiceChip(
                  label: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedTimeAgo = option);
                  },
                  selectedColor: const Color(0xFFF59E0B),
                  backgroundColor: AppColors.obsidianGlassSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFF59E0B) : AppColors.glassBorder,
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 2. Location readout / confirmation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, size: 16, color: AppColors.accentBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Координаты: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)} (Район поиска)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Notes TextField
            const Text(
              'Описание следа и приметы',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Опишите направление движения, поведение, есть ли ошейник или травмы...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.obsidianGlassSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Error Message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // 4. Submit Button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleSubmit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.pin_drop_rounded, size: 18, color: Colors.white),
              label: Text(
                _isSubmitting ? 'Отправка...' : 'Отправить сигнал следа',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Отмена',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
