import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_marker_model.dart';
import '../models/gps_device_model.dart';
import '../models/route_model.dart';

class MapService {
  final Dio _dio;

  MapService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.pawconnect.app/api/v1', connectTimeout: const Duration(seconds: 2)));

  // Initial Mock Collar Gps Device
  static final GpsDeviceModel mockGpsDevice = GpsDeviceModel(
    imei: '864912049182394',
    petName: 'Макс',
    latitude: 55.0302,
    longitude: 82.9204,
    isBreached: false,
    safeZoneLatitude: 55.0302,
    safeZoneLongitude: 82.9204,
    safeZoneRadius: 350.0,
    batteryLevel: 88,
    isConnected: true,
    photoUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=400&q=80',
  );

  // Initial Mock Map Markers
  static final List<MapMarkerModel> mockMarkers = [
    MapMarkerModel(
      id: 'marker-1',
      type: 'lost_pet',
      title: 'Потерялся корги Чарли',
      description: 'Убежал в районе Красного проспекта, синий ошейник, очень дружелюбен!',
      latitude: 55.0350,
      longitude: 82.9280,
      breed: 'Вельш-корги',
      age: '1.5 года',
      image: 'https://images.unsplash.com/photo-1612536057832-2ff7ead7819c?auto=format&fit=crop&w=400&q=80',
      address: 'Красный проспект, 38 (возле ст. метро «Площадь Ленина»)',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    MapMarkerModel(
      id: 'marker-2',
      type: 'playground',
      title: 'Дог-парк Центральный',
      description: 'Огражденная площадка с снарядами для дрессировки, есть освещение и питьевая вода.',
      latitude: 55.0260,
      longitude: 82.9150,
      breed: null,
      age: null,
      image: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=400&q=80',
      address: 'Центральный парк (вход со стороны ул. Фрунзе)',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    MapMarkerModel(
      id: 'marker-3',
      type: 'playground',
      title: 'Площадка Нарымский сквер',
      description: 'Просторная зона для выгула собак мелких и средних пород.',
      latitude: 55.0380,
      longitude: 82.9050,
      breed: null,
      age: null,
      image: 'https://images.unsplash.com/photo-1534361960057-19889db9621e?auto=format&fit=crop&w=400&q=80',
      address: 'Нарымский сквер (около памятника Петру и Февронии)',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    MapMarkerModel(
      id: 'marker-4',
      type: 'companion',
      title: 'Лабрадор Бадди ищет компанию',
      description: 'Гуляем каждый вечер с 19:00 до 20:30. Бадди любит активные игры с мячом!',
      latitude: 55.0320,
      longitude: 82.9120,
      breed: 'Лабрадор ретривер',
      age: '3 года',
      image: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=400&q=80',
      address: 'ул. Ленина, 12 (двор возле кинотеатра «Победа»)',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    MapMarkerModel(
      id: 'marker-5',
      type: 'companion',
      title: 'Хаски Луна',
      description: 'Энергичная хаски, ищет компаньонов для совместного бега.',
      latitude: 55.0280,
      longitude: 82.9290,
      breed: 'Сибирский хаски',
      age: '2 года',
      image: 'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?auto=format&fit=crop&w=400&q=80',
      address: 'ул. Октябрьская, 42 (Октябрьский сквер)',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  /// Fetch Markers with Dio fallback to MockData
  Future<List<MapMarkerModel>> getMapMarkers({double? lat, double? lng, double? radius}) async {
    try {
      final response = await _dio.get('/map/markers', queryParameters: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radius != null) 'radius': radius,
      }).timeout(const Duration(milliseconds: 300));
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => MapMarkerModel.fromJson(e)).toList();
      }
    } catch (_) {
      // Instant offline MockData fallback
    }
    return mockMarkers;
  }

  /// Fetch GPS Collar Device with Dio fallback to MockData
  Future<GpsDeviceModel> getActiveGpsDevice() async {
    try {
      final response = await _dio.get('/gps/active').timeout(const Duration(milliseconds: 300));
      if (response.statusCode == 200 && response.data != null) {
        return GpsDeviceModel.fromJson(response.data);
      }
    } catch (_) {
      // Instant offline MockData fallback
    }
    return mockGpsDevice;
  }

  /// Update Safe Zone Radius & Position
  Future<GpsDeviceModel> updateSafeZone(String imei, double lat, double lng, double radius) async {
    try {
      final response = await _dio.patch('/gps/safe-zone', data: {
        'imei': imei,
        'safeZoneLatitude': lat,
        'safeZoneLongitude': lng,
        'safeZoneRadius': radius,
      }).timeout(const Duration(milliseconds: 300));
      if (response.statusCode == 200 && response.data != null) {
        return GpsDeviceModel.fromJson(response.data);
      }
    } catch (_) {}
    return mockGpsDevice.copyWith(
      safeZoneLatitude: lat,
      safeZoneLongitude: lng,
      safeZoneRadius: radius,
    );
  }

  /// Fetch Real Route from OSRM OpenStreetMap API
  Future<ActiveRouteModel> fetchRealRoute({
    required LatLng origin,
    required LatLng destination,
    required String title,
    required String type,
    String mode = 'walk',
  }) async {
    final osrmProfile = mode == 'drive' ? 'car' : 'foot';
    final url =
        'https://router.project-osrm.org/route/v1/$osrmProfile/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson&steps=true';

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: {'Accept': 'application/json'}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 && response.data != null) {
        final routes = response.data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final primaryRoute = routes.first;
          final distanceMeters = (primaryRoute['distance'] as num).round();
          final durationSec = (primaryRoute['duration'] as num).round();
          final durationMin = (durationSec / 60).ceil().clamp(1, 180);

          final geometry = primaryRoute['geometry'];
          final coordinates = (geometry['coordinates'] as List).map<LatLng>((coord) {
            final lng = (coord[0] as num).toDouble();
            final lat = (coord[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          final stepsList = <RouteStep>[];
          final legs = primaryRoute['legs'] as List?;
          if (legs != null && legs.isNotEmpty) {
            final rawSteps = legs.first['steps'] as List?;
            if (rawSteps != null) {
              for (final step in rawSteps) {
                final name = step['name'] as String? ?? '';
                final stepDist = (step['distance'] as num).round();
                final maneuver = step['maneuver'] as Map?;
                final typeStr = maneuver != null ? (maneuver['type'] as String? ?? '') : '';
                final modifier = maneuver != null ? (maneuver['modifier'] as String? ?? '') : '';

                String instruction = 'Продолжайте движение';
                if (typeStr == 'depart') {
                  instruction = name.isNotEmpty ? 'Начните движение по $name' : 'Начните движение по маршруту';
                } else if (typeStr == 'arrive') {
                  instruction = 'Вы прибыли в пункт назначения: $title';
                } else if (typeStr == 'turn' || typeStr == 'end of road') {
                  final dir = modifier.contains('right')
                      ? 'направо'
                      : (modifier.contains('left') ? 'налево' : '');
                  instruction = name.isNotEmpty ? 'Поверните $dir на $name' : 'Поверните $dir';
                } else if (name.isNotEmpty) {
                  instruction = 'Двигайтесь по $name';
                }

                if (stepDist > 5 || stepsList.isEmpty) {
                  stepsList.add(RouteStep(instruction: instruction, distanceMeters: stepDist));
                }
              }
            }
          }

          if (stepsList.isEmpty) {
            stepsList.add(RouteStep(instruction: 'Следуйте по проложенному маршруту', distanceMeters: distanceMeters));
          }

          return ActiveRouteModel(
            destinationTitle: title,
            destinationType: type,
            startPoint: origin,
            endPoint: destination,
            waypoints: coordinates,
            distanceMeters: distanceMeters,
            durationMinutes: durationMin,
            transportMode: mode,
            steps: stepsList,
          );
        }
      }
    } catch (_) {
      // Graceful offline fallback
    }

    // Offline / fallback calculation
    const distanceCalc = Distance();
    final distanceMeters = distanceCalc.as(LengthUnit.Meter, origin, destination).round();
    final midLat = (origin.latitude + destination.latitude) / 2;
    final midLng = (origin.longitude + destination.longitude) / 2;

    final fallbackWaypoints = [
      origin,
      LatLng(origin.latitude + (destination.latitude - origin.latitude) * 0.35, origin.longitude + 0.0008),
      LatLng(midLat + 0.0006, midLng - 0.0004),
      LatLng(destination.latitude - (destination.latitude - origin.latitude) * 0.25, destination.longitude - 0.0005),
      destination,
    ];

    int durationMin = (distanceMeters / (mode == 'drive' ? 400 : (mode == 'dog_run' ? 150 : 80))).ceil().clamp(1, 120);

    return ActiveRouteModel(
      destinationTitle: title,
      destinationType: type,
      startPoint: origin,
      endPoint: destination,
      waypoints: fallbackWaypoints,
      distanceMeters: distanceMeters,
      durationMinutes: durationMin,
      transportMode: mode,
      steps: [
        RouteStep(instruction: 'Двигайтесь по прямой к пункту "$title"', distanceMeters: distanceMeters),
      ],
    );
  }
}
