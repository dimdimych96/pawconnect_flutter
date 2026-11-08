import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
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
        _messageController.text = 'Здравствуйте, интересует $topic для нашего питомца.';
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
        title: 'Заявка отправлена специалисту',
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.0),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      PawAvatar(
                        url: widget.specialist.avatarUrl,
                        radius: 20,
                        fallbackColor: widget.specialist.professionColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.specialist.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.specialist.professionTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                    padding: EdgeInsets.zero,
                    tooltip: 'Закрыть',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Topics Rail
            const Text(
              'Тема обращения',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickTopics.map((topic) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () => _applyQuickTopic(topic),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.obsidianGlassSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          topic,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Message Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.obsidianGlassSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Опишите породу, возраст питомца и удобное время для визита',
                  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.obsidianBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.obsidianBackground,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Отправить заявку',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
