import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/community/widgets/story_player_screen.dart';
import 'package:pawconnect/models/pet_story_model.dart';

void main() {
  final testStories = [
    PetStoryModel(
      id: 'story-1',
      authorName: 'PawConnect Team',
      isOfficial: true,
      authorAvatar: null,
      petName: null,
      district: 'Центральный',
      mediaUrl: 'https://images.unsplash.com/photo-official',
      statusText: 'Новое обновление сервиса!',
      createdAt: DateTime.now(),
      isViewed: false,
    ),
    PetStoryModel(
      id: 'story-2',
      authorName: 'Екатерина',
      isOfficial: false,
      authorAvatar: null,
      petName: 'Барсик',
      district: 'Заельцовский',
      mediaUrl: 'https://images.unsplash.com/photo-barsik',
      statusText: 'Гуляем в Тимирязевском сквере 🐾',
      createdAt: DateTime.now(),
      isViewed: false,
    ),
    PetStoryModel(
      id: 'story-3',
      authorName: 'Алексей',
      isOfficial: false,
      authorAvatar: null,
      petName: 'Рекс',
      district: 'Ленинский',
      mediaUrl: 'https://images.unsplash.com/photo-reks',
      statusText: 'Утренняя пробежка завершена',
      createdAt: DateTime.now(),
      isViewed: true,
    ),
  ];

  Widget buildTestWidget({
    List<PetStoryModel>? stories,
    int initialIndex = 0,
    ValueChanged<String>? onStoryViewed,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoryPlayerScreen(
                      stories: stories ?? testStories,
                      initialIndex: initialIndex,
                      onStoryViewed: onStoryViewed,
                    ),
                  ),
                );
              },
              child: const Text('Open Stories'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openStoryPlayer(WidgetTester tester) async {
    await tester.tap(find.text('Open Stories'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  group('StoryPlayerScreen Widget Tests', () {
    testWidgets('renders progress bars matching stories length', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await openStoryPlayer(tester);

      expect(find.byType(StoryPlayerScreen), findsOneWidget);
      // Segmented progress bars for 3 stories
      expect(find.byKey(const ValueKey('story_progress_bar_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('story_progress_bar_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('story_progress_bar_2')), findsOneWidget);
    });

    testWidgets('displays author name, district, status text, and verified badge for official story',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await openStoryPlayer(tester);

      expect(find.text('PawConnect Team'), findsOneWidget);
      expect(find.text('Центральный'), findsOneWidget);
      expect(find.text('Новое обновление сервиса!'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('tap on right advances to next story and updates UI', (tester) async {
      final viewedStoryIds = <String>[];

      await tester.pumpWidget(buildTestWidget(
        onStoryViewed: (id) => viewedStoryIds.add(id),
      ));
      await openStoryPlayer(tester);

      expect(viewedStoryIds, contains('story-1'));
      expect(find.text('PawConnect Team'), findsOneWidget);

      // Tap on right side of screen (e.g. x = 650 in 800-wide test window)
      await tester.tapAt(const Offset(650, 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Екатерина'), findsOneWidget);
      expect(find.text('Барсик'), findsOneWidget);
      expect(find.text('Заельцовский'), findsOneWidget);
      expect(find.text('Гуляем в Тимирязевском сквере 🐾'), findsOneWidget);
      expect(viewedStoryIds, contains('story-2'));
    });

    testWidgets('tap on left navigates back to previous story', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialIndex: 1));
      await openStoryPlayer(tester);

      // Starts at index 1: Екатерина
      expect(find.text('Екатерина'), findsOneWidget);

      // Tap left third (e.g. x = 100 in 800-wide test window)
      await tester.tapAt(const Offset(100, 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Goes back to story-1: PawConnect Team
      expect(find.text('PawConnect Team'), findsOneWidget);
    });

    testWidgets('close button pops the screen', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await openStoryPlayer(tester);

      expect(find.byType(StoryPlayerScreen), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(StoryPlayerScreen), findsNothing);
      expect(find.text('Open Stories'), findsOneWidget);
    });

    testWidgets('automatically advances after 5 seconds', (tester) async {
      final viewedStoryIds = <String>[];

      await tester.pumpWidget(buildTestWidget(
        onStoryViewed: (id) => viewedStoryIds.add(id),
      ));
      await openStoryPlayer(tester);

      expect(find.text('PawConnect Team'), findsOneWidget);

      // Fast-forward 5 seconds
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 100));

      // Now should show second story: Екатерина
      expect(find.text('Екатерина'), findsOneWidget);
      expect(viewedStoryIds, contains('story-2'));
    });

    testWidgets('swiping down dismisses the story player', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await openStoryPlayer(tester);

      expect(find.byType(StoryPlayerScreen), findsOneWidget);

      // Drag down by 300 pixels
      await tester.drag(find.byType(StoryPlayerScreen), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.byType(StoryPlayerScreen), findsNothing);
      expect(find.text('Open Stories'), findsOneWidget);
    });

    testWidgets('tap on right on last story dismisses the screen', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialIndex: 2));
      await openStoryPlayer(tester);

      expect(find.text('Алексей'), findsOneWidget);

      // Tap right side on last story
      await tester.tapAt(const Offset(650, 400));
      await tester.pumpAndSettle();

      expect(find.byType(StoryPlayerScreen), findsNothing);
    });

    testWidgets('tap on left on first story stays on first story', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialIndex: 0));
      await openStoryPlayer(tester);

      expect(find.text('PawConnect Team'), findsOneWidget);

      // Tap left side on first story
      await tester.tapAt(const Offset(100, 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('PawConnect Team'), findsOneWidget);
    });

    testWidgets('renders empty fallback when stories list is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(stories: []));
      await openStoryPlayer(tester);

      expect(find.text('Нет историй'), findsOneWidget);
    });

    testWidgets('long press pauses timer and release resumes', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await openStoryPlayer(tester);

      expect(find.text('PawConnect Team'), findsOneWidget);

      // Start long press
      final gesture = await tester.startGesture(const Offset(400, 400));
      await tester.pump(const Duration(milliseconds: 600));

      // Advance by 6 seconds while holding press
      await tester.pump(const Duration(seconds: 6));

      // Should still be on the first story because timer was paused
      expect(find.text('PawConnect Team'), findsOneWidget);

      // Release gesture
      await gesture.up();
      await tester.pump();

      // Now fast forward 5 seconds after release
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 100));

      // Advanced to second story
      expect(find.text('Екатерина'), findsOneWidget);
    });
  });
}
