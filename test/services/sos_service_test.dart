import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pawconnect/services/community_service.dart';
import 'package:pawconnect/services/map_service.dart';
import 'package:pawconnect/models/sos_sighting_model.dart';
import 'package:pawconnect/models/map_marker_model.dart';

void main() {
  group('SOS and Safety Radar Service Tests', () {
    test('CommunityService handles toggleVolunteer, reportSighting, and getSightings', () async {
      final dio = Dio();
      final service = CommunityService(dio: dio, allowMockFallback: true);

      final isVolunteering = await service.toggleVolunteer('mock-post-1');
      expect(isVolunteering, isA<bool>());

      final sighting = await service.reportSighting(
        postId: 'mock-post-1',
        latitude: 55.0315,
        longitude: 82.9215,
        note: 'Замечен у входа в сквер',
        timeAgoStr: '15 мин назад',
      );
      expect(sighting, isA<SosSightingModel>());
      expect(sighting.note, 'Замечен у входа в сквер');

      final sightings = await service.getSightings('mock-post-1');
      expect(sightings, isA<List<SosSightingModel>>());
    });

    test('MapService handles verifyHazardMarker with confirm and cleared', () async {
      final dio = Dio();
      final service = MapService(dio: dio, allowMockFallback: true);

      final confirmed = await service.verifyHazardMarker('mock-marker-1', 'confirm');
      expect(confirmed, isA<MapMarkerModel>());

      final cleared = await service.verifyHazardMarker('mock-marker-1', 'cleared');
      expect(cleared, isA<MapMarkerModel>());
    });
  });
}
