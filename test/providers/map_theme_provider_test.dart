import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawconnect/providers/map_theme_provider.dart';

void main() {
  group('MapThemeProvider Tests', () {
    test('Initial state is Dark Obsidian with emerald boost', () {
      final container = ProviderContainer();
      final state = container.read(mapThemeNotifierProvider);

      expect(state.isLightMode, isFalse);
      expect(state.greenBoost, greaterThan(1.0));
      expect(state.matrix.length, equals(20));
    });

    test('Toggling Light Mode inverts matrix', () {
      final container = ProviderContainer();
      final notifier = container.read(mapThemeNotifierProvider.notifier);

      notifier.toggleLightMode(true);
      final state = container.read(mapThemeNotifierProvider);

      expect(state.isLightMode, isTrue);
      // Inverted matrix has negative multiplier on diagonal or positive offset
      expect(state.matrix[0], lessThan(0));
    });

    test('Applying Cyber Mint preset updates tints', () {
      final container = ProviderContainer();
      final notifier = container.read(mapThemeNotifierProvider.notifier);

      notifier.applyPreset('cyber_mint');
      final state = container.read(mapThemeNotifierProvider);

      expect(state.selectedPresetKey, equals('cyber_mint'));
      expect(state.blueTint, greaterThan(1.0));
    });

    test('Reset returns to default state', () {
      final container = ProviderContainer();
      final notifier = container.read(mapThemeNotifierProvider.notifier);

      notifier.setGreenBoost(2.0);
      notifier.setBrightness(40);
      notifier.reset();

      final state = container.read(mapThemeNotifierProvider);
      expect(state.selectedPresetKey, equals('emerald_dark'));
      expect(state.brightness, equals(0.0));
    });
  });
}
