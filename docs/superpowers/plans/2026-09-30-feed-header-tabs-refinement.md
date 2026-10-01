# Feed Header & Tabs Refinement Implementation Plan

> **Goal**: Eliminate visual clutter at the top of Tab 0 (`/feed`), replace the 4 tiers of stacked controls with an Apple Liquid Glass Segmented Control (`Для вас` | `Мой район` | `SOS 🚨`), embed stories naturally into the scrollable feed, and introduce a contextual district picker for Novosibirsk.

---

## Architecture & Design Rules
1. **Zero-Stub Policy**: Real errors propagated to `AsyncValue.error`. No silent fallback masks.
2. **Apple Liquid Glass Budget**: Zero `BackdropFilter` inside scrolling post cards. Blur is reserved strictly for sticky chrome and modal sheets (`DistrictPickerBottomSheet`).
3. **Instagram 2026 Experience**:
   - Clean top branding (`PawConnect` + `＋`).
   - Natural scroll: stories scroll with feed content, leaving 100% of vertical height for media when reading posts.
   - Smooth horizontal swipe transitions (`TabBarView`) between feeds.
4. **Arcadia Protection**: Absolute ban on touching or inspecting `/Users/dmitryborona/arcadia`.

---

## Tasks Breakdown

### Task 1: Create `FeedSegmentedControl` Widget
- **File**: `lib/features/community/widgets/feed_segmented_control.dart`
- **Spec**:
  - Encapsulated Liquid Glass segmented capsule with 3 tabs: `Для вас`, `Мой район`, `SOS 🚨`.
  - Sliding active indicator with smooth curve (`Curves.easeInOutCubic`).
  - Active red indicator badge for `SOS`.
  - Supports `TabController` synchronization.

### Task 2: Create `DistrictPickerBottomSheet` Widget
- **File**: `lib/features/community/widgets/district_picker_bottom_sheet.dart`
- **Spec**:
  - Modal sheet with blurred acrylic glass background.
  - 10 Novosibirsk districts: Центральный, Заельцовский, Дзержинский, Железнодорожный, Калининский, Кировский, Ленинский, Октябрьский, Первомайский, Советский (Академгородок) + «Все районы».
  - Radio/check indicator for current selection.
  - Invoked with `useRootNavigator: true`.

### Task 3: Assemble Refined `CommunityScreen`
- **File**: `lib/features/community/community_screen.dart`
- **Spec**:
  - Clean top bar: PawConnect logo + `＋` button.
  - Liquid Glass Segmented Control underneath.
  - `TabBarView`:
    - Tab 0 (`Для вас`): `RefreshIndicator` -> `ListView` with `CommunityStoriesBar` as first item, followed by community posts.
    - Tab 1 (`Мой район`): Sticky top bar `📍 [District Name] [Сменить ▾]`, followed by district-filtered stories and posts.
    - Tab 2 (`SOS 🚨`): Urgent alert banner, followed by `category == 'sos'` posts.

### Task 4: Widget Tests & Quality Verification
- **File**: `test/features/community/community_screen_test.dart`
- **Spec**:
  - Test clean header rendering without redundant refresh button.
  - Test segmented control rendering with 3 tabs.
  - Test tab switching and swipe between streams.
  - Test district picker modal presentation and district selection.
  - Test stories scrolling within feed.
  - Verify zero `BackdropFilter` inside scrolling post cards.
  - Run `flutter analyze` and `flutter test`.

---

## Quality Gates
- `flutter analyze` must pass with 0 issues.
- `flutter test` must pass (all 97+ tests).
- Pytest backend tests must pass (11/11).
