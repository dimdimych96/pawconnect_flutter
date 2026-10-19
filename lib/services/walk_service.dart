import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../models/walk_session_model.dart';

class WalkService {
  final Dio _dio;
  final bool _allowMockFallback;

  WalkService({Dio? dio, bool? allowMockFallback})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 4),
              ),
            ),
        _allowMockFallback = allowMockFallback ?? AppConfig.enableOfflineMocks;

  /// Default mock companions around Central Novosibirsk
  static final List<WalkingCompanionModel> mockCompanions = [
    WalkingCompanionModel(
      petId: 'pet-mock-1',
      petName: 'Майло',
      petBreed: 'Джек-рассел терьер',
      petAvatar: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=400&q=80',
      ownerName: 'Дмитрий',
      temperament: DogTemperament.energetic,
      walkMode: 'open',
      latitude: 55.0315,
      longitude: 82.9230,
      distanceMeters: 180,
      walkStartedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      minutesWalking: 18,
      isPrivate: false,
    ),
    WalkingCompanionModel(
      petId: 'pet-mock-2',
      petName: 'Бадди',
      petBreed: 'Золотистый ретривер',
      petAvatar: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=400&q=80',
      ownerName: 'Елена',
      temperament: DogTemperament.playful,
      walkMode: 'open',
      latitude: 55.0270,
      longitude: 82.9180,
      distanceMeters: 320,
      walkStartedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      minutesWalking: 25,
      isPrivate: false,
    ),
    WalkingCompanionModel(
      petId: 'pet-mock-3',
      petName: 'Луна',
      petBreed: 'Сибирский хаски',
      petAvatar: 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=400&q=80',
      ownerName: 'Игорь',
      temperament: DogTemperament.energetic,
      walkMode: 'training',
      latitude: 55.0345,
      longitude: 82.9110,
      distanceMeters: 450,
      walkStartedAt: DateTime.now().subtract(const Duration(minutes: 42)),
      minutesWalking: 42,
      isPrivate: false,
    ),
    WalkingCompanionModel(
      petId: 'pet-mock-4',
      petName: 'Оливер',
      petBreed: 'Французский бульдог',
      petAvatar: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=400&q=80',
      ownerName: 'София',
      temperament: DogTemperament.calm,
      walkMode: 'open',
      latitude: 55.0290,
      longitude: 82.9245,
      distanceMeters: 210,
      walkStartedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      minutesWalking: 12,
      isPrivate: false,
    ),
    WalkingCompanionModel(
      petId: 'pet-mock-5',
      petName: 'Пикси',
      petBreed: 'Той-пудель',
      petAvatar: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=400&q=80',
      ownerName: 'Анастасия',
      temperament: DogTemperament.shy,
      walkMode: 'open',
      latitude: 55.0330,
      longitude: 82.9195,
      distanceMeters: 290,
      walkStartedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      minutesWalking: 15,
      isPrivate: false,
    ),
    WalkingCompanionModel(
      petId: 'pet-mock-6',
      petName: 'Шериф',
      petBreed: 'Немецкая овчарка',
      petAvatar: 'https://images.unsplash.com/photo-1589941013453-ec89f33b5e95?auto=format&fit=crop&w=400&q=80',
      ownerName: 'Михаил',
      temperament: DogTemperament.reactive,
      walkMode: 'private',
      latitude: 55.0265,
      longitude: 82.9125,
      distanceMeters: 380,
      walkStartedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      minutesWalking: 30,
      isPrivate: true,
    ),
  ];

  Future<WalkSessionModel> startWalk({
    required String petId,
    String walkMode = 'open',
    required double latitude,
    required double longitude,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '/walks/start',
        data: {
          'pet_id': petId,
          'walk_mode': walkMode,
          'latitude': latitude,
          'longitude': longitude,
          if (note != null) 'note': note,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return WalkSessionModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }

    // Fallback for offline / demo mode
    return WalkSessionModel(
      id: 'mock-session-${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      userId: 'usr-current',
      walkMode: walkMode,
      latitude: latitude,
      longitude: longitude,
      startedAt: DateTime.now(),
      isActive: true,
      note: note,
      petName: 'Арчи',
      petBreed: 'Вельш-корги',
      temperament: DogTemperament.playful,
      isPrivate: walkMode == 'private',
    );
  }

  Future<WalkSessionModel> stopWalk({required String petId}) async {
    try {
      final response = await _dio.post(
        '/walks/stop',
        data: {'pet_id': petId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return WalkSessionModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }

    return WalkSessionModel(
      id: 'mock-session-stopped',
      petId: petId,
      userId: 'usr-current',
      walkMode: 'open',
      latitude: 55.0302,
      longitude: 82.9204,
      startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      endedAt: DateTime.now(),
      isActive: false,
    );
  }

  Future<WalkSessionModel?> getActiveWalk({required String petId}) async {
    try {
      final response = await _dio.get(
        '/walks/active',
        queryParameters: {'pet_id': petId},
      );
      if (response.statusCode == 200 && response.data != null) {
        return WalkSessionModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
      return null;
    }
  }

  Future<List<WalkingCompanionModel>> getNearbyCompanions({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
    bool includePrivate = true,
  }) async {
    try {
      final response = await _dio.get(
        '/walks/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius_meters': radiusMeters,
          'include_private': includePrivate,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((item) => WalkingCompanionModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } on DioException catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }

    return mockCompanions;
  }

  Future<WalkInvitationModel> sendWalkInvite({
    required String toPetId,
    String? message,
  }) async {
    try {
      final response = await _dio.post(
        '/walks/invite',
        data: {
          'to_pet_id': toPetId,
          if (message != null) 'message': message,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return WalkInvitationModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }

    return WalkInvitationModel(
      id: 'invite-mock-${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: 'usr-current',
      toPetId: toPetId,
      status: 'pending',
      message: message ?? 'Привет! Давайте погуляем вместе 🐾',
      createdAt: DateTime.now(),
    );
  }

  Future<void> updatePetTemperament({
    required String petId,
    required DogTemperament temperament,
  }) async {
    try {
      await _dio.put(
        '/walks/pets/$petId/temperament',
        data: {'temperament': temperament.key},
      );
    } on DioException catch (e) {
      if (!_allowMockFallback) {
        rethrow;
      }
    }
  }
}
