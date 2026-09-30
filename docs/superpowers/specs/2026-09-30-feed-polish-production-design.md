# Спецификация и Архитектура: Instagram 2026 Community Feed (Production)

**Дата**: 30 сентября 2026 г.  
**Статус**: Утверждено  
**Фича**: Доведение главной ленты (Tab 0 `/feed`) до идеала: Instagram Liquid Glass, Stories «Сейчас гуляют», официальный контент от приложения, интерактивные комментарии и Zero-Stub интеграция.

---

## 1. Цели и Контекст

Главная страница приложения PawConnect — **Лента Сообщества** (`Tab 0`, `/feed`) — является центральной точкой вовлечения владельцев питомцев.  
Цель доработки — реализовать премиальный пользовательский опыт уровня Instagram / Threads 2026 года в стилистике **Apple Liquid Glass**, интегрированный с реальным FastAPI-бэкендом при строгом соблюдении Zero-Stub политики.

### Ключевые требования:
1. **Stories Rail («Сейчас гуляют»)**:
   - Горизонтальная лента историй с градиентными кольцами активности.
   - Официальные обучающие и сервисные сториз от команды PawConnect (верифицированный аккаунт).
   - Пользовательские сториз активных питомцев на прогулке с указанием района Новосибирска и таймера выгула.
   - Полноэкранный сториз-плеер (`StoryPlayerScreen`) с прогресс-баром, паузой по удержанию, тапами вперед/назад и свайпом вниз для закрытия.
2. **Instagram Liquid Glass Post Cards**:
   - Карточки публикаций на базе полупрозрачного `AppColors.obsidianCardTranslucent` и specular-бордюров (без GPU-интенсивного `BackdropFilter` внутри скролла).
   - Шапка: автор + питомец + район + категория (SOS с пульсацией, Здоровье, Дрессировка) + верифицированный бейдж PawConnect для официальных постов.
   - Медиа-контент: полноразмерное фото (соотношение 4:5 / 1:1) с поддержкой **Double-Tap Like** и вылетающим сердечком (`HeartBurstOverlay`).
   - Панель реакций: анимированный `HeartPopButton`, кнопка вызова комментариев со счетчиком, кнопка поделиться, кнопка закладки (сохранение в `isBookmarked`).
   - Текст: разворачиваемый пост («ещё...») и кликабельная плашка открытия комментариев.
3. **Интерактивные комментарии (`CommentsBottomSheet`)**:
   - Выдвижная модальная шторка со списком комментариев и полем ввода для мгновенной отправки ответа.
   - Поддержка официальных ответов поддержки PawConnect.
4. **Показательный контент от лица PawConnect Team**:
   - Официальные посты и сториз: советы кинолога, настройка безопасных геозон ошейника, анонсы проверенных дог-парков.
5. **Zero-Stub Policy & FastAPI интеграция**:
   - Запросы к реальному бэкенду `/api/v1/community/posts` (`GET`, `POST`, `POST /{id}/like`) и `/api/v1/community/stories`.
   - Честная обработка ошибок сети (400, 401, 404, 500) через `AsyncValue.error` в Riverpod, скелетоны (shimmer) при загрузке и кнопка «Повторить» при сбое.

---

## 2. Архитектура и Структура Компонентов

```
lib/features/community/
├── community_screen.dart             # Корневой экран Tab 0 (/feed) с Pull-to-Refresh и фильтрами
└── widgets/
    ├── community_stories_bar.dart    # Горизонтальная карусель аватаров сториз
    ├── story_player_screen.dart      # Полноэкранный Instagram-плеер историй
    ├── community_post_card.dart      # Instagram Liquid Glass карточка поста
    ├── heart_burst_overlay.dart      # Анимация всплывающего сердца при double-tap
    ├── heart_pop_button.dart         # Микроинтерактивная кнопка лайка
    ├── comments_bottom_sheet.dart    # Модальная шторка комментариев с инпутом
    ├── district_filter_bar.dart      # Горизонтальный скролл 10 районов Новосибирска
    └── new_post_modal.dart           # Модальное окно создания нового поста
```

### Модели данных (`lib/models/`):
* **`CommunityPostModel`** (расширенный):
  ```dart
  class CommunityPostModel {
    final String id;
    final String authorName;
    final String? authorAvatar;
    final bool isOfficial;          // Бейдж верификации PawConnect Team
    final String? petName;          // Кличка и порода
    final String district;          // Район Новосибирска
    final String category;          // 'general', 'health', 'training', 'sos'
    final String title;
    final String content;
    final String? imageUrl;
    final int likesCount;
    final bool isLiked;
    final int commentsCount;
    final bool isBookmarked;
    final DateTime createdAt;
  }
  ```
* **`PetStoryModel`** (новый):
  ```dart
  class PetStoryModel {
    final String id;
    final String authorName;
    final String? authorAvatar;
    final bool isOfficial;          // Флаг официальной сториз приложения
    final String? petName;          // Кличка питомца
    final String district;          // Район прогулки
    final String mediaUrl;          // Фото сториз
    final String statusText;        // Например: "Гуляет 20 мин в Нарымском сквере"
    final DateTime createdAt;
    final bool isViewed;
  }
  ```
* **`PostCommentModel`** (новый):
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
  }
  ```

---

## 3. Бэкенд и Слой Данных (FastAPI + Riverpod)

### FastAPI Endpoints (`server/app/api/v1/endpoints/posts.py`):
1. `GET /api/v1/community/posts`:
   - Query: `district`, `category`, `skip`, `limit`.
   - Возвращает список постов с полями автора, питомца, счетчиками лайков и комментариев.
2. `POST /api/v1/community/posts`:
   - Создание нового поста (валидация Pydantic, привязка к текущему пользователю).
3. `POST /api/v1/community/posts/{post_id}/like`:
   - Инкремент/декремент лайка с возвратом обновленного состояния.
4. `GET /api/v1/community/stories`:
   - Список актуальных историй (официальные советы PawConnect + активные питомцы на прогулке).
5. `GET /api/v1/community/posts/{post_id}/comments`:
   - Список комментариев к посту.
6. `POST /api/v1/community/posts/{post_id}/comments`:
   - Добавление комментария авторизованным пользователем.

### Riverpod State (`lib/providers/community_provider.dart`):
* `CommunityState`:
  * `AsyncValue<List<CommunityPostModel>> postsAsync`
  * `AsyncValue<List<PetStoryModel>> storiesAsync`
  * `String selectedDistrict` (по умолчанию `'Все районы'`)
  * `String selectedCategory` (по умолчанию `'all'`)
  * `Map<String, List<PostCommentModel>> postCommentsCache`
  * `Set<String> bookmarkedPostIds`
* Методы `CommunityNotifier`:
  * `loadFeed({bool forceRefresh = false})`
  * `toggleLike(String postId)`
  * `toggleBookmark(String postId)`
  * `loadComments(String postId)`
  * `addComment(String postId, String text)`
  * `markStoryViewed(String storyId)`
  * `createPost(...)`

---

## 4. UI/UX Детали и Производительность

1. **Производительность скролла (Zero Jank Policy)**:
   - Внутри `CommunityPostCard` запрещено использовать `BackdropFilter`.
   - Фон карточки: `AppColors.obsidianCardTranslucent` (`Color(0xCC161B22)`) с легкой внутренней тенью и тонким градиентным бордером (`Colors.white12`).
   - Изображения кэшируются через `PawImage` с fade-in эффектом и плавным плейсхолдером.
2. **Микроинтеракции**:
   - Double-tap по фото: мягкая тактильная отдача (haptic feedback) + появление масштабируемого белого/красного сердца по центру фото с затуханием (400 мс).
   - Анимация лайка внизу карточки: пружинящий scale-эффект (spring-bounce).
3. **Официальный профиль PawConnect Team**:
   - Аватар с фирменной лапкой PawConnect на градиенте акцентных цветов (`#34D399` / `#3B82F6`).
   - Значок верификации: синяя капсула с иконкой `Icons.verified_rounded`.
   - В комментариях: бейдж `Команда PawConnect` для экспертных ответов кинолога/ветврача.

---

## 5. План Тестирования и Верификации

1. **Unit & State Tests**:
   - Тесты `CommunityNotifier` на фильтрацию по 10 районам Новосибирска и категориям.
   - Тесты переключения лайков, закладок и добавления комментариев.
   - Проверка честной обработки ошибок бэкенда (`AsyncError`).
2. **Widget Tests**:
   - Рендеринг `CommunityScreen`, проверка отображения Stories rail.
   - Проверка double-tap по фото и вызова `HeartBurstOverlay`.
   - Проверка открытия `CommentsBottomSheet` и `StoryPlayerScreen`.
3. **Backend API Tests (`server/tests/test_posts.py`)**:
   - Проверка эндпоинтов `/api/v1/community/posts`, `/comments`, `/like` и `/stories`.
