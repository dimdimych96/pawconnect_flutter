import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/models/community_post_model.dart';
import 'package:pawconnect/models/pet_story_model.dart';
import 'package:pawconnect/models/post_comment_model.dart';
import 'package:pawconnect/providers/community_provider.dart';
import 'package:pawconnect/services/community_service.dart';

class FakeCommunityService extends CommunityService {
  bool shouldThrow = false;
  List<CommunityPostModel> postsToReturn = [];
  List<PetStoryModel> storiesToReturn = [];
  List<PostCommentModel> commentsToReturn = [];
  int toggleLikeCallCount = 0;
  int addCommentCallCount = 0;

  FakeCommunityService({super.allowMockFallback = true});

  @override
  Future<List<CommunityPostModel>> getPosts({String? district, String? category}) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/posts'),
        error: 'Network connection failed',
      );
    }
    return postsToReturn;
  }

  @override
  Future<List<PetStoryModel>> getStories() async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/stories'),
        error: 'Network connection failed',
      );
    }
    return storiesToReturn;
  }

  @override
  Future<List<PostCommentModel>> getComments(String postId) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/posts/$postId/comments'),
        error: 'Network connection failed',
      );
    }
    return commentsToReturn;
  }

  @override
  Future<PostCommentModel> addComment(String postId, String text) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/posts/$postId/comments'),
        error: 'Network connection failed',
      );
    }
    addCommentCallCount++;
    return PostCommentModel(
      id: 'comment-new',
      postId: postId,
      authorName: 'Тестовый пользователь',
      text: text,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<CommunityPostModel> toggleLike(String postId) async {
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/posts/$postId/like'),
        error: 'Network connection failed',
      );
    }
    toggleLikeCallCount++;
    final post = postsToReturn.firstWhere((p) => p.id == postId);
    return post.copyWith(
      isLiked: !post.isLiked,
      likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
  }
}

void main() {
  group('CommunityProvider & State Tests', () {
    late FakeCommunityService fakeService;
    late CommunityNotifier notifier;

    final testPost1 = CommunityPostModel(
      id: 'post-1',
      authorName: 'PawConnect Team',
      isOfficial: true,
      petName: 'Барс (Самоед)',
      district: 'Центральный',
      category: 'training',
      title: 'Умный выгул',
      content: 'Инструкция по настройке безопасных зон',
      likesCount: 10,
      isLiked: false,
      commentsCount: 2,
      isBookmarked: false,
      createdAt: DateTime(2026, 9, 30, 10, 0),
    );

    final testPost2 = CommunityPostModel(
      id: 'post-2',
      authorName: 'Анна С.',
      isOfficial: false,
      petName: 'Рекс (Хаски)',
      district: 'Заельцовский',
      category: 'sos',
      title: 'Потерялся ошейник',
      content: 'В Нарымском сквере',
      likesCount: 5,
      isLiked: true,
      commentsCount: 0,
      isBookmarked: false,
      createdAt: DateTime(2026, 9, 30, 11, 0),
    );

    final testStory1 = PetStoryModel(
      id: 'story-1',
      authorName: 'PawConnect Team',
      isOfficial: true,
      district: 'Центральный',
      mediaUrl: 'https://example.com/story1.jpg',
      statusText: 'Совет кинолога',
      createdAt: DateTime(2026, 9, 30, 10, 0),
      isViewed: false,
    );

    final testStory2 = PetStoryModel(
      id: 'story-2',
      authorName: 'Михаил Д.',
      petName: 'Луна (Корги)',
      district: 'Советский (Академгородок)',
      mediaUrl: 'https://example.com/story2.jpg',
      statusText: 'Прогулка у НГУ',
      createdAt: DateTime(2026, 9, 30, 10, 30),
      isViewed: false,
    );

    setUp(() {
      fakeService = FakeCommunityService();
      fakeService.postsToReturn = [testPost1, testPost2];
      fakeService.storiesToReturn = [testStory1, testStory2];
      fakeService.commentsToReturn = [
        PostCommentModel(
          id: 'c-1',
          postId: 'post-1',
          authorName: 'Мария',
          text: 'Спасибо за совет!',
          createdAt: DateTime(2026, 9, 30, 10, 15),
        ),
      ];
      notifier = CommunityNotifier(fakeService);
    });

    tearDown(() {
      notifier.dispose();
    });

    test('1. loadFeed() sets postsAsync and storiesAsync to data', () async {
      await notifier.loadFeed();

      expect(notifier.state.postsAsync, isA<AsyncData<List<CommunityPostModel>>>());
      expect(notifier.state.storiesAsync, isA<AsyncData<List<PetStoryModel>>>());

      final posts = notifier.state.postsAsync.value!;
      final stories = notifier.state.storiesAsync.value!;

      expect(posts.length, 2);
      expect(posts.first.title, 'Умный выгул');
      expect(stories.length, 2);
      expect(stories.first.authorName, 'PawConnect Team');
      expect(stories.first.isOfficial, isTrue);
    });

    test('2. Network failure without USE_MOCKS=true results in AsyncError', () async {
      fakeService.shouldThrow = true;

      await notifier.loadFeed(forceRefresh: true);

      expect(notifier.state.postsAsync, isA<AsyncError>());
      expect(notifier.state.storiesAsync, isA<AsyncError>());
    });

    test('3. toggleLike(postId) optimistically toggles like and updates count', () async {
      await notifier.loadFeed();

      // Initially post-1 isLiked == false, likesCount == 10
      expect(notifier.state.posts.first.isLiked, isFalse);
      expect(notifier.state.posts.first.likesCount, 10);

      await notifier.toggleLike('post-1');

      // Optimistically liked
      expect(notifier.state.posts.first.isLiked, isTrue);
      expect(notifier.state.posts.first.likesCount, 11);
      expect(fakeService.toggleLikeCallCount, 1);

      // Toggle back
      await notifier.toggleLike('post-1');
      expect(notifier.state.posts.first.isLiked, isFalse);
      expect(notifier.state.posts.first.likesCount, 10);
      expect(fakeService.toggleLikeCallCount, 2);
    });

    test('4. toggleBookmark(postId) adds/removes from bookmarkedPostIds', () async {
      await notifier.loadFeed();

      expect(notifier.state.bookmarkedPostIds.contains('post-1'), isFalse);

      notifier.toggleBookmark('post-1');
      expect(notifier.state.bookmarkedPostIds.contains('post-1'), isTrue);
      expect(notifier.state.posts.first.isBookmarked, isTrue);

      notifier.toggleBookmark('post-1');
      expect(notifier.state.bookmarkedPostIds.contains('post-1'), isFalse);
      expect(notifier.state.posts.first.isBookmarked, isFalse);
    });

    test('5. addComment(postId, text) prepends comment and increments commentsCount', () async {
      await notifier.loadFeed();
      await notifier.loadComments('post-1');

      expect(notifier.state.postCommentsCache['post-1']?.length, 1);
      expect(notifier.state.posts.first.commentsCount, 2);

      await notifier.addComment('post-1', 'Новый комментарий кинолога');

      final cachedComments = notifier.state.postCommentsCache['post-1'];
      expect(cachedComments, isNotNull);
      expect(cachedComments!.length, 2);
      expect(cachedComments.first.text, 'Новый комментарий кинолога');
      expect(notifier.state.posts.first.commentsCount, 3);
      expect(fakeService.addCommentCallCount, 1);
    });

    test('6. markStoryViewed(storyId) marks story as viewed in storiesAsync', () async {
      await notifier.loadFeed();

      expect(notifier.state.stories.first.isViewed, isFalse);

      notifier.markStoryViewed('story-1');

      expect(notifier.state.stories.first.isViewed, isTrue);
      expect(notifier.state.stories.last.isViewed, isFalse);
    });

    test('7. Filtering by district and category works in filteredPosts', () async {
      await notifier.loadFeed();

      expect(notifier.state.filteredPosts.length, 2);

      notifier.setDistrict('Заельцовский');
      expect(notifier.state.filteredPosts.length, 1);
      expect(notifier.state.filteredPosts.first.id, 'post-2');

      notifier.setCategory('training');
      expect(notifier.state.filteredPosts, isEmpty);

      notifier.setDistrict('Все районы');
      notifier.setCategory('training');
      expect(notifier.state.filteredPosts.length, 1);
      expect(notifier.state.filteredPosts.first.id, 'post-1');
    });
  });
}
