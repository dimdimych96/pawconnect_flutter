import 'package:dio/dio.dart';
import '../models/map_marker_model.dart';
import '../models/gps_device_model.dart';

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
      });
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
      final response = await _dio.get('/gps/active');
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
      });
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
}
