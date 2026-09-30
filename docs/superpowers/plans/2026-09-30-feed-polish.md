# Instagram 2026 Community Feed Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Довести главную страницу Ленты (Tab 0 `/feed`) PawConnect до идеала Instagram 2026 Liquid Glass: истории «Сейчас гуляют» с полноэкранным плеером, карточки постов с double-tap лайком, интерактивная шторка комментариев, показательный контент от команды PawConnect и интеграция с FastAPI по правилам Zero-Stub.

**Architecture:** Модульный Liquid Glass движок в `lib/features/community/widgets/` с разделением ответственности: сториз-карусель и плеер, Instagram-карточки постов со строгим соблюдением бюджета производительности (без `BackdropFilter` внутри скролла), интерактивная шторка комментариев, чистые Dart-модели данных и реактивное управление состоянием через Riverpod `StateNotifier` с честным пробросом ошибок бэкенда.

**Tech Stack:** Flutter 3, Dart 3, Riverpod 2.5, Dio 5.5, FastAPI (Python 3.12), SQLAlchemy 2.0 (async), Pydantic v2.

**Spec:** [`docs/superpowers/specs/2026-09-30-feed-polish-production-design.md`](file:///Users/dmitryborona/.gemini/antigravity/worktrees/pawconnect_flutter/polish_main_feed/docs/superpowers/specs/2026-09-30-feed-polish-production-design.md)

## Global Constraints

- **Zero-Stub Policy**: Запрещено глотать ошибки сети через `catch (_) => mock`. Исключения пробрасываются в Riverpod (`AsyncError`), в UI обязательны честные экраны ошибок с кнопкой «Повторить» и скелетоны загрузки.
- **Apple Liquid Glass Budget**: Запрещено помещать `BackdropFilter` внутрь скроллящихся карточек ленты. Фон постов — `AppColors.obsidianCardTranslucent` с тонкими specular-бордюрами. Размытие разрешено только для верхней шапки, плавающего таббара и модальных шторок.
- **No Code Generation**: Строго plain Dart модели с ручными `fromJson`, `toJson` и `copyWith`. Никакого `build_runner` или `freezed`.
- **Navigation**: `/feed` — Tab 0 (Главный экран).
- **Icons**: Использовать только стандартные Flutter `Icons` или `cupertino_icons`. Никакого `lucide_icons`.

---

### Task 1: Data Models Extension (Dart)

**Files:**
- Modify: `lib/models/community_post_model.dart`
- Create: `lib/models/pet_story_model.dart`
- Create: `lib/models/post_comment_model.dart`
- Create: `test/models/community_models_test.dart`

**Interfaces:**
- Produces: `CommunityPostModel` with `isOfficial`, `petName`, `commentsCount`, `isBookmarked`
- Produces: `PetStoryModel` (`id`, `authorName`, `isOfficial`, `authorAvatar`, `petName`, `district`, `mediaUrl`, `statusText`, `createdAt`, `isViewed`)
- Produces: `PostCommentModel` (`id`, `postId`, `authorName`, `authorAvatar`, `isOfficial`, `text`, `createdAt`, `likesCount`, `isLiked`)

- [ ] **Step 1: Write the failing test for models**

```dart
// test/models/community_models_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest` or Dart test command. Expected: Compilation failure due to missing `PetStoryModel`, `PostCommentModel`, and missing fields in `CommunityPostModel`.

- [ ] **Step 3: Implement `PetStoryModel`, `PostCommentModel`, and update `CommunityPostModel`**

Create `lib/models/pet_story_model.dart`:
```dart
class PetStoryModel {
  final String id;
  final String authorName;
  final bool isOfficial;
  final String? authorAvatar;
  final String? petName;
  final String district;
  final String mediaUrl;
  final String statusText;
  final DateTime createdAt;
  final bool isViewed;

  PetStoryModel({
    required this.id,
    required this.authorName,
    this.isOfficial = false,
    this.authorAvatar,
    this.petName,
    required this.district,
    required this.mediaUrl,
    required this.statusText,
    required this.createdAt,
    this.isViewed = false,
  });

  factory PetStoryModel.fromJson(Map<String, dynamic> json) {
    return PetStoryModel(
      id: json['id'] ?? '',
      authorName: json['authorName'] ?? 'Аноним',
      isOfficial: json['isOfficial'] ?? false,
      authorAvatar: json['authorAvatar'],
      petName: json['petName'],
      district: json['district'] ?? 'Центральный',
      mediaUrl: json['mediaUrl'] ?? '',
      statusText: json['statusText'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isViewed: json['isViewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'isOfficial': isOfficial,
        'authorAvatar': authorAvatar,
        'petName': petName,
        'district': district,
        'mediaUrl': mediaUrl,
        'statusText': statusText,
        'createdAt': createdAt.toIso8601String(),
        'isViewed': isViewed,
      };

  PetStoryModel copyWith({
    String? id,
    String? authorName,
    bool? isOfficial,
    String? authorAvatar,
    String? petName,
    String? district,
    String? mediaUrl,
    String? statusText,
    DateTime? createdAt,
    bool? isViewed,
  }) {
    return PetStoryModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      isOfficial: isOfficial ?? this.isOfficial,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      petName: petName ?? this.petName,
      district: district ?? this.district,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      statusText: statusText ?? this.statusText,
      createdAt: createdAt ?? this.createdAt,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
```

Create `lib/models/post_comment_model.dart`:
```dart
class PostCommentModel {
  final String id;
  final String postId;
  final String authorName;
  final String? authorAvatar;
  final bool isOfficial;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    this.authorAvatar,
    this.isOfficial = false,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      authorName: json['authorName'] ?? 'Аноним',
      authorAvatar: json['authorAvatar'],
      isOfficial: json['isOfficial'] ?? false,
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'isOfficial': isOfficial,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'likesCount': likesCount,
        'isLiked': isLiked,
      };

  PostCommentModel copyWith({
    String? id,
    String? postId,
    String? authorName,
    String? authorAvatar,
    bool? isOfficial,
    String? text,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
  }) {
    return PostCommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      isOfficial: isOfficial ?? this.isOfficial,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
```

Update `lib/models/community_post_model.dart` with new fields (`isOfficial`, `petName`, `commentsCount`, `isBookmarked`).

- [ ] **Step 4: Verify tests pass**
- [ ] **Step 5: Commit**

```bash
git add lib/models/ test/models/
git commit -m "feat(models): add PetStoryModel, PostCommentModel and extend CommunityPostModel"
```

---

### Task 2: Backend FastAPI Endpoints & Official Showcase Content (Python)

**Files:**
- Modify: `server/app/api/v1/endpoints/posts.py`
- Modify: `server/app/schemas/post.py`
- Modify: `server/tests/test_posts.py`

**Interfaces:**
- Consumes: FastAPI DB session, `current_user`
- Produces: `GET /api/v1/community/stories`, `GET /api/v1/community/posts/{post_id}/comments`, `POST /api/v1/community/posts/{post_id}/comments`

- [ ] **Step 1: Write backend tests for stories, comments, and official posts**

In `server/tests/test_posts.py`, add tests for `GET /api/v1/community/stories` and comments endpoints.
Verify 200 response and presence of official PawConnect showcase stories.

- [ ] **Step 2: Run pytest to verify tests fail**

Run: `pytest server/tests/test_posts.py -v`  
Expected: 404 or missing routes.

- [ ] **Step 3: Implement endpoints and schemas**

1. In `server/app/schemas/post.py`: add `StoryResponse`, `CommentCreate`, `CommentResponse`.
2. In `server/app/api/v1/endpoints/posts.py`:
   - Endpoint `GET /stories`: returns seeded showcase stories (PawConnect Official Tips + Active Pets).
   - Endpoint `GET /{post_id}/comments`: returns comments for post.
   - Endpoint `POST /{post_id}/comments`: adds comment from `current_user`.
   - Update `get_posts` to include official PawConnect showcase posts (e.g., guide on safe zone setup with verified badge).

- [ ] **Step 4: Run pytest to verify all pass**

Run: `pytest server/tests/test_posts.py -v`  
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat(api): add stories and comments endpoints with official showcase content"
```

---

### Task 3: CommunityService & CommunityNotifier (Dart & Riverpod)

**Files:**
- Modify: `lib/services/community_service.dart`
- Modify: `lib/providers/community_provider.dart`
- Modify: `test/providers/community_provider_test.dart`

**Interfaces:**
- Consumes: `CommunityService`, `PetStoryModel`, `CommunityPostModel`, `PostCommentModel`
- Produces: `CommunityNotifier` with `postsAsync`, `storiesAsync`, `loadFeed()`, `toggleLike()`, `toggleBookmark()`, `addComment()`, `markStoryViewed()`

- [ ] **Step 1: Write provider unit tests**

Test state transitions:
1. `loadFeed()` sets `postsAsync` and `storiesAsync` to data.
2. Network failure without `USE_MOCKS=true` results in `AsyncError`.
3. `toggleLike(postId)` optimistically toggles like and updates count.
4. `toggleBookmark(postId)` adds/removes from `bookmarkedPostIds`.
5. `addComment(postId, text)` prepends comment and increments `commentsCount`.

- [ ] **Step 2: Run tests to verify failure**
- [ ] **Step 3: Implement `CommunityService` and `CommunityNotifier`**

In `lib/services/community_service.dart`:
- Add `getStories()` method calling `/community/stories`.
- Add `getComments(String postId)` and `addComment(String postId, String text)`.
- Adhere strictly to Zero-Stub: rethrow Dio exceptions unless `AppConfig.enableOfflineMocks` is true.
- Provide curated fallback lists for both stories and posts when `enableOfflineMocks` is active.

In `lib/providers/community_provider.dart`:
- Update `CommunityState` to store `AsyncValue<List<CommunityPostModel>> postsAsync`, `AsyncValue<List<PetStoryModel>> storiesAsync`, bookmarks, comments map.
- Implement methods in `CommunityNotifier`.

- [ ] **Step 4: Verify tests pass**
- [ ] **Step 5: Commit**

```bash
git add lib/services/community_service.dart lib/providers/community_provider.dart test/
git commit -m "feat(community): implement stories and comments in service and Riverpod state"
```

---

### Task 4: Interactive Micro-Widgets (HeartBurstOverlay & Stories Rail)

**Files:**
- Create: `lib/features/community/widgets/heart_burst_overlay.dart`
- Create: `lib/features/community/widgets/community_stories_bar.dart`
- Create: `test/features/community/widgets/stories_bar_test.dart`

**Interfaces:**
- Produces: `HeartBurstOverlay` widget with double-tap burst animation.
- Produces: `CommunityStoriesBar` widget accepting `List<PetStoryModel>` and `onTapStory(story, index)`.

- [ ] **Step 1: Write widget tests for HeartBurstOverlay and StoriesBar**

Test:
1. `HeartBurstOverlay` renders child and triggers pop animation when `triggerBurst()` is called.
2. `CommunityStoriesBar` renders avatars, displays verified badge for official stories, and invokes `onTapStory`.

- [ ] **Step 2: Verify tests fail**
- [ ] **Step 3: Implement widgets**

1. `heart_burst_overlay.dart`:
   - `StatefulWidget` with `AnimationController` and `CurvedAnimation(curve: Curves.elasticOut)`.
   - Scale from 0.0 to 1.3, then fade out.
   - Standard red/white heart icon centered over image.
2. `community_stories_bar.dart`:
   - Horizontal `ListView.separated`.
   - Story item: avatar in gradient border ring (Azure-Green for official PawConnect, Orange-Coral for walking pets, Gray for viewed).
   - Label: Pet name or "PawConnect" below avatar.
   - Official badge indicator.

- [ ] **Step 4: Verify tests pass**
- [ ] **Step 5: Commit**

```bash
git add lib/features/community/widgets/ test/features/community/
git commit -m "feat(community): add HeartBurstOverlay and CommunityStoriesBar widgets"
```

---

### Task 5: Fullscreen Story Player (`StoryPlayerScreen`)

**Files:**
- Create: `lib/features/community/widgets/story_player_screen.dart`
- Create: `test/features/community/widgets/story_player_test.dart`

**Interfaces:**
- Consumes: `List<PetStoryModel>`, initialIndex, `onStoryViewed(storyId)`
- Produces: Modal fullscreen route with story progress bars, touch navigation, and swipe down to close.

- [ ] **Step 1: Write widget test for StoryPlayerScreen**

Test:
1. Renders progress bars matching stories length.
2. Displays author name, district, status text, and story image.
3. Tap on right advances to next story. Tap on left goes to previous story.
4. Close button pops the screen.

- [ ] **Step 2: Verify test fails**
- [ ] **Step 3: Implement `StoryPlayerScreen`**

- Segmented top progress indicators (5 seconds per story).
- `GestureDetector`: onTapUp left (prev) / right (next), onLongPressDown (pause timer), onLongPressUp (resume timer), onVerticalDragEnd (dismiss if downward velocity > 300).
- Top header: author avatar, name, verified badge if `isOfficial`, district chip, close button.
- Bottom overlay: status chip («Гуляет 25 мин в Нарымском сквере» или официальный совет).

- [ ] **Step 4: Verify test passes**
- [ ] **Step 5: Commit**

```bash
git add lib/features/community/widgets/story_player_screen.dart test/
git commit -m "feat(community): implement fullscreen Instagram-style StoryPlayerScreen"
```

---

### Task 6: Instagram Liquid Glass Post Card (`CommunityPostCard`)

**Files:**
- Create: `lib/features/community/widgets/community_post_card.dart`
- Create: `test/features/community/widgets/community_post_card_test.dart`

**Interfaces:**
- Consumes: `CommunityPostModel`, callbacks `onLike`, `onComment`, `onBookmark`, `onShare`
- Produces: Card widget complying with Apple Liquid Glass performance rules (NO `BackdropFilter` inside card).

- [ ] **Step 1: Write widget test for `CommunityPostCard`**

Test:
1. Renders author, district badge, category badge.
2. Verified badge displays when `post.isOfficial == true`.
3. Double-tap on image triggers `onLike`.
4. Tap on comment icon and comment preview triggers `onComment`.
5. Tap on bookmark triggers `onBookmark`.

- [ ] **Step 2: Verify test fails**
- [ ] **Step 3: Implement `CommunityPostCard`**

- Outer container: `AppColors.obsidianCardTranslucent` with `Border.all(color: Colors.white10)`. No `BackdropFilter`!
- Header: `PawAvatar`, author name, official badge, district pill, category tag (SOS has red accent, Health green, Training blue).
- Media: `AspectRatio(aspectRatio: 4 / 5)` or `1 / 1` wrapped in `HeartBurstOverlay` with double-tap gesture.
- Action Bar: `HeartPopButton(isLiked, likesCount, onTap)`, comment button with counter, share icon, bookmark icon.
- Content: Post title, expandable content text with "ещё..." / "скрыть".
- Comment preview line: "Посмотреть все N комментариев" with soft text styling.

- [ ] **Step 4: Verify test passes**
- [ ] **Step 5: Commit**

```bash
git add lib/features/community/widgets/community_post_card.dart test/
git commit -m "feat(community): implement Instagram Liquid Glass CommunityPostCard"
```

---

### Task 7: Interactive Comments Bottom Sheet (`CommentsBottomSheet`)

**Files:**
- Create: `lib/features/community/widgets/comments_bottom_sheet.dart`
- Create: `test/features/community/widgets/comments_bottom_sheet_test.dart`

**Interfaces:**
- Consumes: `postId`, `List<PostCommentModel>`, `onAddComment(text)`
- Produces: Modal bottom sheet with scrollable comments list and glass input bar.

- [ ] **Step 1: Write widget test for `CommentsBottomSheet`**

Test:
1. Displays list of comments with author names and text.
2. Official comments from PawConnect Team show verified badge.
3. Typing text and pressing send triggers `onAddComment` and clears field.

- [ ] **Step 2: Verify test fails**
- [ ] **Step 3: Implement `CommentsBottomSheet`**

- Draggable scrollable sheet with top drag handle.
- Header: "Комментарии (N)" + close icon.
- List: `ListView.builder` of comments with avatar, author, time ago, text.
- Footer input: Glass text field with send icon button.

- [ ] **Step 4: Verify test passes**
- [ ] **Step 5: Commit**

```bash
git add lib/features/community/widgets/comments_bottom_sheet.dart test/
git commit -m "feat(community): implement interactive CommentsBottomSheet"
```

---

### Task 8: Assemble Polished Feed Screen (`CommunityScreen`) & Quality Gates

**Files:**
- Modify: `lib/features/community/community_screen.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: All widgets from Tasks 1-7
- Produces: Complete Tab 0 `/feed` screen with pull-to-refresh, skeleton states, district filters, stories rail, post stream, and zero-stub error handling.

- [ ] **Step 1: Update `community_screen.dart`**

1. Top bar: Sticky glass header with app title ("PawConnect Лента"), create post action button.
2. District filter capsules (10 districts of Novosibirsk) + category pills.
3. Stories rail (`CommunityStoriesBar`) connected to `StoryPlayerScreen`.
4. Main post feed (`CommunityPostCard` items).
5. State handling:
   - `when(data: ...)` renders posts list with `RefreshIndicator`.
   - `when(loading: ...)` renders shimmering card skeletons.
   - `when(error: ...)` renders genuine Liquid Glass error view with "Не удалось загрузить ленту" and "Повторить попытку" button.
6. Opening `CommentsBottomSheet` when tapping comments.

- [ ] **Step 2: Run all tests and verify**

1. Run backend tests: `pytest server/tests/` (all must pass).
2. Run widget tests: verify `widget_test.dart` and community screen tests pass.
3. Verify static analysis has zero warnings.

- [ ] **Step 3: Commit and Finalize**

```bash
git add lib/features/community/community_screen.dart test/
git commit -m "feat(feed): polish Tab 0 community feed to Instagram Liquid Glass perfection"
```
