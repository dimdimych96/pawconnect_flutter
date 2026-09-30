import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect/features/community/widgets/comments_bottom_sheet.dart';
import 'package:pawconnect/models/post_comment_model.dart';

void main() {
  final sampleComments = [
    PostCommentModel(
      id: 'c1',
      postId: 'post-100',
      authorName: 'PawConnect Team',
      isOfficial: true,
      authorAvatar: 'https://images.unsplash.com/team-avatar',
      text: 'Официальный комментарий: волонтёры уже на месте!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      likesCount: 12,
      isLiked: true,
    ),
    PostCommentModel(
      id: 'c2',
      postId: 'post-100',
      authorName: 'Анна К.',
      isOfficial: false,
      authorAvatar: null,
      text: 'Спасибо за оперативную помощь!',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likesCount: 3,
      isLiked: false,
    ),
  ];

  Widget buildSheetWidget({
    String postId = 'post-100',
    List<PostCommentModel>? comments,
    Future<void> Function(String)? onAddComment,
    VoidCallback? onClose,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CommentsBottomSheet(
          postId: postId,
          comments: comments ?? sampleComments,
          onAddComment: onAddComment ?? (_) async {},
          onClose: onClose,
        ),
      ),
    );
  }

  group('CommentsBottomSheet', () {
    testWidgets('displays header with comment count and close button', (tester) async {
      await tester.pumpWidget(
        buildSheetWidget(comments: sampleComments),
      );
      await tester.pumpAndSettle();

      expect(find.text('Комментарии (2)'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('displays friendly empty state when comments list is empty', (tester) async {
      await tester.pumpWidget(
        buildSheetWidget(comments: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('Комментарии (0)'), findsOneWidget);
      expect(find.text('Пока нет комментариев. Будьте первыми!'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    });

    testWidgets('displays list of comments with author, text, and relative time', (tester) async {
      await tester.pumpWidget(
        buildSheetWidget(comments: sampleComments),
      );
      await tester.pumpAndSettle();

      expect(find.text('PawConnect Team'), findsOneWidget);
      expect(find.text('Официальный комментарий: волонтёры уже на месте!'), findsOneWidget);
      expect(find.text('5 мин назад'), findsOneWidget);

      expect(find.text('Анна К.'), findsOneWidget);
      expect(find.text('Спасибо за оперативную помощь!'), findsOneWidget);
      expect(find.text('2 ч назад'), findsOneWidget);
    });

    testWidgets('displays verified badge for official comments and omits for regular comments', (tester) async {
      await tester.pumpWidget(
        buildSheetWidget(comments: sampleComments),
      );
      await tester.pumpAndSettle();

      // Only 1 official comment in sampleComments -> exactly 1 verified badge
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    });

    testWidgets('tapping close button invokes onClose callback', (tester) async {
      bool closed = false;
      await tester.pumpWidget(
        buildSheetWidget(
          comments: sampleComments,
          onClose: () => closed = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });

    testWidgets('typing text and tapping send button triggers onAddComment and clears text field', (tester) async {
      String? submittedText;
      await tester.pumpWidget(
        buildSheetWidget(
          comments: sampleComments,
          onAddComment: (text) async {
            submittedText = text;
          },
        ),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      expect(find.text('Напишите комментарий...'), findsOneWidget);

      await tester.enterText(inputFinder, '  Держим кулачки за пушистика!  ');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(submittedText, 'Держим кулачки за пушистика!');

      final textField = tester.widget<TextField>(inputFinder);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('tapping send with empty or whitespace-only text does not trigger onAddComment', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        buildSheetWidget(
          comments: sampleComments,
          onAddComment: (text) async {
            called = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, '    ');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('submitting via keyboard onSubmitted triggers onAddComment and clears field', (tester) async {
      String? submittedText;
      await tester.pumpWidget(
        buildSheetWidget(
          comments: sampleComments,
          onAddComment: (text) async {
            submittedText = text;
          },
        ),
      );
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);
      await tester.enterText(inputFinder, 'Отличные новости');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(submittedText, 'Отличные новости');
      final textField = tester.widget<TextField>(inputFinder);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('renders top drag handle and BackdropFilter for liquid glass modal style', (tester) async {
      await tester.pumpWidget(
        buildSheetWidget(comments: sampleComments),
      );
      await tester.pumpAndSettle();

      // Top drag handle container (36x4 pill in Colors.white24)
      final handleFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.constraints?.hasBoundedWidth == true) {
          final decoration = widget.decoration;
          if (decoration is BoxDecoration &&
              decoration.color == Colors.white24 &&
              widget.constraints?.maxWidth == 36 &&
              widget.constraints?.maxHeight == 4) {
            return true;
          }
        }
        return false;
      });
      expect(handleFinder, findsOneWidget);

      // Liquid glass modal overlay permits BackdropFilter
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('CommentsBottomSheet.show opens modal and can be closed via close icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    CommentsBottomSheet.show(
                      context,
                      postId: 'post-100',
                      comments: sampleComments,
                      onAddComment: (_) async {},
                    );
                  },
                  child: const Text('Open Comments'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Комментарии (2)'), findsNothing);

      await tester.tap(find.text('Open Comments'));
      await tester.pumpAndSettle();

      expect(find.text('Комментарии (2)'), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Комментарии (2)'), findsNothing);
    });
  });
}
