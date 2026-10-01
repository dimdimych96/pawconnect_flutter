import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/community/community_screen.dart';
import 'package:pawconnect/features/community/widgets/comments_bottom_sheet.dart';
import 'package:pawconnect/features/community/widgets/community_post_card.dart';
import 'package:pawconnect/features/community/widgets/community_stories_bar.dart';
import 'package:pawconnect/features/community/widgets/district_picker_bottom_sheet.dart';
import 'package:pawconnect/features/community/widgets/feed_segmented_control.dart';
import 'package:pawconnect/features/community/widgets/new_post_modal.dart';
import 'package:pawconnect/features/community/widgets/new_story_modal.dart';
import 'package:pawconnect/features/community/widgets/story_player_screen.dart';
import 'package:pawconnect/models/auth_model.dart';
import 'package:pawconnect/models/community_post_model.dart';
import 'package:pawconnect/models/pet_story_model.dart';
import 'package:pawconnect/models/post_comment_model.dart';
import 'package:pawconnect/providers/auth_provider.dart';
import 'package:pawconnect/providers/community_provider.dart';
import 'package:pawconnect/services/auth_service.dart';
import 'package:pawconnect/services/community_service.dart';

class FakeCommunityService extends CommunityService {
  bool shouldThrow = false;
  Completer<List<CommunityPostModel>>? postsCompleter;
  Completer<List<PetStoryModel>>? storiesCompleter;
  List<CommunityPostModel> postsToReturn = [];
  List<PetStoryModel> storiesToReturn = [];
  List<PostCommentModel> commentsToReturn = [];
  List<PetStoryModel> createdStories = [];
  List<CommunityPostModel> createdPosts = [];
  int getPostsCallCount = 0;
  int getStoriesCallCount = 0;
  int toggleLikeCallCount = 0;
  int addCommentCallCount = 0;
  int createPostCallCount = 0;
  int updatePostCallCount = 0;
  int deletePostCallCount = 0;
  int createStoryCallCount = 0;
  int deleteStoryCallCount = 0;

  FakeCommunityService({super.allowMockFallback = true});

  @override
  Future<PetStoryModel> createStory(PetStoryModel story) async {
    createStoryCallCount++;
    createdStories.add(story);
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/stories'),
        error: 'Network connection failed',
      );
    }
    return story;
  }

  @override
  Future<void> deleteStory(String storyId) async {
    deleteStoryCallCount++;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/stories/$storyId'),
        error: 'Network connection failed',
      );
    }
  }

  @override
  Future<CommunityPostModel> createPost(CommunityPostModel post) async {
    createPostCallCount++;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/posts'),
        error: 'Network connection failed',
      );
    }
    return post;
  }

  @override
  Future<CommunityPostModel> updatePost(CommunityPostModel post) async {
    updatePostCallCount++;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/posts/${post.id}'),
        error: 'Network connection failed',
      );
    }
    return post;
  }

  @override
  Future<void> deletePost(String postId) async {
    deletePostCallCount++;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: '/community/posts/$postId'),
        error: 'Network connection failed',
      );
    }
  }

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

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(UserAuthModel user)
      : super(AuthService(storage: FakeAuthStorage(), allowMockFallback: true)) {
    state = AuthState(
      isAuthenticated: true,
      isLoading: false,
      currentUser: user,
    );
  }

  @override
  Future<void> checkSession() async {}
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

  Widget createCommunityScreen({UserAuthModel? currentUser}) {
    return ProviderScope(
      overrides: [
        communityServiceProvider.overrideWithValue(fakeService),
        if (currentUser != null)
          authNotifierProvider.overrideWith((ref) => MockAuthNotifier(currentUser)),
      ],
      child: const MaterialApp(
        home: CommunityScreen(),
      ),
    );
  }

  group('CommunityScreen UI & Integration Tests (Tabs & Segmented Control)', () {
    testWidgets('1. renders clean branding header with PawConnect logo & add post button (no duplicate refresh button)', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.text('PawConnect'), findsWidgets);
      expect(find.byIcon(Icons.pets_rounded), findsWidgets);
      expect(find.byKey(const ValueKey('feed_add_post_button')), findsOneWidget);
      // Duplicate refresh button is removed in favor of pull-to-refresh
      expect(find.byKey(const ValueKey('feed_refresh_button')), findsNothing);
    });

    testWidgets('2. renders Liquid Glass FeedSegmentedControl with 3 tabs', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      final segmentedControl = find.byType(FeedSegmentedControl);
      expect(segmentedControl, findsOneWidget);
      expect(find.byKey(const ValueKey('feed_tab_for_you')), findsOneWidget);
      expect(find.byKey(const ValueKey('feed_tab_district')), findsOneWidget);
      expect(find.byKey(const ValueKey('feed_tab_sos')), findsOneWidget);
      expect(find.descendant(of: segmentedControl, matching: find.text('Для вас')), findsOneWidget);
      expect(find.descendant(of: segmentedControl, matching: find.text('Мой район')), findsOneWidget);
      expect(find.descendant(of: segmentedControl, matching: find.text('SOS')), findsOneWidget);
    });

    testWidgets('3. renders stories rail within the scrollable feed in Tab 0 («Для вас»)', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CommunityStoriesBar), findsOneWidget);
      expect(find.text('PawConnect'), findsWidgets);
      expect(find.text('Рокки'), findsOneWidget);
    });

    testWidgets('4. renders feed post cards on Tab 0 with all posts', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CommunityPostCard), findsNWidgets(2));
      expect(find.text('Советы кинолога'), findsOneWidget);
      expect(find.text('Потерялся щенок'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('5. switching to Tab 1 («Мой район») renders contextual district selector bar', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      // Tap on Tab 1 «Мой район»
      final districtTab = find.byKey(const ValueKey('feed_tab_district'));
      await tester.tap(districtTab);
      await tester.pumpAndSettle();

      // Contextual bar should appear
      expect(find.byKey(const ValueKey('feed_change_district_button')), findsOneWidget);
      expect(find.text('Все районы Новосибирска'), findsOneWidget);
      expect(find.text('Сменить'), findsOneWidget);
    });

    testWidgets('6. tapping «Сменить» opens DistrictPickerBottomSheet with Novosibirsk districts', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      // Tap Tab 1
      await tester.tap(find.byKey(const ValueKey('feed_tab_district')));
      await tester.pumpAndSettle();

      // Tap «Сменить»
      final changeBtn = find.byKey(const ValueKey('feed_change_district_button'));
      await tester.tap(changeBtn);
      await tester.pumpAndSettle();

      // Bottom sheet should be visible with Novosibirsk districts
      final sheetFinder = find.byType(DistrictPickerBottomSheet);
      expect(sheetFinder, findsOneWidget);
      expect(find.text('Район Новосибирска'), findsOneWidget);
      expect(find.descendant(of: sheetFinder, matching: find.text('🏙️ Все районы города')), findsOneWidget);
      expect(find.descendant(of: sheetFinder, matching: find.text('Центральный')), findsOneWidget);
      expect(find.descendant(of: sheetFinder, matching: find.text('Заельцовский')), findsOneWidget);

      // Select Заельцовский
      final zaeltsovskyOption = find.byKey(const ValueKey('district_option_Заельцовский'));
      await tester.tap(zaeltsovskyOption);
      await tester.pumpAndSettle();

      // Sheet is closed and district updated
      expect(find.byType(DistrictPickerBottomSheet), findsNothing);
      expect(find.text('Заельцовский район'), findsOneWidget);
    });

    testWidgets('7. switching to Tab 2 («SOS 🚨») renders SOS banner and filters to urgent posts', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      // Tap Tab 2
      final sosTab = find.byKey(const ValueKey('feed_tab_sos'));
      await tester.tap(sosTab);
      await tester.pumpAndSettle();

      // Emergency banner should appear
      expect(find.text('Экстренные поиски и помощь'), findsOneWidget);
      expect(find.text('1 активных'), findsOneWidget);

      // Only SOS post (post-2) is shown
      expect(find.byType(CommunityPostCard), findsOneWidget);
      expect(find.text('Потерялся щенок'), findsOneWidget);
      expect(find.text('Советы кинолога'), findsNothing);
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

    testWidgets('10. renders genuine zero-stub error view on network failure with retry button', (tester) async {
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

    testWidgets('11. renders shimmering skeleton cards while feed is in loading state', (tester) async {
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

    testWidgets('12. Apple Liquid Glass Budget: strictly ZERO BackdropFilter in scrolling post cards', (tester) async {
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

    testWidgets('13. tapping add post button opens NewPostModal, enters title & content, publishes successfully', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      final addBtn = find.byKey(const ValueKey('feed_add_post_button'));
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // NewPostModal should be open
      expect(find.byType(NewPostModal), findsOneWidget);
      expect(find.text('Новая запись в ленту'), findsOneWidget);

      // Enter title and content
      await tester.enterText(find.widgetWithText(TextField, 'Заголовок записи...'), 'Мой новый пост');
      await tester.enterText(find.widgetWithText(TextField, 'Расскажите подробнее сообществу районов...'), 'Гуляем на набережной');
      await tester.pump();

      // Submit
      final submitBtn = find.byKey(const ValueKey('submit_new_post_button'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Modal is closed and createPost was invoked
      expect(find.byType(NewPostModal), findsNothing);
      expect(fakeService.createPostCallCount, equals(1));
      expect(find.text('Мой новый пост'), findsOneWidget);

      // Advance PawToast auto-dismiss timer
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('14. tapping actions button on author post opens action sheet with edit, delete, copy link options', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      final actionsBtn = find.byKey(const ValueKey('post_actions_button_post-1'));
      expect(actionsBtn, findsOneWidget);
      await tester.tap(actionsBtn);
      await tester.pumpAndSettle();

      expect(find.text('Редактировать запись'), findsOneWidget);
      expect(find.text('Удалить запись'), findsOneWidget);
      expect(find.text('Скопировать ссылку'), findsOneWidget);
    });

    testWidgets('15. tapping edit opens NewPostModal with post data, saves updates in feed and calls updatePost', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      // Open action sheet
      await tester.tap(find.byKey(const ValueKey('post_actions_button_post-1')));
      await tester.pumpAndSettle();

      // Tap Edit
      await tester.tap(find.text('Редактировать запись'));
      await tester.pumpAndSettle();

      // Modal in edit mode
      expect(find.text('Редактировать запись'), findsOneWidget);
      expect(find.text('Сохранить изменения'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NewPostModal),
          matching: find.widgetWithText(TextField, 'Советы кинолога'),
        ),
        findsOneWidget,
      );

      // Edit title
      await tester.enterText(find.widgetWithText(TextField, 'Советы кинолога'), 'Обновленные советы кинолога');
      await tester.pump();

      // Submit
      await tester.tap(find.byKey(const ValueKey('submit_new_post_button')));
      await tester.pumpAndSettle();

      // Post updated
      expect(fakeService.updatePostCallCount, equals(1));
      expect(find.text('Обновленные советы кинолога'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('16. tapping delete opens confirmation dialog, confirming deletes post from feed and calls deletePost', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      expect(find.text('Советы кинолога'), findsOneWidget);

      // Open action sheet
      await tester.tap(find.byKey(const ValueKey('post_actions_button_post-1')));
      await tester.pumpAndSettle();

      // Tap Delete
      await tester.tap(find.text('Удалить запись'));
      await tester.pumpAndSettle();

      // Confirm dialog open
      expect(find.text('Удалить публикацию?'), findsOneWidget);
      final confirmBtn = find.byKey(const ValueKey('confirm_delete_post_button'));
      expect(confirmBtn, findsOneWidget);

      // Confirm delete
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Post deleted from feed
      expect(fakeService.deletePostCallCount, equals(1));
      expect(find.text('Советы кинолога'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('17. tapping "+ Ваша история" opens NewStoryModal, enters status and publishes new story', (tester) async {
      await tester.pumpWidget(createCommunityScreen());
      await tester.pumpAndSettle();

      // Stories bar renders "Ваша история" button
      expect(find.byKey(const ValueKey('add_story_button')), findsOneWidget);
      expect(find.text('Ваша история'), findsOneWidget);

      // Tap add story
      await tester.tap(find.byKey(const ValueKey('add_story_button')));
      await tester.pumpAndSettle();

      // NewStoryModal is shown
      expect(find.byType(NewStoryModal), findsOneWidget);
      expect(find.text('Новая история'), findsOneWidget);

      // Enter status description
      final statusField = find.widgetWithText(TextField, 'Статус выгула / Чем вы заняты');
      expect(statusField, findsOneWidget);
      await tester.enterText(statusField, 'Утренняя пробежка в Нарымском сквере 🐕');
      await tester.pump();

      // Submit story
      final submitButton = find.byKey(const ValueKey('submit_new_story_button'));
      expect(submitButton, findsOneWidget);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Service received createStory call
      expect(fakeService.createStoryCallCount, equals(1));
      expect(fakeService.createdStories.first.statusText, equals('Утренняя пробежка в Нарымском сквере 🐕'));

      // Modal closed
      expect(find.byType(NewStoryModal), findsNothing);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('18. admin user sees author switcher [Лично | PawConnect Team] in NewPostModal and NewStoryModal', (tester) async {
      final adminUser = UserAuthModel(
        id: 'admin-1',
        email: 'admin@pawconnect.app',
        name: 'Администратор Елена',
        role: 'admin',
      );

      await tester.pumpWidget(createCommunityScreen(currentUser: adminUser));
      await tester.pumpAndSettle();

      // 1. Check NewPostModal author switcher
      await tester.tap(find.byKey(const ValueKey('feed_add_post_button')));
      await tester.pumpAndSettle();

      expect(find.byType(NewPostModal), findsOneWidget);
      expect(find.text('Автор публикации'), findsOneWidget);
      expect(find.text('Администратор Елена'), findsOneWidget);
      final postModalTeam = find.descendant(
        of: find.byType(NewPostModal),
        matching: find.text('PawConnect Team'),
      );
      expect(postModalTeam, findsOneWidget);

      // Toggle to PawConnect Team
      await tester.tap(postModalTeam);
      await tester.pump();

      // Enter title and content
      await tester.enterText(find.widgetWithText(TextField, 'Заголовок записи...'), 'Официальный анонс');
      await tester.enterText(find.widgetWithText(TextField, 'Расскажите подробнее сообществу районов...'), 'Новые площадки в Новосибирске');
      await tester.pump();

      final submitPostBtn = find.byKey(const ValueKey('submit_new_post_button'));
      await tester.ensureVisible(submitPostBtn);
      await tester.tap(submitPostBtn);
      await tester.pumpAndSettle();

      expect(fakeService.createPostCallCount, equals(1));

      // 2. Check NewStoryModal author switcher
      await tester.tap(find.byKey(const ValueKey('add_story_button')));
      await tester.pumpAndSettle();

      expect(find.byType(NewStoryModal), findsOneWidget);
      expect(find.text('Автор истории'), findsOneWidget);
      expect(find.text('Администратор Елена'), findsOneWidget);
      final storyModalTeam = find.descendant(
        of: find.byType(NewStoryModal),
        matching: find.text('PawConnect Team'),
      );
      expect(storyModalTeam, findsOneWidget);

      // Switch to PawConnect Team
      await tester.tap(storyModalTeam);
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, 'Статус выгула / Чем вы заняты'), 'Совет кинолога дня');
      await tester.pump();

      final submitStoryBtn = find.byKey(const ValueKey('submit_new_story_button'));
      await tester.ensureVisible(submitStoryBtn);
      await tester.tap(submitStoryBtn);
      await tester.pumpAndSettle();

      expect(fakeService.createStoryCallCount, equals(1));
      expect(fakeService.createdStories.last.isOfficial, isTrue);
      expect(fakeService.createdStories.last.authorName, equals('PawConnect Team'));

      await tester.pump(const Duration(seconds: 3));
    });
  });
}
