import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/community_post_model.dart';
import 'package:pawconnect/models/pet_story_model.dart';
import 'package:pawconnect/models/post_comment_model.dart';

void main() {
  group('Community Models Tests', () {
    test('PetStoryModel serialization and copyWith', () {
      final story = PetStoryModel(
        id: 'story-1',
        authorName: 'PawConnect Team',
        isOfficial: true,
        authorAvatar: 'https://example.com/avatar.jpg',
        petName: null,
        district: 'Центральный',
        mediaUrl: 'https://example.com/story.jpg',
        statusText: 'Совет кинолога',
        createdAt: DateTime(2026, 9, 30, 12, 0),
        isViewed: false,
      );

      final json = story.toJson();
      expect(json['isOfficial'], isTrue);
      expect(json['district'], 'Центральный');

      final deserialized = PetStoryModel.fromJson(json);
      expect(deserialized.id, 'story-1');
      expect(deserialized.isOfficial, isTrue);

      final viewed = story.copyWith(isViewed: true);
      expect(viewed.isViewed, isTrue);
    });

    test('PostCommentModel serialization and copyWith', () {
      final comment = PostCommentModel(
        id: 'c-1',
        postId: 'post-1',
        authorName: 'Дмитрий',
        authorAvatar: null,
        isOfficial: false,
        text: 'Отличный совет!',
        createdAt: DateTime(2026, 9, 30, 12, 5),
        likesCount: 3,
        isLiked: true,
      );

      final json = comment.toJson();
      expect(json['text'], 'Отличный совет!');

      final deserialized = PostCommentModel.fromJson(json);
      expect(deserialized.likesCount, 3);
      expect(deserialized.isLiked, isTrue);
    });

    test('CommunityPostModel extended fields serialization', () {
      final post = CommunityPostModel(
        id: 'p-1',
        authorName: 'PawConnect Team',
        isOfficial: true,
        petName: 'Рекс (Овчарка)',
        district: 'Заельцовский',
        category: 'training',
        title: 'Умный выгул',
        content: 'Инструкция по настройке безопасной зоны',
        likesCount: 15,
        isLiked: true,
        commentsCount: 4,
        isBookmarked: true,
        createdAt: DateTime(2026, 9, 30, 10, 0),
        imageUrl: 'https://example.com/dog.jpg',
      );

      final json = post.toJson();
      expect(json['isOfficial'], isTrue);
      expect(json['commentsCount'], 4);
      expect(json['isBookmarked'], isTrue);

      final fromJson = CommunityPostModel.fromJson(json);
      expect(fromJson.isOfficial, isTrue);
      expect(fromJson.petName, 'Рекс (Овчарка)');
    });
  });
}
