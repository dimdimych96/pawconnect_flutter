import 'package:flutter/material.dart';

enum DogTemperament {
  playful('playful', 'Игривый', '🎾', Color(0xFF34D399)),
  calm('calm', 'Спокойный', '🌿', Color(0xFF60A5FA)),
  energetic('energetic', 'Энергичный', '⚡', Color(0xFFFBBF24)),
  shy('shy', 'Осторожный', '🙈', Color(0xFFA78BFA)),
  reactive('reactive', 'Дистанция', '⛔', Color(0xFFF87171));

  final String key;
  final String label;
  final String emoji;
  final Color color;

  const DogTemperament(this.key, this.label, this.emoji, this.color);

  static DogTemperament fromString(String? val) {
    if (val == null) return DogTemperament.playful;
    switch (val.toLowerCase()) {
      case 'calm':
        return DogTemperament.calm;
      case 'energetic':
        return DogTemperament.energetic;
      case 'shy':
        return DogTemperament.shy;
      case 'reactive':
        return DogTemperament.reactive;
      case 'playful':
      default:
        return DogTemperament.playful;
    }
  }

  CompatibilityResult checkCompatibility(DogTemperament other) {
    if (this == DogTemperament.reactive || other == DogTemperament.reactive) {
      return const CompatibilityResult(
        level: CompatibilityLevel.careful,
        title: 'Рекомендуется дистанция',
        subtitle: 'Один из питомцев не любит близкий контакт. Держите дистанцию на поводке.',
        badgeColor: Color(0xFFF87171),
        emoji: '⛔',
      );
    }

    if ((this == DogTemperament.playful && other == DogTemperament.playful) ||
        (this == DogTemperament.playful && other == DogTemperament.energetic) ||
        (this == DogTemperament.energetic && other == DogTemperament.energetic)) {
      return const CompatibilityResult(
        level: CompatibilityLevel.high,
        title: 'Отличная совместимость!',
        subtitle: 'Оба хвостика активны и обожают побегать и поиграть вместе.',
        badgeColor: Color(0xFF34D399),
        emoji: '🎾',
      );
    }

    if (this == DogTemperament.shy || other == DogTemperament.shy) {
      return const CompatibilityResult(
        level: CompatibilityLevel.moderate,
        title: 'Осторожное знакомство',
        subtitle: 'Спокойное параллельное гуляние без резких движений.',
        badgeColor: Color(0xFFA78BFA),
        emoji: '🐾',
      );
    }

    return const CompatibilityResult(
      level: CompatibilityLevel.high,
      title: 'Хорошая компания',
      subtitle: 'Приятная совместная прогулка в спокойном ритме.',
      badgeColor: Color(0xFF60A5FA),
      emoji: '🌿',
    );
  }
}

enum CompatibilityLevel { high, moderate, careful }

class CompatibilityResult {
  final CompatibilityLevel level;
  final String title;
  final String subtitle;
  final Color badgeColor;
  final String emoji;

  const CompatibilityResult({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.badgeColor,
    required this.emoji,
  });
}

class WalkSessionModel {
  final String id;
  final String petId;
  final String userId;
  final String walkMode; // 'open', 'private', 'training'
  final double latitude;
  final double longitude;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isActive;
  final String? note;
  final String? petName;
  final String? petBreed;
  final String? petAvatar;
  final DogTemperament temperament;
  final bool isPrivate;

  WalkSessionModel({
    required this.id,
    required this.petId,
    required this.userId,
    required this.walkMode,
    required this.latitude,
    required this.longitude,
    required this.startedAt,
    this.endedAt,
    this.isActive = true,
    this.note,
    this.petName,
    this.petBreed,
    this.petAvatar,
    this.temperament = DogTemperament.playful,
    this.isPrivate = false,
  });

  factory WalkSessionModel.fromJson(Map<String, dynamic> json) {
    return WalkSessionModel(
      id: json['id']?.toString() ?? '',
      petId: json['pet_id']?.toString() ?? json['petId']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      walkMode: json['walk_mode'] ?? json['walkMode'] ?? 'open',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 55.0302,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 82.9204,
      startedAt: DateTime.tryParse(json['started_at'] ?? json['startedAt'] ?? '') ?? DateTime.now(),
      endedAt: json['ended_at'] != null ? DateTime.tryParse(json['ended_at']) : null,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      note: json['note'],
      petName: json['pet_name'] ?? json['petName'],
      petBreed: json['pet_breed'] ?? json['petBreed'],
      petAvatar: json['pet_avatar'] ?? json['petAvatar'],
      temperament: DogTemperament.fromString(json['temperament']),
      isPrivate: json['is_private'] ?? json['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pet_id': petId,
        'user_id': userId,
        'walk_mode': walkMode,
        'latitude': latitude,
        'longitude': longitude,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'is_active': isActive,
        'note': note,
        'pet_name': petName,
        'pet_breed': petBreed,
        'pet_avatar': petAvatar,
        'temperament': temperament.key,
        'is_private': isPrivate,
      };

  WalkSessionModel copyWith({
    String? id,
    String? petId,
    String? userId,
    String? walkMode,
    double? latitude,
    double? longitude,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isActive,
    String? note,
    String? petName,
    String? petBreed,
    String? petAvatar,
    DogTemperament? temperament,
    bool? isPrivate,
  }) {
    return WalkSessionModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      walkMode: walkMode ?? this.walkMode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
      petName: petName ?? this.petName,
      petBreed: petBreed ?? this.petBreed,
      petAvatar: petAvatar ?? this.petAvatar,
      temperament: temperament ?? this.temperament,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}

class WalkingCompanionModel {
  final String petId;
  final String petName;
  final String? petBreed;
  final String? petAvatar;
  final String ownerName;
  final DogTemperament temperament;
  final String walkMode;
  final double latitude;
  final double longitude;
  final int distanceMeters;
  final DateTime walkStartedAt;
  final int minutesWalking;
  final bool isPrivate;

  WalkingCompanionModel({
    required this.petId,
    required this.petName,
    this.petBreed,
    this.petAvatar,
    required this.ownerName,
    required this.temperament,
    required this.walkMode,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.walkStartedAt,
    required this.minutesWalking,
    this.isPrivate = false,
  });

  factory WalkingCompanionModel.fromJson(Map<String, dynamic> json) {
    return WalkingCompanionModel(
      petId: json['pet_id']?.toString() ?? json['petId']?.toString() ?? '',
      petName: json['pet_name'] ?? json['petName'] ?? '',
      petBreed: json['pet_breed'] ?? json['petBreed'],
      petAvatar: json['pet_avatar'] ?? json['petAvatar'],
      ownerName: json['owner_name'] ?? json['ownerName'] ?? 'Сосед',
      temperament: DogTemperament.fromString(json['temperament']),
      walkMode: json['walk_mode'] ?? json['walkMode'] ?? 'open',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 55.0302,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 82.9204,
      distanceMeters: (json['distance_meters'] as num?)?.toInt() ?? (json['distanceMeters'] as num?)?.toInt() ?? 0,
      walkStartedAt: DateTime.tryParse(json['walk_started_at'] ?? json['walkStartedAt'] ?? '') ?? DateTime.now(),
      minutesWalking: (json['minutes_walking'] as num?)?.toInt() ?? (json['minutesWalking'] as num?)?.toInt() ?? 1,
      isPrivate: json['is_private'] ?? json['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'pet_id': petId,
        'pet_name': petName,
        'pet_breed': petBreed,
        'pet_avatar': petAvatar,
        'owner_name': ownerName,
        'temperament': temperament.key,
        'walk_mode': walkMode,
        'latitude': latitude,
        'longitude': longitude,
        'distance_meters': distanceMeters,
        'walk_started_at': walkStartedAt.toIso8601String(),
        'minutes_walking': minutesWalking,
        'is_private': isPrivate,
      };
}

class WalkInvitationModel {
  final String id;
  final String fromUserId;
  final String toPetId;
  final String status;
  final String? message;
  final DateTime createdAt;

  WalkInvitationModel({
    required this.id,
    required this.fromUserId,
    required this.toPetId,
    required this.status,
    this.message,
    required this.createdAt,
  });

  factory WalkInvitationModel.fromJson(Map<String, dynamic> json) {
    return WalkInvitationModel(
      id: json['id']?.toString() ?? '',
      fromUserId: json['from_user_id']?.toString() ?? json['fromUserId']?.toString() ?? '',
      toPetId: json['to_pet_id']?.toString() ?? json['toPetId']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      message: json['message'],
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'from_user_id': fromUserId,
        'to_pet_id': toPetId,
        'status': status,
        'message': message,
        'created_at': createdAt.toIso8601String(),
      };
}
