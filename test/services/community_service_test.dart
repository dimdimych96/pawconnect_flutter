import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/services/community_service.dart';

void main() {
  group('CommunityService Tests', () {
    test('Zero-Stub Policy: Rethrows DioException when allowMockFallback is false', () async {
      final dio = Dio();
      // Configure Dio adapter or invalid baseUrl to trigger connection error
      dio.options.baseUrl = 'http://invalid-unreachable-host:9999/api/v1';
      dio.options.connectTimeout = const Duration(milliseconds: 100);

      final service = CommunityService(dio: dio, allowMockFallback: false);

      expect(() => service.getPosts(), throwsA(isA<DioException>()));
      expect(() => service.getStories(), throwsA(isA<DioException>()));
      expect(() => service.getComments('post-1'), throwsA(isA<DioException>()));
      expect(() => service.addComment('post-1', 'hello'), throwsA(isA<DioException>()));
      expect(() => service.toggleLike('post-1'), throwsA(isA<DioException>()));
    });

    test('Offline Mock Fallback: Returns curated mocks when allowMockFallback is true', () async {
      final dio = Dio();
      dio.options.baseUrl = 'http://invalid-unreachable-host:9999/api/v1';
      dio.options.connectTimeout = const Duration(milliseconds: 100);

      final service = CommunityService(dio: dio, allowMockFallback: true);

      final stories = await service.getStories();
      expect(stories, isNotEmpty);
      expect(stories.first.id, 'story-pc-official');
      expect(stories.first.authorName, 'PawConnect Team');

      final posts = await service.getPosts();
      expect(posts, isNotEmpty);
      expect(posts.any((p) => p.isOfficial), isTrue);

      final comments = await service.getComments('post-official-1');
      expect(comments, isNotEmpty);
      expect(comments.first.authorName, 'PawConnect Team');

      final newComment = await service.addComment('post-1', 'Замечательный совет!');
      expect(newComment.text, 'Замечательный совет!');
      expect(newComment.postId, 'post-1');

      final likedPost = await service.toggleLike('post-official-1');
      expect(likedPost.id, 'post-official-1');
    });

    test('Offline Mock Fallback: District and category filtering on mock posts', () async {
      final dio = Dio();
      dio.options.baseUrl = 'http://invalid-unreachable-host:9999/api/v1';
      dio.options.connectTimeout = const Duration(milliseconds: 100);

      final service = CommunityService(dio: dio, allowMockFallback: true);

      final zaeltsovskyPosts = await service.getPosts(district: 'Заельцовский');
      for (final p in zaeltsovskyPosts) {
        expect(p.district, 'Заельцовский');
      }

      final trainingPosts = await service.getPosts(category: 'training');
      for (final p in trainingPosts) {
        expect(p.category, 'training');
      }
    });
  });
}
