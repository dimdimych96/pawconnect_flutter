# Production Guest Mode & Progressive Authorization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a production-grade Guest Mode (полноценный гостевой режим) without forced authentication on launch. Guests freely browse the Community Feed, interactive Yandex Map, and Search without any demo clutter. When attempting write actions (posting, stories, liking, commenting), display a clean production Apple Liquid Glass auth prompt modal. Maintain a clean, production-grade login & registration form on `/auth` without demo buttons.

**Architecture:**
- **Navigation (`app_router.dart`)**: Eliminate the blanket unauthenticated redirect to `/auth`. The initial location is `/feed`. Guests browse freely across `/feed`, `/map`, `/search`, `/profile`, and `/settings`.
- **Production Auth Screen (`auth_screen.dart`)**: Pure production UI (Вход / Регистрация, Email, Пароль, Имя). No test/demo buttons. Includes a discreet top navigation button `[ ← Назад к ленте ]` so users can return to guest browsing.
- **Progressive Auth Prompts (`auth_prompt_modal.dart`)**: Contextual modal sheet appears only when guest attempts write actions (`+ Пост`, `+ Ваша история`, `Лайк`, `Комментарии`), offering `[ Войти в аккаунт ]` or `[ Позже ]`.
- **Feed Experience (`community_screen.dart`)**: Top bar features a discreet `[ Войти ]` glass capsule for guests. Author-only controls (edit/delete) are safely hidden for unauthenticated visitors.
- **Passport (`pet_profile_screen.dart`) & Settings (`settings_screen.dart`)**: Clean production guest states with an informative invite card and `[ Войти или создать аккаунт ]` button.
- **Web Resilience (`app_config.dart` & `auth_service.dart`)**: Offline mock fallback triggers on static hosting (`github.io`) or `--dart-define=ENABLE_OFFLINE_MOCKS=true` to prevent browser mixed-content crashes, seamlessly creating the account while keeping the real backend pathway active for local and production servers.

**Tech Stack:** Flutter 3.x, Riverpod 2.x, GoRouter, Apple Liquid Glass Design System.

---

## Global Constraints

- **Production UI Integrity**: NO demo/test buttons, mock badges, or developer artifacts in the user-facing UI.
- **Zero-Stub Policy**: Real backend calls (`127.0.0.1:8000`) must continue to work normally when the backend is reachable; fallback is only used when the server is unreachable or on static hosts (`github.io`).
- **Liquid Glass Performance Budget**: No `BackdropFilter` inside scrolling list items.
- **Modals**: All modal sheets must set `useRootNavigator: true`.
- **Quality Gates**: `flutter analyze` with 0 warnings, all unit/widget tests passing (`flutter test`).

---

## User Review Required

> [!IMPORTANT]
> **Key Decisions Aligned with User Feedback:**
> 1. **No Demo Buttons**: The `/auth` screen remains strictly production-oriented (Email, Password, Name). No pre-filled demo logins or fake buttons.
> 2. **Guest Freedom**: Users immediately see the feed on launch. They can browse posts, read comments, view stories, explore the map, and search categories without signing in.
> 3. **Smooth Return**: A guest who opens `/auth` can tap `[ ← Назад к ленте ]` to return to browsing at any time.

---

## Proposed Changes

### Component 1: Routing & Configuration Layer

#### [MODIFY] `lib/core/config/app_config.dart`
- Dynamically detect static web hosting (`github.io`, `pages.dev`, `vercel.app`) or `--dart-define=ENABLE_OFFLINE_MOCKS=true` / `USE_MOCKS=true` to prevent browser Mixed Content network errors on static sites.

#### [MODIFY] `lib/services/auth_service.dart`
- In `SecureAuthStorage`, add fallback to `SharedPreferences` for web environments where `FlutterSecureStorage` may be unavailable or restricted.
- In `AuthService.login` and `AuthService.register`, when fallback is active, assign `role: 'admin'` if email equals `'dmitryborona@gmail.com'` or contains `'admin'`.

#### [MODIFY] `lib/routes/app_router.dart`
- Remove the unconditional redirect from unauthenticated states to `/auth`.
- If an unauthenticated user navigates around (`/feed`, `/map`, `/search`, `/profile`, `/settings`), allow them to view the screen in Guest Mode.
- If an authenticated user navigates to `/auth`, redirect them to `/feed`.

```dart
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/auth';
      if (isAuthRoute && authState.isAuthenticated) {
        return '/feed';
      }
      return null;
    },
```

---

### Component 2: Production Auth Screen

#### [MODIFY] `lib/features/auth/auth_screen.dart`
- Keep strictly production UI:
  - Header: PawConnect logo and subtitle ("Единая экосистема для заботы о питомцах")
  - Tab Switcher: `[ Вход | Регистрация ]`
  - Name field (Register only)
  - Email & Password fields
  - Submit button: `[ Войти в аккаунт ]` / `[ Зарегистрироваться ]`
  - Top bar button: `[ ← Назад ]` (navigates back to `/feed` via `context.go('/feed')`)
  - NO demo login buttons or fake test accounts.

---

### Component 3: Community Feed Guest Experience & Contextual Prompts

#### [NEW] `lib/core/widgets/auth_prompt_modal.dart`
- Reusable Apple Liquid Glass bottom modal presented when a guest attempts an authenticated action:
  - Icon: `Icons.lock_outline_rounded` inside an emerald/cyan glowing container.
  - Title: *"Требуется авторизация"*
  - Description: *"Войдите или зарегистрируйтесь, чтобы $action, находить друзей и сохранять публикации."*
  - Primary button: `[ Войти в аккаунт ]` -> closes modal and navigates `context.push('/auth')`.
  - Secondary button: `[ Продолжить как гость ]` -> closes modal.

#### [MODIFY] `lib/features/community/community_screen.dart`
- **Header**:
  - If `!authState.isAuthenticated`: display a clean Apple Liquid Glass `[ Войти ]` pill button with `Icons.login_rounded` in the top bar.
- **Action Guards**:
  - `+ Пост` button: If guest, invoke `AuthPromptModal.show(context, action: 'публиковать посты в ленте')`.
  - `+ Ваша история`: If guest, invoke `AuthPromptModal.show(context, action: 'добавлять истории')`.
  - `onLike`: If guest, invoke `AuthPromptModal.show(context, action: 'ставить отметки «Нравится»')`.
  - `_openComments`: When guest tries to send a comment, invoke `AuthPromptModal.show(context, action: 'оставлять комментарии')`.
  - `_isPostAuthor`: If `currentUser == null`, safely return `false` (guests cannot edit or delete posts).

---

### Component 4: Pet Profile & Settings Production Guest States

#### [MODIFY] `lib/features/profile/pet_profile_screen.dart`
- If unauthenticated (`!authState.isAuthenticated`):
  - Display a clean guest preview header:
    - Title: *"Цифровой паспорт питомца"*
    - Subtitle: *"Войдите, чтобы привязать умный GPS-ошейник, настроить безопасные геозоны и вести ветеринарный календарь."*
    - Glass CTA button: `[ Войти или зарегистрироваться ]` -> `context.push('/auth')`.
  - The demo card for "Макс" is shown as an interactive demonstration preview with a subtle "Демо-просмотр" tag.

#### [MODIFY] `lib/features/settings/settings_screen.dart`
- If unauthenticated (`!authState.isAuthenticated`):
  - Replace Owner Profile Card with **Гостевой профиль**:
    - Avatar placeholder (`Icons.person_outline_rounded`)
    - Name: *"Гость PawConnect"*
    - Status: *"Вход не выполнен"*
    - Primary Button: `[ Войти в аккаунт ]` -> `context.push('/auth')`.
  - Diagnostic rows show `Роль профиля: ГОСТЬ`.
  - Hide "Выйти из аккаунта" button when not logged in.

---

### Component 5: CI/CD Deployment

#### [MODIFY] `.github/workflows/deploy.yml`
- Add `--dart-define=ENABLE_OFFLINE_MOCKS=true` to `flutter build web` to ensure static GitHub Pages builds gracefully handle network requests.

---

## Verification Plan

### Automated Tests
1. **Unit & Widget Tests**:
   - Update `test/widget_test.dart` to verify that unauthenticated launch renders Tab 0 Community Feed in guest mode without redirecting to `/auth`.
   - Add widget test for `AuthPromptModal` when tapping `+ Пост` as a guest.
   - Run `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test` -> must pass 100%.
2. **Static Analysis**:
   - `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter analyze` -> 0 issues.
3. **Web Build**:
   - `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter build web --release` -> builds without errors.

### Manual Verification
1. Open GitHub Pages (`https://dimdimych96.github.io/pawconnect_flutter/`) or local web build.
2. Verify app loads immediately into the feed (`/feed`), showing stories, posts, and districts without forcing `/auth`.
3. Check header: sleek `[ Войти ]` pill button present.
4. Tap `+ Пост` or `+ История` or `Лайк` -> verify production Liquid Glass auth prompt modal pops up smoothly.
5. Tap `[ Войти в аккаунт ]` -> opens `/auth`. Check that there are **no** demo buttons.
6. Verify `[ ← Назад к ленте ]` returns to `/feed`.
7. Enter login or register -> successfully authenticates and updates feed/profile/settings.
