import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawconnect/providers/map_theme_provider.dart';

void main() {
  group('MapThemeProvider Tests', () {
    test('Initial state has default emerald park color', () {
      final container = ProviderContainer();
      final state = container.read(mapThemeNotifierProvider);

      expect(state.isLightMode, isFalse);
      expect(state.parkColor, equals(const Color(0xFF1E432E)));
      expect(state.matrix.length, equals(20));
    });

    test('Setting individual park and water colors updates state independently', () {
      final container = ProviderContainer();
      final notifier = container.read(mapThemeNotifierProvider.notifier);

      notifier.setParkColor(const Color(0xFF00F5D4));
      notifier.setWaterColor(const Color(0xFF1E3A5F));

      final state = container.read(mapThemeNotifierProvider);
      expect(state.parkColor, equals(const Color(0xFF00F5D4)));
      expect(state.waterColor, equals(const Color(0xFF1E3A5F)));
      expect(state.selectedPresetKey, equals('custom'));
    });

    test('Toggling Light Mode switches to light preset colors', () {
      final container = ProviderContainer();
      final notifier = container.read(mapThemeNotifierProvider.notifier);

      notifier.toggleLightMode(true);
      final state = container.read(mapThemeNotifierProvider);

      expect(state.isLightMode, isTrue);
      expect(state.selectedPresetKey, equals('apple_light'));
      expect(state.matrix[0], lessThan(0));
    });

    test('Reset returns to Obsidian Emerald preset', () {
      final container = ProviderContainer();
      final notifier = container.read(mapThemeNotifierProvider.notifier);

      notifier.setParkColor(const Color(0xFFFFFFFF));
      notifier.reset();

      final state = container.read(mapThemeNotifierProvider);
      expect(state.selectedPresetKey, equals('emerald_dark'));
      expect(state.parkColor, equals(const Color(0xFF1E432E)));
    });
  });
}
