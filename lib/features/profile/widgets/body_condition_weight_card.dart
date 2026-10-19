import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../../core/widgets/pill_toast.dart';
import '../../../models/breed_model.dart';
import '../../../models/pet_health_profile_model.dart';
import '../../../providers/health_provider.dart';

class BodyConditionWeightCard extends ConsumerWidget {
  final PetHealthProfileModel profile;

  const BodyConditionWeightCard({
    super.key,
    required this.profile,
  });

  void _openWeightLogger(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _WeightLoggerModal(
        profile: profile,
        onSave: (newWeight, newBcs) async {
          final success = await ref.read(healthNotifierProvider.notifier).updateCondition(
                petId: profile.petId,
                weightKg: newWeight,
                bcsScore: newBcs,
              );
          if (sheetContext.mounted && context.mounted) {
            if (success) {
              PawToast.show(
                context,
                title: 'Вес и шкала кондиции обновлены: ${newWeight.toStringAsFixed(1)} кг (BCS $newBcs)',
                type: ToastType.success,
              );
            } else {
              PawToast.show(
                context,
                title: 'Не удалось сохранить вес',
                type: ToastType.alert,
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bcs = profile.bcsScore;
    final bcsColor = BodyConditionHelper.getColor(bcs);
    final bcsLabel = profile.conditionLabel.isNotEmpty
        ? profile.conditionLabel
        : BodyConditionHelper.getLabel(bcs);
    final bcsAdvice = BodyConditionHelper.getAdvice(bcs);
    final currentWeight = profile.weightKg ?? 10.0;
    final targetWeight = profile.targetWeightKg;

    String? diffText;
    Color diffColor = AppColors.textSecondary;
    if (targetWeight != null) {
      final diff = currentWeight - targetWeight;
      if (diff.abs() < 0.1) {
        diffText = '🎯 Точно в цели';
        diffColor = AppColors.accentGreen;
      } else if (diff > 0) {
        diffText = '+${diff.toStringAsFixed(1)} кг к цели';
        diffColor = AppColors.accentYellow;
      } else {
        diffText = '${diff.toStringAsFixed(1)} кг к цели';
        diffColor = AppColors.accentBlue;
      }
    }

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      accentColor: bcsColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.monitor_weight_outlined, color: AppColors.accentGreen, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Шкала кондиции & Вес',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _openWeightLogger(context, ref),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 13, color: AppColors.accentGreen),
                      SizedBox(width: 4),
                      Text(
                        'Записать',
                        style: TextStyle(
                          color: AppColors.accentGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Weight Metrics Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.obsidianGlassSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Текущий вес',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currentWeight.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'кг',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (diffText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          diffText,
                          style: TextStyle(
                            fontSize: 11,
                            color: diffColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: AppColors.glassBorder,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Норма породы (WSAVA)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.idealWeightRange ?? '10.0 – 14.0 кг',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (targetWeight != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Цель: ${targetWeight.toStringAsFixed(1)} кг',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // BCS Visual Gauge Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Индекс BCS (1–9 баллов)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bcsColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: bcsColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '$bcs/9 • $bcsLabel',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: bcsColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 9-step Visual Gauge
          Row(
            children: List.generate(9, (index) {
              final step = index + 1;
              final isSelected = step == bcs;
              final stepColor = BodyConditionHelper.getColor(step);
              final isIdealRange = step == 4 || step == 5;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 8 ? 4.0 : 0.0),
                  child: Column(
                    children: [
                      Container(
                        height: isSelected ? 24 : 14,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? stepColor
                              : (isIdealRange
                                  ? stepColor.withValues(alpha: 0.35)
                                  : AppColors.obsidianGlassSurface),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : (isIdealRange
                                    ? stepColor.withValues(alpha: 0.5)
                                    : AppColors.glassBorderSubtle),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: stepColor.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$step',
                            style: TextStyle(
                              fontSize: isSelected ? 11 : 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.black
                                  : (isIdealRange ? stepColor : AppColors.textTertiary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (step == 5)
                        const Text(
                          'Идеал',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGreen,
                          ),
                        )
                      else
                        const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // BCS Veterinary Advice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bcsColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bcsColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: bcsColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bcsAdvice,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightLoggerModal extends StatefulWidget {
  final PetHealthProfileModel profile;
  final Future<void> Function(double newWeight, int newBcs) onSave;

  const _WeightLoggerModal({
    required this.profile,
    required this.onSave,
  });

  @override
  State<_WeightLoggerModal> createState() => _WeightLoggerModalState();
}

class _WeightLoggerModalState extends State<_WeightLoggerModal> {
  late double _weight;
  late int _bcs;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _weight = widget.profile.weightKg ?? 10.0;
    _bcs = widget.profile.bcsScore;
  }

  void _adjustWeight(double delta) {
    setState(() {
      _weight = (_weight + delta).clamp(1.0, 99.0);
      _weight = double.parse(_weight.toStringAsFixed(1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final bcsColor = BodyConditionHelper.getColor(_bcs);
    final bcsLabel = BodyConditionHelper.getLabel(_bcs);

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
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.monitor_weight_rounded, color: AppColors.accentGreen, size: 22),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Запись веса и кондиции',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Stepper for Weight
              const Text(
                'Вес питомца (кг)',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _StepButton(
                          icon: Icons.remove,
                          onTap: () => _adjustWeight(-0.5),
                          label: '-0.5',
                        ),
                        const SizedBox(width: 6),
                        _StepButton(
                          icon: Icons.remove,
                          onTap: () => _adjustWeight(-0.1),
                          label: '-0.1',
                        ),
                      ],
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${_weight.toStringAsFixed(1)} кг',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _StepButton(
                          icon: Icons.add,
                          onTap: () => _adjustWeight(0.1),
                          label: '+0.1',
                        ),
                        const SizedBox(width: 6),
                        _StepButton(
                          icon: Icons.add,
                          onTap: () => _adjustWeight(0.5),
                          label: '+0.5',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Stepper / Selector for BCS (1-9)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Оценка кондиции (BCS)',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_bcs/9 • $bcsLabel',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: bcsColor),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: bcsColor,
                inactiveTrackColor: AppColors.obsidianGlassSurface,
                thumbColor: bcsColor,
                overlayColor: bcsColor.withValues(alpha: 0.2),
                trackHeight: 6,
                tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
                activeTickMarkColor: Colors.white,
                inactiveTickMarkColor: AppColors.glassBorder,
              ),
              child: Slider(
                value: _bcs.toDouble(),
                min: 1,
                max: 9,
                divisions: 8,
                onChanged: (val) {
                  setState(() {
                    _bcs = val.round();
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        await widget.onSave(_weight, _bcs);
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text(
                        'Сохранить изменения',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String label;

  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.obsidianCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
