import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/community/community_screen.dart';
import 'package:pawconnect/features/community/widgets/comments_bottom_sheet.dart';
import 'package:pawconnect/features/community/widgets/community_post_card.dart';
import 'package:pawconnect/features/community/widgets/community_stories_bar.dart';
import 'package:pawconnect/features/community/widgets/story_player_screen.dart';
import 'package:pawconnect/models/community_post_model.dart';
import 'package:pawconnect/models/pet_story_model.dart';
import 'package:pawconnect/models/post_comment_model.dart';
import 'package:pawconnect/providers/community_provider.dart';
import 'package:pawconnect/services/community_service.dart';

class FakeCommunityService extends CommunityService {
  bool shouldThrow = false;
  Completer<List<CommunityPostModel>>? postsCompleter;
  Completer<List<PetStoryModel>>? storiesCompleter;
  List<CommunityPostModel> postsToReturn = [];
  List<PetStoryModel> storiesToReturn = [];
  List<PostCommentModel> commentsToReturn = [];
  int getPostsCallCount = 0;
  int getStoriesCallCount = 0;
  int toggleLikeCallCount = 0;
  int addCommentCallCount = 0;

  FakeCommunityService({super.allowMockFallback = true});

  @override
  Future<List<CommunityPostModel>> getPosts({String? district, String? category}) async {
    getPostsCallCount++;
    if (postsCompleter != null) {
      return postsCompleter!.future;
    }
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
    getStoriesCallCount++;
    if (storiesCompleter != null) {
      return storiesCompleter!.future;
    }
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
    toggleLikeCallCount++;
    final post = postsToReturn.firstWhere((p) => p.id == postId);
    return post.copyWith(
      isLiked: !post.isLiked,
      likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
  }
}

void main() {
  final testPost1 = CommunityPostModel(
    id: 'post-1',
    authorName: 'PawConnect Team',
    isOfficial: true,
    petName: 'Барс',
    district: 'Центральный',
    category: 'training',
    title: 'Советы кинолога',
    content: 'Правильное обучение питомца командам',
    likesCount: 15,
    isLiked: false,
    commentsCount: 3,
    isBookmarked: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  final testPost2 = CommunityPostModel(
    id: 'post-2',
    authorName: 'Ольга П.',
    isOfficial: false,
    petName: 'Майло',
    district: 'Заельцовский',
    category: 'sos',
    title: 'Потерялся щенок',
    content: 'В районе дендропарка потерялся щенок джек-рассел',
    likesCount: 8,
    isLiked: true,
    commentsCount: 1,
    isBookmarked: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  );

  final testStory1 = PetStoryModel(
    id: 'story-1',
    authorName: 'PawConnect Team',
    isOfficial: true,
    district: 'Центральный',
    mediaUrl: 'https://example.com/story1.jpg',
    statusText: 'Совет дня от ветеринара',
    createdAt: DateTime.now(),
    isViewed: false,
  );

  final testStory2 = PetStoryModel(
    id: 'story-2',
    authorName: 'Дмитрий В.',
    petName: 'Рокки',
    district: 'Советский (Академгородок)',
    mediaUrl: 'https://example.com/story2.jpg',
    statusText: 'Активная утренняя прогулка',
    createdAt: DateTime.now(),
    isViewed: false,
  );

  late FakeCommunityService fakeService;

  setUp(() {
    fakeService = FakeCommunityService();
    fakeService.postsToReturn = [testPost1, testPost2];
    fakeService.storiesToReturn = [testStory1, testStory2];
    fakeService.commentsToReturn = [
      PostCommentModel(
        id: 'c-1',
        postId: 'post-1',
        authorName: 'Анна',
        text: 'Очень полезная информация!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];
  });

  Widget createCommunityScreen() {
    return ProviderScope(
      overrides: [
        communityServiceProvider.overrideWithValue(fakeService),
      ],
      child: const MaterialApp(
        home: CommunityScreen(),
      ),
    );
  }

  group('CommunityScreen UI & Integration Tests', () {
    testWidgets('1. renders sticky top header with title, gradient paw, refresh and add buttons', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.text('PawConnect'), findsWidgets);
      expect(find.text('Лента'), findsOneWidget);
      expect(find.text('Новосибирск • Сообщество'), findsOneWidget);
      expect(find.byIcon(Icons.pets_rounded), findsWidgets);
      expect(find.byKey(const ValueKey('feed_refresh_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('feed_add_post_button')), findsOneWidget);
    });

    testWidgets('2. renders Novosibirsk district capsules and category pills', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.text('Все районы'), findsOneWidget);
      expect(find.text('Центральный'), findsWidgets);
      expect(find.text('Заельцовский'), findsWidgets);

      expect(find.text('Все темы'), findsOneWidget);
      expect(find.text('🚨 SOS'), findsOneWidget);
      expect(find.text('🏥 Здоровье'), findsOneWidget);
      expect(find.text('🦮 Дрессировка'), findsOneWidget);
    });

    testWidgets('3. renders stories rail with active stories', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CommunityStoriesBar), findsOneWidget);
      expect(find.text('PawConnect'), findsWidgets);
      expect(find.text('Рокки'), findsOneWidget);
    });

    testWidgets('4. renders feed post cards with author name, district, content and actions', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsNWidgets(2));
      expect(find.text('Советы кинолога'), findsOneWidget);
      expect(find.text('Потерялся щенок'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('5. tapping district capsule filters the posts stream', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsNWidgets(2));

      // Filter by Заельцовский
      final zaeltsovskyCapsule = find.byKey(const ValueKey('district_filter_Заельцовский'));
      await tester.tap(zaeltsovskyCapsule);
      await tester.pumpAndSettle();

      // Only post-2 should remain
      expect(find.byType(CommunityPostCard), findsOneWidget);
      expect(find.text('Потерялся щенок'), findsOneWidget);
      expect(find.text('Советы кинолога'), findsNothing);
    });

    testWidgets('6. tapping category pill filters the posts stream', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsNWidgets(2));

      // Filter by SOS
      final sosPill = find.byKey(const ValueKey('category_filter_sos'));
      await tester.tap(sosPill);
      await tester.pumpAndSettle();

      // Only post-2 (sos) should remain
      expect(find.byType(CommunityPostCard), findsOneWidget);
      expect(find.text('Потерялся щенок'), findsOneWidget);
      expect(find.text('Советы кинолога'), findsNothing);
    });

    testWidgets('7. empty state displays friendly message and resets filters on tap', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      // Filter to district with no posts in that category
      final dzerzhinskyCapsule = find.byKey(const ValueKey('district_filter_Дзержинский'));
      await tester.ensureVisible(dzerzhinskyCapsule);
      await tester.tap(dzerzhinskyCapsule);
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsNothing);
      expect(find.byKey(const ValueKey('feed_empty_view')), findsOneWidget);
      expect(find.text('В этом районе пока нет публикаций'), findsOneWidget);

      final resetBtn = find.byKey(const ValueKey('feed_reset_filters_button'));
      expect(resetBtn, findsOneWidget);

      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      // Posts are restored
      expect(find.byType(CommunityPostCard), findsNWidgets(2));
    });

    testWidgets('8. tapping story in stories rail opens StoryPlayerScreen and marks story viewed', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      // Tap first story
      final firstStory = find.text('Рокки');
      expect(firstStory, findsOneWidget);
      await tester.tap(firstStory);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // StoryPlayerScreen should be open
      expect(find.byType(StoryPlayerScreen), findsOneWidget);
      expect(find.text('Дмитрий В.'), findsOneWidget);

      // Close story player
      final closeButton = find.byKey(const ValueKey('story_close_button'));
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Back to feed
      expect(find.byType(StoryPlayerScreen), findsNothing);
      expect(find.byType(CommunityScreen), findsOneWidget);
    });

    testWidgets('9. tapping comments on post opens CommentsBottomSheet', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      // Tap on comments of post-1
      final commentIcon = find.byIcon(Icons.chat_bubble_outline_rounded).first;
      await tester.tap(commentIcon);
      await tester.pumpAndSettle();

      expect(find.byType(CommentsBottomSheet), findsOneWidget);
    });

    testWidgets('10. tapping top refresh button re-triggers loadFeed', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      final initialCount = fakeService.getPostsCallCount;

      final refreshBtn = find.byKey(const ValueKey('feed_refresh_button'));
      await tester.tap(refreshBtn);
      await tester.pump();

      expect(fakeService.getPostsCallCount, greaterThan(initialCount));
    });

    testWidgets('11. renders genuine zero-stub error view on network failure with retry button', (tester) async {
      fakeService.shouldThrow = true;

      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('feed_error_view')), findsOneWidget);
      expect(find.text('Не удалось загрузить ленту'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

      final retryBtn = find.byKey(const ValueKey('feed_retry_button'));
      expect(retryBtn, findsOneWidget);

      // Resolve network failure and tap retry
      fakeService.shouldThrow = false;
      await tester.tap(retryBtn);
      await tester.pumpAndSettle();

      // Feed recovered!
      expect(find.byKey(const ValueKey('feed_error_view')), findsNothing);
      expect(find.byType(CommunityPostCard), findsNWidgets(2));
    });

    testWidgets('12. renders shimmering skeleton cards while feed is in loading state', (tester) async {
      final completer = Completer<List<CommunityPostModel>>();
      fakeService.postsCompleter = completer;

      await tester.pumpWidget(createCommunityScreen());
      await tester.pump(); // Start loading frame

      // Skeleton should be visible, no post cards
      expect(find.byKey(const ValueKey('feed_skeleton')), findsOneWidget);
      expect(find.byType(CommunityPostCard), findsNothing);

      // Complete async response
      completer.complete([testPost1, testPost2]);
      await tester.pumpAndSettle();

      // Feed loaded
      expect(find.byKey(const ValueKey('feed_skeleton')), findsNothing);
      expect(find.byType(CommunityPostCard), findsNWidgets(2));
    });

    testWidgets('13. Apple Liquid Glass Budget: strictly ZERO BackdropFilter in scrolling post cards', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      final postCards = find.byType(CommunityPostCard);
      expect(postCards, findsWidgets);

      final backdropFilterInPosts = find.descendant(
        of: postCards,
        matching: find.byType(BackdropFilter),
      );
      expect(backdropFilterInPosts, findsNothing);
    });
  });
}
