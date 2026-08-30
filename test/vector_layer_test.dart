import 'package:flutter_test/flutter_test.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

void main() {
  test('Construct VectorTileLayer with MemoryCacheVectorTileProvider and maximumZoom 14', () {
    final styleMap = {
      'version': 8,
      'sources': {
        'openmaptiles': {
          'type': 'vector',
          'url': 'https://tiles.basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json'
        }
      },
      'layers': [
        {
          'id': 'background',
          'type': 'background',
          'paint': {'background-color': '#0A0A0C'}
        },
        {
          'id': 'water',
          'type': 'fill',
          'source': 'openmaptiles',
          'source-layer': 'water',
          'paint': {'fill-color': '#0C1622'}
        }
      ]
    };

    final theme = vtr.ThemeReader().read(styleMap);
    final tileProviders = TileProviders({
      'openmaptiles': MemoryCacheVectorTileProvider(
        delegate: NetworkVectorTileProvider(
          urlTemplate: 'https://tiles.basemaps.cartocdn.com/vectortiles/carto.streets/v1/{z}/{x}/{y}.mvt',
          maximumZoom: 14,
        ),
        maxSizeBytes: 64 * 1024 * 1024,
      ),
    });

    final layer = VectorTileLayer(
      theme: theme,
      tileProviders: tileProviders,
    );

    expect(layer, isNotNull);
  });
}
