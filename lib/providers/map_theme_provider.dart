import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapThemePreset {
  final String key;
  final String title;
  final String description;
  final bool isLightMode;
  final double greenBoost;
  final double contrast;
  final double brightness;
  final double saturation;
  final double redTint;
  final double blueTint;

  const MapThemePreset({
    required this.key,
    required this.title,
    required this.description,
    required this.isLightMode,
    required this.greenBoost,
    required this.contrast,
    required this.brightness,
    required this.saturation,
    required this.redTint,
    required this.blueTint,
  });
}

class MapThemeState {
  final bool isLightMode;
  final double greenBoost;    // 0.5 .. 2.5
  final double contrast;      // 0.5 .. 2.0
  final double brightness;    // -50 .. +50
  final double saturation;    // 0.0 .. 2.0
  final double redTint;       // 0.5 .. 2.0
  final double blueTint;      // 0.5 .. 2.0
  final String selectedPresetKey;

  const MapThemeState({
    this.isLightMode = false,
    this.greenBoost = 1.35,
    this.contrast = 1.05,
    this.brightness = 0.0,
    this.saturation = 1.0,
    this.redTint = 0.90,
    this.blueTint = 0.95,
    this.selectedPresetKey = 'emerald_dark',
  });

  MapThemeState copyWith({
    bool? isLightMode,
    double? greenBoost,
    double? contrast,
    double? brightness,
    double? saturation,
    double? redTint,
    double? blueTint,
    String? selectedPresetKey,
  }) {
    return MapThemeState(
      isLightMode: isLightMode ?? this.isLightMode,
      greenBoost: greenBoost ?? this.greenBoost,
      contrast: contrast ?? this.contrast,
      brightness: brightness ?? this.brightness,
      saturation: saturation ?? this.saturation,
      redTint: redTint ?? this.redTint,
      blueTint: blueTint ?? this.blueTint,
      selectedPresetKey: selectedPresetKey ?? this.selectedPresetKey,
    );
  }

  /// Вычисляет 20-элементную матрицу 4x5 для ColorFilter.matrix
  List<double> get matrix {
    final c = contrast;
    final b = brightness;
    final r = redTint * c;
    final g = greenBoost * c;
    final bl = blueTint * c;

    if (isLightMode) {
      // Светлая тема: инверсия с сохранением мягких природных тонов
      return <double>[
        -0.85 * r, 0.0,       0.0,       0.0, 245.0 + b,
        0.0,       -0.75 * g, 0.0,       0.0, 248.0 + b + 5.0,
        0.0,       0.0,       -0.85 * bl,0.0, 252.0 + b,
        0.0,       0.0,       0.0,       1.0, 0.0,
      ];
    } else {
      // Темная тема (Obsidian / Emerald / Cyber)
      return <double>[
        r,   0.0, 0.0, 0.0, b,
        0.0, g,   0.0, 0.0, b + (greenBoost > 1.0 ? (greenBoost - 1.0) * 35.0 : 0.0),
        0.0, 0.0, bl,  0.0, b + (blueTint > 1.0 ? (blueTint - 1.0) * 25.0 : 0.0),
        0.0, 0.0, 0.0, 1.0, 0.0,
      ];
    }
  }

  static const List<MapThemePreset> builtInPresets = [
    MapThemePreset(
      key: 'emerald_dark',
      title: 'Obsidian Emerald',
      description: 'Глубокий графит с сочными изумрудными парками',
      isLightMode: false,
      greenBoost: 1.40,
      contrast: 1.10,
      brightness: 0.0,
      saturation: 1.1,
      redTint: 0.88,
      blueTint: 0.92,
    ),
    MapThemePreset(
      key: 'apple_light',
      title: 'Apple Light Clean',
      description: 'Светлая минималистичная тема Apple Maps',
      isLightMode: true,
      greenBoost: 1.25,
      contrast: 1.15,
      brightness: 0.0,
      saturation: 1.0,
      redTint: 1.0,
      blueTint: 1.05,
    ),
    MapThemePreset(
      key: 'deep_forest',
      title: 'Deep Pine Forest',
      description: 'Усиленная хвойная зелень и темные дороги',
      isLightMode: false,
      greenBoost: 1.75,
      contrast: 1.25,
      brightness: -10.0,
      saturation: 1.3,
      redTint: 0.75,
      blueTint: 0.85,
    ),
    MapThemePreset(
      key: 'cyber_mint',
      title: 'Cyberpunk Mint',
      description: 'Неоновый мятный акцент и футуристичный контраст',
      isLightMode: false,
      greenBoost: 1.65,
      contrast: 1.35,
      brightness: 5.0,
      saturation: 1.4,
      redTint: 0.80,
      blueTint: 1.55,
    ),
    MapThemePreset(
      key: 'oled_black',
      title: 'OLED Pure Black',
      description: '100% черный фон под Super Retina дисплеи',
      isLightMode: false,
      greenBoost: 1.20,
      contrast: 1.45,
      brightness: -25.0,
      saturation: 0.9,
      redTint: 0.70,
      blueTint: 0.75,
    ),
  ];
}

class MapThemeNotifier extends StateNotifier<MapThemeState> {
  MapThemeNotifier() : super(const MapThemeState());

  void setGreenBoost(double val) {
    state = state.copyWith(greenBoost: val, selectedPresetKey: 'custom');
  }

  void setContrast(double val) {
    state = state.copyWith(contrast: val, selectedPresetKey: 'custom');
  }

  void setBrightness(double val) {
    state = state.copyWith(brightness: val, selectedPresetKey: 'custom');
  }

  void setSaturation(double val) {
    state = state.copyWith(saturation: val, selectedPresetKey: 'custom');
  }

  void setRedTint(double val) {
    state = state.copyWith(redTint: val, selectedPresetKey: 'custom');
  }

  void setBlueTint(double val) {
    state = state.copyWith(blueTint: val, selectedPresetKey: 'custom');
  }

  void toggleLightMode(bool isLight) {
    state = state.copyWith(
      isLightMode: isLight,
      selectedPresetKey: isLight ? 'apple_light' : 'emerald_dark',
    );
  }

  void applyPreset(String presetKey) {
    final preset = MapThemeState.builtInPresets.firstWhere(
      (p) => p.key == presetKey,
      orElse: () => MapThemeState.builtInPresets.first,
    );

    state = MapThemeState(
      isLightMode: preset.isLightMode,
      greenBoost: preset.greenBoost,
      contrast: preset.contrast,
      brightness: preset.brightness,
      saturation: preset.saturation,
      redTint: preset.redTint,
      blueTint: preset.blueTint,
      selectedPresetKey: preset.key,
    );
  }

  void reset() {
    applyPreset('emerald_dark');
  }
}

final mapThemeNotifierProvider =
    StateNotifierProvider<MapThemeNotifier, MapThemeState>((ref) {
  return MapThemeNotifier();
});
