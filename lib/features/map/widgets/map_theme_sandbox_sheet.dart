import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/pill_toast.dart';
import '../../../providers/map_theme_provider.dart';

/// Интерактивная Liquid Glass шторка для тестирования и настройки цветов карты
class MapThemeSandboxSheet extends ConsumerWidget {
  final VoidCallback onClose;

  const MapThemeSandboxSheet({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(mapThemeNotifierProvider);
    final themeNotifier = ref.read(mapThemeNotifierProvider.notifier);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: BoxDecoration(
            color: const Color(0xE614181D),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 36,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.palette_rounded,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Песочница темы карты',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Live GPU тюнинг цветов и пресетов',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // Scrollable Sliders & Presets Content
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                  children: [
                    // 1. Dark vs Light Mode Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ThemeTabButton(
                              icon: Icons.nightlight_round,
                              label: 'Тёмная (Dark)',
                              isSelected: !themeState.isLightMode,
                              onTap: () => themeNotifier.toggleLightMode(false),
                            ),
                          ),
                          Expanded(
                            child: _ThemeTabButton(
                              icon: Icons.wb_sunny_rounded,
                              label: 'Светлая (Light)',
                              isSelected: themeState.isLightMode,
                              onTap: () => themeNotifier.toggleLightMode(true),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Presets Quick Carousel
                    const Text(
                      'ГОТОВЫЕ ПРЕСЕТЫ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: MapThemeState.builtInPresets.map((preset) {
                          final isSelected = themeState.selectedPresetKey == preset.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => themeNotifier.applyPreset(preset.key),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accentGreen.withValues(alpha: 0.22)
                                      : Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accentGreen
                                        : Colors.white.withValues(alpha: 0.1),
                                    width: isSelected ? 1.4 : 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    preset.title,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.accentGreen
                                          : AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 3. Live Sliders
                    const Text(
                      'НАСТРОЙКА СПЕКТРА И ЯРКОСТИ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Slider: Green Boost (Парки)
                    _ColorSlider(
                      label: '🌿 Зелень парков (Green Boost)',
                      valueText: '${((themeState.greenBoost - 1.0) * 100).toStringAsFixed(0)}%',
                      value: themeState.greenBoost,
                      min: 0.5,
                      max: 2.5,
                      accentColor: AppColors.accentGreen,
                      onChanged: themeNotifier.setGreenBoost,
                    ),

                    // Slider: Contrast
                    _ColorSlider(
                      label: '🎚 Контрастность (Contrast)',
                      valueText: '${(themeState.contrast * 100).toStringAsFixed(0)}%',
                      value: themeState.contrast,
                      min: 0.5,
                      max: 2.0,
                      accentColor: Colors.white70,
                      onChanged: themeNotifier.setContrast,
                    ),

                    // Slider: Brightness
                    _ColorSlider(
                      label: '☀️ Яркость (Brightness)',
                      valueText: themeState.brightness.toStringAsFixed(0),
                      value: themeState.brightness,
                      min: -40.0,
                      max: 40.0,
                      accentColor: Colors.amberAccent,
                      onChanged: themeNotifier.setBrightness,
                    ),

                    // Slider: Blue Tint (Вода)
                    _ColorSlider(
                      label: '🌊 Синий / Река Обь (Blue Tint)',
                      valueText: '${((themeState.blueTint - 1.0) * 100).toStringAsFixed(0)}%',
                      value: themeState.blueTint,
                      min: 0.5,
                      max: 2.0,
                      accentColor: AppColors.accentBlue,
                      onChanged: themeNotifier.setBlueTint,
                    ),

                    // Slider: Red Tint
                    _ColorSlider(
                      label: '🔴 Красный спектр / Теплота (Red Tint)',
                      valueText: '${((themeState.redTint - 1.0) * 100).toStringAsFixed(0)}%',
                      value: themeState.redTint,
                      min: 0.5,
                      max: 2.0,
                      accentColor: Colors.redAccent,
                      onChanged: themeNotifier.setRedTint,
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons: Reset & Copy Matrix Values
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              themeNotifier.reset();
                              PawToast.show(
                                context,
                                title: 'Настройки сброшены',
                                subtitle: 'Тема возвращена к Obsidian Emerald',
                                type: ToastType.info,
                              );
                            },
                            icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.textSecondary),
                            label: const Text(
                              'Сбросить',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              PawToast.show(
                                context,
                                title: 'Пресет зафиксирован',
                                subtitle: 'Текущие параметры применены к карте',
                                type: ToastType.success,
                              );
                              onClose();
                            },
                            icon: const Icon(Icons.check_rounded, size: 16, color: Colors.black),
                            label: const Text(
                              'Применить',
                              style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.accentGreen : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSlider extends StatelessWidget {
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final Color accentColor;
  final ValueChanged<double> onChanged;

  const _ColorSlider({
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                valueText,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: Colors.white12,
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.2),
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
