import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  restricted,
}

class UserLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final DateTime? timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.timestamp,
  });

  factory UserLocation.fromPosition(Position position) {
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }
}

abstract class LocationService {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<UserLocation?> getCurrentLocation();
  Stream<UserLocation> getLocationStream({int distanceFilter = 5});
  void dispose();
}

/// Real GPS Implementation via geolocator plugin with IP-Geo fallback
class GeolocatorLocationService implements LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 3)));

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (kIsWeb) return true;
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return true;
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final perm = await Geolocator.checkPermission();
      return _mapPermission(perm);
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final perm = await Geolocator.requestPermission();
      final mapped = _mapPermission(perm);
      if (mapped == LocationPermissionStatus.granted) {
        return mapped;
      }
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        if (pos.latitude != 0.0 || pos.longitude != 0.0) {
          return LocationPermissionStatus.granted;
        }
      } catch (_) {}
      return mapped;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<UserLocation?> getCurrentLocation() async {
    // 1. Try Hardware GPS
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );
      if (position.latitude != 0.0 || position.longitude != 0.0) {
        return UserLocation.fromPosition(position);
      }
    } catch (e) {
      debugPrint('Hardware GPS unavailable ($e), attempting real IP-based geolocation fallback...');
    }

    // 2. Real IP-Based Geolocation Fallback (Works on mobile HTTP without browser security blocks)
    return await _fetchIpLocation();
  }

  Future<UserLocation?> _fetchIpLocation() async {
    try {
      final response = await _dio.get('https://ipapi.co/json/');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          debugPrint('Determined location via IP: $lat, $lng');
          return UserLocation(
            latitude: lat,
            longitude: lng,
            accuracy: 500.0,
            timestamp: DateTime.now(),
          );
        }
      }
    } catch (_) {}

    try {
      final response = await _dio.get('http://ip-api.com/json');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final lat = (data['lat'] as num?)?.toDouble();
        final lng = (data['lon'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          debugPrint('Determined location via secondary IP provider: $lat, $lng');
          return UserLocation(
            latitude: lat,
            longitude: lng,
            accuracy: 500.0,
            timestamp: DateTime.now(),
          );
        }
      }
    } catch (_) {}

    return null;
  }

  @override
  Stream<UserLocation> getLocationStream({int distanceFilter = 5}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    ).map((position) => UserLocation.fromPosition(position));
  }

  LocationPermissionStatus _mapPermission(LocationPermission perm) {
    switch (perm) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.restricted;
      case LocationPermission.denied:
      default:
        return LocationPermissionStatus.denied;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
  }
}

/// Fake Location Service for deterministic unit & widget tests
class FakeLocationService implements LocationService {
  UserLocation? _currentPosition;
  bool _serviceEnabled = true;
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.granted;
  final StreamController<UserLocation> _controller = StreamController<UserLocation>.broadcast();

  FakeLocationService({UserLocation? initialPosition}) : _currentPosition = initialPosition;

  void pushLocation(UserLocation location) {
    _currentPosition = location;
    if (!_controller.isClosed) {
      _controller.add(location);
    }
  }

  void setServiceEnabled(bool enabled) {
    _serviceEnabled = enabled;
  }

  void setPermissionStatus(LocationPermissionStatus status) {
    _permissionStatus = status;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => _serviceEnabled;

  @override
  Future<LocationPermissionStatus> checkPermission() async => _permissionStatus;

  @override
  Future<LocationPermissionStatus> requestPermission() async => _permissionStatus;

  @override
  Future<UserLocation?> getCurrentLocation() async => _currentPosition;

  @override
  Stream<UserLocation> getLocationStream({int distanceFilter = 5}) => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}
