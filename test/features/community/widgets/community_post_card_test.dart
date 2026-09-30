import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/community/widgets/community_post_card.dart';
import 'package:pawconnect/features/community/widgets/heart_pop_button.dart';
import 'package:pawconnect/features/community/widgets/heart_burst_overlay.dart';
import 'package:pawconnect/models/community_post_model.dart';

void main() {
  CommunityPostModel createTestPost({
    String id = 'post-1',
    String authorName = 'Елена В.',
    bool isOfficial = false,
    String? authorAvatar,
    String? petName,
    String district = 'Заельцовский',
    String category = 'sos',
    String title = 'Потерялся бигль',
    String content = 'Короткий текст описания',
    int likesCount = 10,
    bool isLiked = false,
    int commentsCount = 5,
    bool isBookmarked = false,
    DateTime? createdAt,
    String? imageUrl = 'https://images.unsplash.com/photo-dog',
  }) {
    return CommunityPostModel(
      id: id,
      authorName: authorName,
      isOfficial: isOfficial,
      authorAvatar: authorAvatar,
      petName: petName,
      district: district,
      category: category,
      title: title,
      content: content,
      likesCount: likesCount,
      isLiked: isLiked,
      commentsCount: commentsCount,
      isBookmarked: isBookmarked,
      createdAt: createdAt ?? DateTime.now().subtract(const Duration(minutes: 15)),
      imageUrl: imageUrl,
    );
  }

  Widget buildCardWidget({
    required CommunityPostModel post,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onBookmark,
    VoidCallback? onShare,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 380,
              child: CommunityPostCard(
                post: post,
                onLike: onLike ?? () {},
                onComment: onComment ?? () {},
                onBookmark: onBookmark ?? () {},
                onShare: onShare ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('CommunityPostCard Widget Tests', () {
    testWidgets('renders author, district, and category badges correctly', (tester) async {
      setupScreenSize(tester);
      final post = createTestPost(
        authorName: 'Анна К.',
        district: 'Центральный',
        category: 'health',
        title: 'Совет ветеринара',
      );

      await tester.pumpWidget(buildCardWidget(post: post));

      expect(find.text('Анна К.'), findsOneWidget);
      expect(find.text('Центральный'), findsOneWidget);
      expect(find.text('Здоровье'), findsOneWidget);
      expect(find.text('Совет ветеринара'), findsOneWidget);
    });

    testWidgets('renders SOS category badge with alert icon and accent', (tester) async {
      setupScreenSize(tester);
      final post = createTestPost(category: 'sos');
      await tester.pumpWidget(buildCardWidget(post: post));

      expect(find.text('SOS'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('displays verified badge for official posts only', (tester) async {
      setupScreenSize(tester);
      final officialPost = createTestPost(isOfficial: true);
      await tester.pumpWidget(buildCardWidget(post: officialPost));
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);

      final regularPost = createTestPost(isOfficial: false);
      await tester.pumpWidget(buildCardWidget(post: regularPost));
      expect(find.byIcon(Icons.verified_rounded), findsNothing);
    });

    testWidgets('displays pet tag when petName is provided and omits when null', (tester) async {
      setupScreenSize(tester);
      final postWithPet = createTestPost(petName: 'Джеки (Бигль)');
      await tester.pumpWidget(buildCardWidget(post: postWithPet));
      expect(find.text('🐾 Джеки (Бигль)'), findsOneWidget);

      final postWithoutPet = createTestPost(petName: null);
      await tester.pumpWidget(buildCardWidget(post: postWithoutPet));
      expect(find.textContaining('🐾'), findsNothing);
    });

    testWidgets('double-tap on photo triggers onLike callback and fires heart burst', (tester) async {
      setupScreenSize(tester);
      bool liked = false;
      final post = createTestPost(
        imageUrl: 'https://images.unsplash.com/photo-sample',
      );

      await tester.pumpWidget(buildCardWidget(
        post: post,
        onLike: () {
          liked = true;
        },
      ));

      expect(find.byType(HeartBurstOverlay), findsOneWidget);

      // Double-tap on image overlay
      await tester.tap(find.byType(HeartBurstOverlay));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(HeartBurstOverlay));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(liked, isTrue);

      // Let animation and gesture timers settle
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('tapping HeartPopButton invokes onLike callback', (tester) async {
      setupScreenSize(tester);
      bool liked = false;
      final post = createTestPost(likesCount: 12, isLiked: false);

      await tester.pumpWidget(buildCardWidget(
        post: post,
        onLike: () {
          liked = true;
        },
      ));

      await tester.tap(find.byType(HeartPopButton));
      await tester.pump();

      expect(liked, isTrue);
    });

    testWidgets('tapping comment button and preview line invokes onComment callback', (tester) async {
      setupScreenSize(tester);
      int commentTapCount = 0;
      final post = createTestPost(commentsCount: 7);

      await tester.pumpWidget(buildCardWidget(
        post: post,
        onComment: () {
          commentTapCount++;
        },
      ));

      // Tap comment button in action bar
      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      await tester.pump();
      expect(commentTapCount, equals(1));

      // Tap comment preview line
      await tester.tap(find.text('Посмотреть все 7 комментариев'));
      await tester.pump();
      expect(commentTapCount, equals(2));
    });

    testWidgets('shows "Написать первый комментарий" when commentsCount is 0 and invokes onComment', (tester) async {
      setupScreenSize(tester);
      bool commentTapped = false;
      final post = createTestPost(commentsCount: 0);

      await tester.pumpWidget(buildCardWidget(
        post: post,
        onComment: () {
          commentTapped = true;
        },
      ));

      expect(find.text('Написать первый комментарий'), findsOneWidget);
      await tester.tap(find.text('Написать первый комментарий'));
      await tester.pump();
      expect(commentTapped, isTrue);
    });

    testWidgets('tapping bookmark button invokes onBookmark and shows correct icon', (tester) async {
      setupScreenSize(tester);
      bool bookmarkTapped = false;
      final unbookmarkedPost = createTestPost(isBookmarked: false);

      await tester.pumpWidget(buildCardWidget(
        post: unbookmarkedPost,
        onBookmark: () {
          bookmarkTapped = true;
        },
      ));

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
      await tester.pump();
      expect(bookmarkTapped, isTrue);

      final bookmarkedPost = createTestPost(isBookmarked: true);
      await tester.pumpWidget(buildCardWidget(post: bookmarkedPost));
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    });

    testWidgets('tapping share button invokes onShare callback', (tester) async {
      setupScreenSize(tester);
      bool shareTapped = false;
      final post = createTestPost();

      await tester.pumpWidget(buildCardWidget(
        post: post,
        onShare: () {
          shareTapped = true;
        },
      ));

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.pump();
      expect(shareTapped, isTrue);
    });

    testWidgets('expands and collapses long content (> 120 chars)', (tester) async {
      setupScreenSize(tester);
      const longContent =
          'Команда PawConnect подготовила подробный гид по настройке GPS-ошейника и безопасных зон выгула в Новосибирске. Задайте радиус безопасной зоны от 50 до 500 метров в карточке питомца. При выходе за границу вы мгновенно получите пуш-уведомление и сигнал тревоги!';

      final post = createTestPost(content: longContent);
      await tester.pumpWidget(buildCardWidget(post: post));

      // Initially shows truncated text with "ещё..."
      expect(find.text('ещё...'), findsOneWidget);
      expect(find.text('скрыть'), findsNothing);

      // Tap "ещё..." to expand
      await tester.tap(find.text('ещё...'));
      await tester.pumpAndSettle();

      expect(find.text('скрыть'), findsOneWidget);
      expect(find.text('ещё...'), findsNothing);
      expect(find.text(longContent), findsOneWidget);

      // Tap "скрыть" to collapse
      await tester.tap(find.text('скрыть'));
      await tester.pumpAndSettle();

      expect(find.text('ещё...'), findsOneWidget);
      expect(find.text('скрыть'), findsNothing);
    });

    testWidgets('short content (<= 120 chars) does not show expand or collapse buttons', (tester) async {
      setupScreenSize(tester);
      const shortContent = 'Короткий текст о прогулке с собакой.';
      final post = createTestPost(content: shortContent);

      await tester.pumpWidget(buildCardWidget(post: post));

      expect(find.text(shortContent), findsOneWidget);
      expect(find.text('ещё...'), findsNothing);
      expect(find.text('скрыть'), findsNothing);
    });

    testWidgets('strict zero jank: no BackdropFilter inside CommunityPostCard', (tester) async {
      setupScreenSize(tester);
      final post = createTestPost();
      await tester.pumpWidget(buildCardWidget(post: post));

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}
