import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../core/widgets/pill_toast.dart';
import '../../../models/specialist_model.dart';

class SpecialistInquiryModal extends StatefulWidget {
  final SpecialistModel specialist;
  final Future<bool> Function(String message) onSubmit;

  const SpecialistInquiryModal({
    super.key,
    required this.specialist,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required SpecialistModel specialist,
    required Future<bool> Function(String message) onSubmit,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => SpecialistInquiryModal(
        specialist: specialist,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<SpecialistInquiryModal> createState() => _SpecialistInquiryModalState();
}

class _SpecialistInquiryModalState extends State<SpecialistInquiryModal> {
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _quickTopics = [
    'Консультация',
    'Первое знакомство',
    'Занятие с выездом',
    'Передержка',
    'Гигиенический уход',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _applyQuickTopic(String topic) {
    setState(() {
      if (_messageController.text.isEmpty) {
        _messageController.text = 'Здравствуйте! Интересует $topic для нашего питомца.';
      } else {
        _messageController.text += ' ($topic)';
      }
    });
  }

  Future<void> _submit() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    final success = await widget.onSubmit(text);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      PawToast.show(
        context,
        title: 'Заявка успешно отправлена специалисту!',
        type: ToastType.success,
      );
    } else {
      setState(() => _isSubmitting = false);
      PawToast.show(
        context,
        title: 'Не удалось отправить заявку',
        type: ToastType.alert,
      );
    }
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
      child: SingleChildScrollView(
        child: GlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(22),
          accentColor: AppColors.accentGreen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      PawAvatar(
                        url: widget.specialist.avatarUrl,
                        radius: 20,
                        fallbackColor: widget.specialist.professionColor,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.specialist.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            widget.specialist.professionTitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.specialist.professionColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quick Topics Rail
              const Text(
                'Тема обращения',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickTopics.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: InkWell(
                        onTap: () => _applyQuickTopic(topic),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.obsidianGlassSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.glassBorderSubtle),
                          ),
                          child: Text(
                            topic,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Message Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Опишите породу, возраст питомца и удобное время для визита...',
                    hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : const Text(
                          'Отправить заявку',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
