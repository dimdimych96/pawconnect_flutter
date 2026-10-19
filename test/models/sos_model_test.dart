import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/sos_sighting_model.dart';
import 'package:pawconnect/models/map_marker_model.dart';
import 'package:pawconnect/models/community_post_model.dart';

void main() {
  group('SOS and Hazard Models Test', () {
    test('SosSightingModel parses json correctly with camelCase and snake_case', () {
      final json = {
        'id': 'sighting-1',
        'postId': 'post-100',
        'authorId': 'user-1',
        'authorName': 'Алексей',
        'authorAvatar': 'https://example.com/avatar.jpg',
        'latitude': 55.0315,
        'longitude': 82.9215,
        'note': 'Замечен у сквера, бежал на восток',
        'timeAgoStr': '15 мин назад',
        'createdAt': '2026-10-19T10:00:00Z',
      };
      final sighting = SosSightingModel.fromJson(json);
      expect(sighting.id, 'sighting-1');
      expect(sighting.postId, 'post-100');
      expect(sighting.authorName, 'Алексей');
      expect(sighting.latitude, 55.0315);
      expect(sighting.longitude, 82.9215);
      expect(sighting.note, 'Замечен у сквера, бежал на восток');
      expect(sighting.timeAgoStr, '15 мин назад');

      final serialized = sighting.toJson();
      expect(serialized['id'], 'sighting-1');
      expect(serialized['postId'], 'post-100');
      expect(serialized['timeAgoStr'], '15 мин назад');
    });

    test('MapMarkerModel parses hazard attributes correctly', () {
      final json = {
        'id': 'danger-1',
        'type': 'danger',
        'title': 'Зона риска: Отрава',
        'description': 'Рассыпан порошок',
        'latitude': 55.0340,
        'longitude': 82.9180,
        'dangerType': 'poison',
        'confirmationsCount': 3,
        'clearedCount': 1,
        'createdAt': '2026-10-19T10:00:00Z',
      };
      final marker = MapMarkerModel.fromJson(json);
      expect(marker.dangerType, 'poison');
      expect(marker.confirmationsCount, 3);
      expect(marker.clearedCount, 1);
      expect(marker.type, 'danger');

      final copy = marker.copyWith(confirmationsCount: 4);
      expect(copy.confirmationsCount, 4);
      expect(copy.dangerType, 'poison');
    });

    test('CommunityPostModel parses volunteers and sightings correctly', () {
      final json = {
        'id': 'post-sos-1',
        'authorName': 'Ольга',
        'district': 'Центральный',
        'category': 'sos',
        'title': 'SOS: Пропал корги',
        'text': 'Помогите найти малыша',
        'likesCount': 10,
        'isLiked': false,
        'volunteersCount': 5,
        'sightingsCount': 2,
        'isVolunteering': true,
        'createdAt': '2026-10-19T10:00:00Z',
      };
      final post = CommunityPostModel.fromJson(json);
      expect(post.volunteersCount, 5);
      expect(post.sightingsCount, 2);
      expect(post.isVolunteering, true);

      final copy = post.copyWith(volunteersCount: 6, isVolunteering: false);
      expect(copy.volunteersCount, 6);
      expect(copy.isVolunteering, false);
      expect(copy.sightingsCount, 2);
    });
  });
}
