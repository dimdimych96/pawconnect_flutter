import 'package:vector_map_tiles/vector_map_tiles.dart';

/// Helper for reading custom vector themes
class CustomVectorMapTheme {
  static Future<Style> getEmeraldDarkStyle() async {
    return StyleReader(
      uri: 'https://tiles.basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json',
    ).read();
  }
}
