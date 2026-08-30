import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/providers/map_provider.dart';
import 'package:pawconnect/services/map_service.dart';
import 'package:pawconnect/services/location_service.dart';

void main() {
  group('MapNotifier Location Tracking Tests', () {
    late FakeLocationService fakeLocationService;
    late MapService mapService;
    late MapNotifier mapNotifier;

    setUp(() {
      fakeLocationService = FakeLocationService(
        initialPosition: const UserLocation(
          latitude: 55.0340,
          longitude: 82.9180,
          accuracy: 4.2,
        ),
      );
      mapService = MapService();
      mapNotifier = MapNotifier(mapService, locationService: fakeLocationService);
    });

    tearDown(() {
      mapNotifier.dispose();
      fakeLocationService.dispose();
    });

    test('Initial user position is updated from LocationService on init', () async {
      await mapNotifier.initLocationTracking();

      expect(mapNotifier.state.userLatitude, equals(55.0340));
      expect(mapNotifier.state.userLongitude, equals(82.9180));
      expect(mapNotifier.state.hasLocationPermission, isTrue);
      expect(mapNotifier.state.isLocationTrackingActive, isTrue);
    });

    test('Position stream updates user location dynamically in state', () async {
      await mapNotifier.initLocationTracking();

      // Push new location
      fakeLocationService.pushLocation(
        const UserLocation(latitude: 55.0360, longitude: 82.9220, accuracy: 3.0),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(mapNotifier.state.userLatitude, equals(55.0360));
      expect(mapNotifier.state.userLongitude, equals(82.9220));
    });

    test('Distance to pet recalculates dynamically when user moves', () async {
      await mapNotifier.loadMapData();
      await mapNotifier.initLocationTracking();

      final initialDistance = mapNotifier.state.distanceToPetInMeters;
      expect(initialDistance, isNonZero);

      // Move closer to pet coordinates (Pet is at 55.0302, 82.9204)
      fakeLocationService.pushLocation(
        const UserLocation(latitude: 55.0302, longitude: 82.9204, accuracy: 2.0),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(mapNotifier.state.distanceToPetInMeters, equals(0));
    });

    test('Handles permission denial gracefully with location fallback', () async {
      fakeLocationService.setPermissionStatus(LocationPermissionStatus.denied);

      await mapNotifier.initLocationTracking();

      expect(mapNotifier.state.hasLocationPermission, isFalse);
      expect(mapNotifier.state.userLatitude, equals(55.0340));
    });
  });
}
