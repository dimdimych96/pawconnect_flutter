import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Fetch Carto Vector Tile', () async {
    // Novosibirsk tile at z=14
    final url = Uri.parse('https://tiles.basemaps.cartocdn.com/vectortiles/carto.streets/v1/14/9235/5760.mvt');
    final response = await http.get(url);
    print('Carto Status: ${response.statusCode}, Bytes: ${response.bodyBytes.length}');
  });
}
