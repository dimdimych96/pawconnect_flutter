import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/pill_toast.dart';
import '../../../providers/map_theme_provider.dart';

/// Интерактивная Liquid Glass шторка для раздельного выбора цветов зон (парки, вода, дороги, фон)
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
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: const Color(0xF014181E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.70),
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
                            'Раздельная палитра слоев карты',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Парки, Вода, Дороги, Здания, Подложка',
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

              // Scrollable Layer Color Pickers & Presets
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
                      'ГОТОВЫЕ ПРЕСЕТЫ ВСЕХ СЛОЕВ',
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

                    // 3. Independent Layer Color Tuners
                    // Layer A: Parks & Greenery
                    _LayerColorPickerRow(
                      title: '🌿 Парки и зелёные зоны',
                      currentColor: themeState.parkColor,
                      palette: const [
                        Color(0xFF1E432E), // Изумруд
                        Color(0xFF30D158), // Apple Green
                        Color(0xFF00F5D4), // Неоновый мятный
                        Color(0xFF143621), // Хвойный темный
                        Color(0xFF52796F), // Оливковый шалфей
                        Color(0xFFC8E6C9), // Светло-зеленый (для белой темы)
                      ],
                      onSelectColor: themeNotifier.setParkColor,
                    ),

                    // Layer B: Water & Rivers
                    _LayerColorPickerRow(
                      title: '🌊 Вода (Река Обь, озёра)',
                      currentColor: themeState.waterColor,
                      palette: const [
                        Color(0xFF0C1622), // Deep Navy
                        Color(0xFF1E3A5F), // Атлантический синий
                        Color(0xFF0077B6), // Неоновый синий
                        Color(0xFF1A1230), // Индиго / Фиолетовый
                        Color(0xFF081018), // Угольный темный
                        Color(0xFFB3E5FC), // Светло-голубой (для белой темы)
                      ],
                      onSelectColor: themeNotifier.setWaterColor,
                    ),

                    // Layer C: Roads
                    _LayerColorPickerRow(
                      title: '🛣 Дороги и магистрали',
                      currentColor: themeState.roadColor,
                      palette: const [
                        Color(0xFF2C2C32), // Контрастный графит
                        Color(0xFF1F1F24), // Матовый асфальт
                        Color(0xFF424769), // Сиреневый сланец
                        Color(0xFF26262B), // Темно-серый
                        Color(0xFFFFFFFF), // Белый (для светлой темы)
                        Color(0xFF64748B), // Яркий серый
                      ],
                      onSelectColor: themeNotifier.setRoadColor,
                    ),

                    // Layer D: Buildings
                    _LayerColorPickerRow(
                      title: '🏢 Здания и кварталы',
                      currentColor: themeState.buildingColor,
                      palette: const [
                        Color(0xFF141418), // Тёмный кварц
                        Color(0xFF1C1C22), // Графит
                        Color(0xFF22223B), // Сизый
                        Color(0xFF111114), // Почти черный
                        Color(0xFFE2E8F0), // Светлый (для светлой темы)
                        Color(0xFF2E2E38), // Светлый графит
                      ],
                      onSelectColor: themeNotifier.setBuildingColor,
                    ),

                    // Layer E: Background / Land
                    _LayerColorPickerRow(
                      title: '🌑 Фоновая подложка (Земля)',
                      currentColor: themeState.backgroundColor,
                      palette: const [
                        Color(0xFF0A0A0C), // Obsidian Black
                        Color(0xFF000000), // OLED Pure Black
                        Color(0xFF080A08), // Хвойный темный фон
                        Color(0xFF0F0E17), // Фиолетовый Cyber фон
                        Color(0xFFF8FAFC), // Apple Light белый фон
                        Color(0xFF18181B), // Серый цинк
                      ],
                      onSelectColor: themeNotifier.setBackgroundColor,
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons: Reset & Apply
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              themeNotifier.reset();
                              PawToast.show(
                                context,
                                title: 'Сброшено к Obsidian Emerald',
                                subtitle: 'Базовая палитра восстановлена',
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
                                title: 'Палитра зафиксирована',
                                subtitle: 'Выбранные цвета применены к слоям карты',
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

class _LayerColorPickerRow extends StatelessWidget {
  final String title;
  final Color currentColor;
  final List<Color> palette;
  final ValueChanged<Color> onSelectColor;

  const _LayerColorPickerRow({
    required this.title,
    required this.currentColor,
    required this.palette,
    required this.onSelectColor,
  });

  String _toHex(Color c) {
    return '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Text(
                  _toHex(currentColor),
                  style: TextStyle(
                    color: currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: palette.map((color) {
              final isSelected = currentColor.toARGB32() == color.toARGB32();
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelectColor(color),
                  child: Container(
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
