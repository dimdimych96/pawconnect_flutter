import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/walk_session_model.dart';
import 'package:pawconnect/models/map_marker_model.dart';

void main() {
  group('Walk and Companion Models Tests', () {
    test('DogTemperament parses string and determines compatibility correctly', () {
      expect(DogTemperament.fromString('playful'), DogTemperament.playful);
      expect(DogTemperament.fromString('CALM'), DogTemperament.calm);
      expect(DogTemperament.fromString('energetic'), DogTemperament.energetic);
      expect(DogTemperament.fromString('shy'), DogTemperament.shy);
      expect(DogTemperament.fromString('reactive'), DogTemperament.reactive);
      expect(DogTemperament.fromString(null), DogTemperament.playful);

      // Compatibility checks
      final playfulAndEnergetic = DogTemperament.playful.checkCompatibility(DogTemperament.energetic);
      expect(playfulAndEnergetic.level, CompatibilityLevel.high);
      expect(playfulAndEnergetic.emoji, '🎾');

      final reactiveAndPlayful = DogTemperament.reactive.checkCompatibility(DogTemperament.playful);
      expect(reactiveAndPlayful.level, CompatibilityLevel.careful);
      expect(reactiveAndPlayful.emoji, '⛔');

      final calmAndShy = DogTemperament.calm.checkCompatibility(DogTemperament.shy);
      expect(calmAndShy.level, CompatibilityLevel.moderate);
      expect(calmAndShy.emoji, '🐾');

      final calmAndCalm = DogTemperament.calm.checkCompatibility(DogTemperament.calm);
      expect(calmAndCalm.level, CompatibilityLevel.high);
    });

    test('WalkSessionModel parses json and serializes correctly', () {
      final json = {
        'id': 'session-123',
        'pet_id': 'pet-1',
        'user_id': 'user-1',
        'walk_mode': 'private',
        'latitude': 55.0302,
        'longitude': 82.9204,
        'started_at': '2026-10-19T12:00:00Z',
        'is_active': true,
        'note': 'Вечерняя прогулка',
        'pet_name': 'Арчи',
        'pet_breed': 'Корги',
        'pet_avatar': 'https://example.com/archi.jpg',
        'temperament': 'playful',
        'is_private': true,
      };

      final session = WalkSessionModel.fromJson(json);
      expect(session.id, 'session-123');
      expect(session.petName, 'Арчи');
      expect(session.walkMode, 'private');
      expect(session.isPrivate, true);
      expect(session.temperament, DogTemperament.playful);

      final copy = session.copyWith(walkMode: 'open', isPrivate: false);
      expect(copy.walkMode, 'open');
      expect(copy.isPrivate, false);
      expect(copy.petName, 'Арчи');

      final serialized = session.toJson();
      expect(serialized['id'], 'session-123');
      expect(serialized['walk_mode'], 'private');
      expect(serialized['is_private'], true);
    });

    test('WalkingCompanionModel parses json correctly', () {
      final json = {
        'pet_id': 'pet-companion-1',
        'pet_name': 'Майло',
        'pet_breed': 'Джек-рассел',
        'pet_avatar': 'https://example.com/milo.jpg',
        'owner_name': 'Дмитрий',
        'temperament': 'energetic',
        'walk_mode': 'open',
        'latitude': 55.0310,
        'longitude': 82.9220,
        'distance_meters': 180,
        'walk_started_at': '2026-10-19T11:45:00Z',
        'minutes_walking': 25,
        'is_private': false,
      };

      final companion = WalkingCompanionModel.fromJson(json);
      expect(companion.petId, 'pet-companion-1');
      expect(companion.petName, 'Майло');
      expect(companion.distanceMeters, 180);
      expect(companion.minutesWalking, 25);
      expect(companion.temperament, DogTemperament.energetic);

      final serialized = companion.toJson();
      expect(serialized['pet_id'], 'pet-companion-1');
      expect(serialized['temperament'], 'energetic');
    });

    test('WalkInvitationModel parses json and serializes correctly', () {
      final json = {
        'id': 'invite-1',
        'from_user_id': 'user-1',
        'to_pet_id': 'pet-2',
        'status': 'pending',
        'message': 'Давайте погуляем в парке!',
        'created_at': '2026-10-19T12:05:00Z',
      };

      final invite = WalkInvitationModel.fromJson(json);
      expect(invite.id, 'invite-1');
      expect(invite.fromUserId, 'user-1');
      expect(invite.toPetId, 'pet-2');
      expect(invite.message, 'Давайте погуляем в парке!');

      final serialized = invite.toJson();
      expect(serialized['id'], 'invite-1');
      expect(serialized['message'], 'Давайте погуляем в парке!');
    });

    test('MapMarkerModel handles walking and temperament companion attributes', () {
      final json = {
        'id': 'marker-pet-1',
        'type': 'companion',
        'title': 'Майло гуляет',
        'latitude': 55.0310,
        'longitude': 82.9220,
        'is_walking': true,
        'temperament': 'energetic',
        'walk_mode': 'open',
        'walk_started_at': '2026-10-19T12:00:00Z',
        'createdAt': '2026-10-19T12:00:00Z',
      };

      final marker = MapMarkerModel.fromJson(json);
      expect(marker.isWalking, true);
      expect(marker.temperament, 'energetic');
      expect(marker.walkMode, 'open');

      final copy = marker.copyWith(isWalking: false);
      expect(copy.isWalking, false);
      expect(copy.temperament, 'energetic');
    });
  });
}
