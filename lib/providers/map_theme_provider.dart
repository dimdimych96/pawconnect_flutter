import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

class LayerColorPreset {
  final String key;
  final String title;
  final String description;
  final bool isLightMode;
  final Color parkColor;
  final Color waterColor;
  final Color roadColor;
  final Color buildingColor;
  final Color backgroundColor;

  const LayerColorPreset({
    required this.key,
    required this.title,
    required this.description,
    required this.isLightMode,
    required this.parkColor,
    required this.waterColor,
    required this.roadColor,
    required this.buildingColor,
    required this.backgroundColor,
  });
}

class MapThemeState {
  final bool isLightMode;
  final Color parkColor;
  final Color waterColor;
  final Color roadColor;
  final Color buildingColor;
  final Color backgroundColor;
  final String selectedPresetKey;

  const MapThemeState({
    this.isLightMode = false,
    this.parkColor = const Color(0xFF1E432E),
    this.waterColor = const Color(0xFF0C1622),
    this.roadColor = const Color(0xFF2C2C32),
    this.buildingColor = const Color(0xFF141418),
    this.backgroundColor = const Color(0xFF0A0A0C),
    this.selectedPresetKey = 'emerald_dark',
  });

  String get themeSignature =>
      '${isLightMode ? "L" : "D"}_'
      '${parkColor.toARGB32().toRadixString(16)}_'
      '${waterColor.toARGB32().toRadixString(16)}_'
      '${roadColor.toARGB32().toRadixString(16)}_'
      '${buildingColor.toARGB32().toRadixString(16)}_'
      '${backgroundColor.toARGB32().toRadixString(16)}';

  MapThemeState copyWith({
    bool? isLightMode,
    Color? parkColor,
    Color? waterColor,
    Color? roadColor,
    Color? buildingColor,
    Color? backgroundColor,
    String? selectedPresetKey,
  }) {
    return MapThemeState(
      isLightMode: isLightMode ?? this.isLightMode,
      parkColor: parkColor ?? this.parkColor,
      waterColor: waterColor ?? this.waterColor,
      roadColor: roadColor ?? this.roadColor,
      buildingColor: buildingColor ?? this.buildingColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedPresetKey: selectedPresetKey ?? this.selectedPresetKey,
    );
  }

  static String _colorToHex(Color c) {
    return '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Builds a dynamic Vector Mapbox-compatible Theme object for VectorTileLayer
  vtr.Theme buildVectorTheme() {
    final styleMap = {
      'version': 8,
      'name': 'PawConnect Dynamic Vector Theme',
      'sources': {
        'openmaptiles': {
          'type': 'vector',
          'url': 'https://tiles.basemaps.cartocdn.com/vectortiles/carto.streets/v1/{z}/{x}/{y}.mvt'
        }
      },
      'layers': [
        // 1. Background layer
        {
          'id': 'background',
          'type': 'background',
          'paint': {
            'background-color': _colorToHex(backgroundColor),
          }
        },
        // 2. Water layers (Ocean, rivers, lakes, canals)
        {
          'id': 'water',
          'type': 'fill',
          'source': 'openmaptiles',
          'source-layer': 'water',
          'paint': {
            'fill-color': _colorToHex(waterColor),
            'fill-opacity': isLightMode ? 0.85 : 0.95,
          }
        },
        {
          'id': 'waterway',
          'type': 'line',
          'source': 'openmaptiles',
          'source-layer': 'waterway',
          'paint': {
            'line-color': _colorToHex(waterColor),
            'line-width': 1.5,
          }
        },
        // 3. Parks, Forestry, Leisure, Grass
        {
          'id': 'landuse_park',
          'type': 'fill',
          'source': 'openmaptiles',
          'source-layer': 'park',
          'paint': {
            'fill-color': _colorToHex(parkColor),
            'fill-opacity': isLightMode ? 0.85 : 0.92,
          }
        },
        {
          'id': 'landuse_overlay',
          'type': 'fill',
          'source': 'openmaptiles',
          'source-layer': 'landuse',
          'paint': {
            'fill-color': _colorToHex(parkColor),
            'fill-opacity': 0.70,
          }
        },
        {
          'id': 'landcover_grass',
          'type': 'fill',
          'source': 'openmaptiles',
          'source-layer': 'landcover',
          'paint': {
            'fill-color': _colorToHex(parkColor),
            'fill-opacity': 0.75,
          }
        },
        // 4. Buildings
        {
          'id': 'building',
          'type': 'fill',
          'source': 'openmaptiles',
          'source-layer': 'building',
          'paint': {
            'fill-color': _colorToHex(buildingColor),
            'fill-outline-color': _colorToHex(buildingColor.withValues(alpha: 0.5)),
          }
        },
        // 5. Transportation / Roads (Minor streets, footpaths)
        {
          'id': 'road_minor',
          'type': 'line',
          'source': 'openmaptiles',
          'source-layer': 'transportation',
          'paint': {
            'line-color': _colorToHex(roadColor),
            'line-width': 1.2,
          }
        },
        // 6. Major Roads / Highways
        {
          'id': 'road_primary',
          'type': 'line',
          'source': 'openmaptiles',
          'source-layer': 'transportation',
          'filter': ['in', 'class', 'primary', 'secondary', 'tertiary', 'trunk', 'motorway'],
          'paint': {
            'line-color': _colorToHex(isLightMode ? Colors.white : roadColor),
            'line-width': 2.4,
          }
        },
      ]
    };

    return vtr.ThemeReader().read(styleMap);
  }

  /// 4x5 ColorFilter.matrix calculated from current per-layer balance
  List<double> get matrix {
    final parkG = parkColor.g / 255.0;
    final waterB = waterColor.b / 255.0;
    final roadC = roadColor.r / 255.0;
    final bgR = backgroundColor.r / 255.0;
    final bgG = backgroundColor.g / 255.0;
    final bgB = backgroundColor.b / 255.0;

    if (isLightMode) {
      final invertMult = -0.85;
      return <double>[
        invertMult * (roadC * 2.0).clamp(0.6, 1.4), 0.0, 0.0, 0.0, 240.0 + (bgR * 20),
        0.0, invertMult * (parkG * 2.0).clamp(0.6, 1.5), 0.0, 0.0, 246.0 + (bgG * 20),
        0.0, 0.0, invertMult * (waterB * 2.0).clamp(0.6, 1.4), 0.0, 252.0 + (bgB * 20),
        0.0, 0.0, 0.0, 1.0, 0.0,
      ];
    } else {
      final gBoost = (parkG * 4.5).clamp(0.8, 2.5);
      final bBoost = (waterB * 4.0).clamp(0.7, 2.0);
      final rBoost = (roadC * 3.5).clamp(0.6, 1.8);

      return <double>[
        rBoost, 0.0,    0.0,    0.0, bgR * 10,
        0.0,    gBoost, 0.0,    0.0, (parkG > 0.2 ? (parkG - 0.2) * 50.0 : 0.0) + (bgG * 10),
        0.0,    0.0,    bBoost, 0.0, (waterB > 0.15 ? (waterB - 0.15) * 40.0 : 0.0) + (bgB * 10),
        0.0,    0.0,    0.0,    1.0, 0.0,
      ];
    }
  }

  static const List<LayerColorPreset> builtInPresets = [
    LayerColorPreset(
      key: 'emerald_dark',
      title: 'Obsidian Emerald',
      description: 'Изумрудные парки, глубокая синяя Обь, темный графит',
      isLightMode: false,
      parkColor: Color(0xFF1E432E),
      waterColor: Color(0xFF0C1622),
      roadColor: Color(0xFF2C2C32),
      buildingColor: Color(0xFF141418),
      backgroundColor: Color(0xFF0A0A0C),
    ),
    LayerColorPreset(
      key: 'apple_light',
      title: 'Apple Light Clean',
      description: 'Нежно-зеленые парки, голубая река, белые дороги',
      isLightMode: true,
      parkColor: Color(0xFFC8E6C9),
      waterColor: Color(0xFFB3E5FC),
      roadColor: Color(0xFFFFFFFF),
      buildingColor: Color(0xFFE2E8F0),
      backgroundColor: Color(0xFFF8FAFC),
    ),
    LayerColorPreset(
      key: 'deep_forest',
      title: 'Deep Pine Forest',
      description: 'Хвойный темно-зеленый массив и матовый асфальт',
      isLightMode: false,
      parkColor: Color(0xFF133821),
      waterColor: Color(0xFF09121D),
      roadColor: Color(0xFF242428),
      buildingColor: Color(0xFF121214),
      backgroundColor: Color(0xFF080A08),
    ),
    LayerColorPreset(
      key: 'cyber_mint',
      title: 'Cyberpunk Mint',
      description: 'Неоновый мятный акцент, индиго вода, фиолетовые полутона',
      isLightMode: false,
      parkColor: Color(0xFF00F5D4),
      waterColor: Color(0xFF1A1230),
      roadColor: Color(0xFF424769),
      buildingColor: Color(0xFF22223B),
      backgroundColor: Color(0xFF0F0E17),
    ),
    LayerColorPreset(
      key: 'oled_black',
      title: 'OLED Pure Black',
      description: '100% черный фон, контрастные парки для Super Retina',
      isLightMode: false,
      parkColor: Color(0xFF1B402B),
      waterColor: Color(0xFF081018),
      roadColor: Color(0xFF26262B),
      buildingColor: Color(0xFF111114),
      backgroundColor: Color(0xFF000000),
    ),
  ];
}

class MapThemeNotifier extends StateNotifier<MapThemeState> {
  MapThemeNotifier() : super(const MapThemeState());

  void setParkColor(Color color) {
    state = state.copyWith(parkColor: color, selectedPresetKey: 'custom');
  }

  void setWaterColor(Color color) {
    state = state.copyWith(waterColor: color, selectedPresetKey: 'custom');
  }

  void setRoadColor(Color color) {
    state = state.copyWith(roadColor: color, selectedPresetKey: 'custom');
  }

  void setBuildingColor(Color color) {
    state = state.copyWith(buildingColor: color, selectedPresetKey: 'custom');
  }

  void setBackgroundColor(Color color) {
    state = state.copyWith(backgroundColor: color, selectedPresetKey: 'custom');
  }

  void toggleLightMode(bool isLight) {
    if (isLight) {
      applyPreset('apple_light');
    } else {
      applyPreset('emerald_dark');
    }
  }

  void applyPreset(String presetKey) {
    final preset = MapThemeState.builtInPresets.firstWhere(
      (p) => p.key == presetKey,
      orElse: () => MapThemeState.builtInPresets.first,
    );

    state = MapThemeState(
      isLightMode: preset.isLightMode,
      parkColor: preset.parkColor,
      waterColor: preset.waterColor,
      roadColor: preset.roadColor,
      buildingColor: preset.buildingColor,
      backgroundColor: preset.backgroundColor,
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
