import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/community/widgets/community_stories_bar.dart';
import 'package:pawconnect/features/community/widgets/heart_burst_overlay.dart';
import 'package:pawconnect/models/pet_story_model.dart';

void main() {
  group('HeartBurstOverlay Widget Tests', () {
    testWidgets('renders child widget and heart is initially hidden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeartBurstOverlay(
              child: const Text('Child Photo Content'),
            ),
          ),
        ),
      );

      expect(find.text('Child Photo Content'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    });

    testWidgets('triggers burst animation programmatically via triggerBurst()', (tester) async {
      final key = GlobalKey<HeartBurstOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeartBurstOverlay(
              key: key,
              child: Container(
                width: 300,
                height: 300,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_rounded), findsNothing);

      // Trigger burst programmatically
      key.currentState!.triggerBurst();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Heart should be rendered and visible
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      // Wait for animation to finish (~500ms)
      await tester.pump(const Duration(milliseconds: 600));

      // After completion and reset, heart icon is hidden again
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    });

    testWidgets('triggers burst and calls onDoubleTap on double tap', (tester) async {
      bool doubleTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeartBurstOverlay(
              onDoubleTap: () {
                doubleTapped = true;
              },
              child: const SizedBox(
                width: 200,
                height: 200,
                child: Text('Double Tap Target'),
              ),
            ),
          ),
        ),
      );

      expect(doubleTapped, isFalse);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);

      // Double tap on child
      await tester.tap(find.text('Double Tap Target'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Double Tap Target'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(doubleTapped, isTrue);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      // Let animation settle
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    });
  });

  group('CommunityStoriesBar Widget Tests', () {
    final testStories = [
      PetStoryModel(
        id: 'story-official',
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
        id: 'story-pet-active',
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
        id: 'story-pet-viewed',
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

    testWidgets('renders all story items and their labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityStoriesBar(
              stories: testStories,
            ),
          ),
        ),
      );

      // Official story label defaults to PawConnect when petName is null
      expect(find.text('PawConnect'), findsOneWidget);
      expect(find.text('Барсик'), findsOneWidget);
      expect(find.text('Рекс'), findsOneWidget);
    });

    testWidgets('displays verified badge for official stories only', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityStoriesBar(
              stories: testStories,
            ),
          ),
        ),
      );

      // Verified badge icon should appear only once (for story-official)
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('invokes onTapStory callback with story and index when story is tapped', (tester) async {
      PetStoryModel? tappedStory;
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommunityStoriesBar(
              stories: testStories,
              onTapStory: (story, index) {
                tappedStory = story;
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      // Tap second story ('Барсик')
      await tester.tap(find.text('Барсик'));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(1));
      expect(tappedStory?.id, equals('story-pet-active'));
      expect(tappedStory?.petName, equals('Барсик'));

      // Tap official story ('PawConnect')
      await tester.tap(find.text('PawConnect'));
      await tester.pumpAndSettle();

      expect(tappedIndex, equals(0));
      expect(tappedStory?.id, equals('story-official'));
      expect(tappedStory?.isOfficial, isTrue);
    });

    testWidgets('renders empty shrink widget when stories list is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommunityStoriesBar(
              stories: [],
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsNothing);
    });
  });
}
