import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/services/location_service.dart';

void main() {
  group('LocationService Tests', () {
    late FakeLocationService fakeLocationService;

    setUp(() {
      fakeLocationService = FakeLocationService(
        initialPosition: const UserLocation(
          latitude: 55.0345,
          longitude: 82.9190,
          accuracy: 5.0,
        ),
      );
    });

    tearDown(() {
      fakeLocationService.dispose();
    });

    test('getCurrentLocation returns initial configured location', () async {
      final loc = await fakeLocationService.getCurrentLocation();
      expect(loc, isNotNull);
      expect(loc!.latitude, equals(55.0345));
      expect(loc.longitude, equals(82.9190));
      expect(loc.accuracy, equals(5.0));
    });

    test('isLocationServiceEnabled returns true by default and can be toggled', () async {
      expect(await fakeLocationService.isLocationServiceEnabled(), isTrue);
      fakeLocationService.setServiceEnabled(false);
      expect(await fakeLocationService.isLocationServiceEnabled(), isFalse);
    });

    test('checkPermission and requestPermission work with LocationPermissionStatus', () async {
      expect(await fakeLocationService.checkPermission(), equals(LocationPermissionStatus.granted));

      fakeLocationService.setPermissionStatus(LocationPermissionStatus.denied);
      expect(await fakeLocationService.checkPermission(), equals(LocationPermissionStatus.denied));

      final requested = await fakeLocationService.requestPermission();
      expect(requested, equals(LocationPermissionStatus.denied));
    });

    test('getLocationStream emits location updates when pushed', () async {
      final emittedLocations = <UserLocation>[];
      final subscription = fakeLocationService.getLocationStream().listen((loc) {
        emittedLocations.add(loc);
      });

      fakeLocationService.pushLocation(
        const UserLocation(latitude: 55.0350, longitude: 82.9200, accuracy: 4.0),
      );
      fakeLocationService.pushLocation(
        const UserLocation(latitude: 55.0360, longitude: 82.9210, accuracy: 3.5),
      );

      // Wait a microtask
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emittedLocations.length, equals(2));
      expect(emittedLocations.first.latitude, equals(55.0350));
      expect(emittedLocations.last.latitude, equals(55.0360));

      await subscription.cancel();
    });
  });
}
