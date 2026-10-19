# Phase 2: «Радар прогулок» & Совместный выгул — Implementation Plan

> **Goal**: Implement PawConnect's signature **«Радар прогулок» (Walk Radar)** and live companion matching on Yandex Maps with dog temperament compatibility, live walk session tracking, private walk mode with coordinate fuzzing, and one-tap walk invitations — completely native to the Apple Liquid Glass design system.
> **Architecture Reference**: [`docs/superpowers/specs/2026-10-19-gavs-reference-roadmap.md`](file:///Users/dmitryborona/.gemini/antigravity/worktrees/pawconnect_flutter/polish_main_feed/docs/superpowers/specs/2026-10-19-gavs-reference-roadmap.md)
> **Compliance**: AGENTS.md Zero-Stub Policy, Apple Liquid Glass performance rules (STRICT ZERO JANK: no `BackdropFilter` inside scrolling items).

---

## Proposed Changes & File Structure

```
server/
├── app/
│   ├── models/
│   │   ├── pet.py                  # Extend Pet with temperament, is_walking, walk_mode, walk_started_at
│   │   └── walk.py                 # WalkSession and WalkInvitation SQLAlchemy models
│   ├── schemas/
│   │   └── walk.py                 # Pydantic schemas for walk start, stop, nearby, invite
│   └── api/v1/
│       ├── api.py                  # Include /walks router
│       └── endpoints/
│           └── walks.py            # Endpoints: /start, /stop, /active, /nearby, /invite, /temperament
└── tests/
    ├── test_walk_models.py         # Pytest for walk session and invitation models
    └── test_walk_endpoints.py      # Pytest for walk API endpoints

lib/
├── models/
│   ├── walk_session_model.dart     # WalkSessionModel, DogTemperament, WalkInvitationModel
│   └── map_marker_model.dart       # Extend with temperament, walkMode, isWalking, walkStartedAt
├── services/
│   └── walk_service.dart           # Production Dio HTTP client for /walks
├── providers/
│   └── walk_provider.dart          # Riverpod StateNotifier managing activeWalk and nearby companions
├── features/
│   └── map/
│       └── widgets/
│           ├── companion_walk_marker.dart   # Live walking avatar with Walk Pulse green aura & temperament badge
│           ├── walk_session_hud.dart        # Floating Liquid Glass top capsule with live walk timer and mode
│           ├── start_walk_modal.dart        # Bottom sheet: Open / Private / Training modes & temperament picker
│           └── marker_detail_sheet.dart     # Enriched companion detail with temperament compatibility & invite
└── shell/
    └── main_shell.dart             # Mount WalkSessionHud when walk is active

test/
├── models/
│   └── walk_models_test.dart       # Unit test for walk models & temperament matrix
├── services/
│   └── walk_service_test.dart      # Mock HTTP unit tests for walk service
└── widgets/
    ├── walk_session_hud_test.dart  # Widget test for walk HUD
    ├── start_walk_modal_test.dart  # Widget test for start walk sheet
    └── companion_walk_marker_test.dart # Widget test for marker & temperament compatibility
```

---

## Tasks Breakdown

### Task 1: Backend Models for Walk Sessions & Temperaments
- **Files**:
  - `server/app/models/pet.py`: Add `temperament` (default `'playful'`), `is_walking` (bool), `walk_mode` (`'open'`, `'private'`, `'training'`), `walk_started_at` (DateTime).
  - `server/app/models/walk.py`: Create `WalkSession` and `WalkInvitation`.
  - `server/app/models/__init__.py`: Export `walk`.
- **Test**: `server/tests/test_walk_models.py`
- **Verification**: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests/test_walk_models.py`

### Task 2: Backend API Endpoints for Walk Radar & Invitations
- **Files**:
  - `server/app/schemas/walk.py`: Pydantic request/response schemas.
  - `server/app/api/v1/endpoints/walks.py`: Implement `/start`, `/stop`, `/active`, `/nearby` (with privacy fuzzing for `'private'` mode), `/invite`, `/temperament`.
  - `server/app/api/v1/api.py`: Register router.
- **Test**: `server/tests/test_walk_endpoints.py`
- **Verification**: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests/test_walk_endpoints.py`

### Task 3: Frontend Dart Models for Walk Sessions & Dog Temperaments
- **Files**:
  - `lib/models/walk_session_model.dart`: Define `WalkSessionModel`, `DogTemperament` enum (`playful`, `calm`, `energetic`, `shy`, `reactive`) with compatibility checker (`getCompatibility(DogTemperament other)`), `WalkInvitationModel`.
  - `lib/models/map_marker_model.dart`: Add `temperament`, `walkMode`, `isWalking`, `walkStartedAt`.
- **Test**: `test/models/walk_models_test.dart`
- **Verification**: `flutter test test/models/walk_models_test.dart`

### Task 4: Flutter Walk Radar Service & Riverpod State Notifier
- **Files**:
  - `lib/services/walk_service.dart`: Production HTTP service.
  - `lib/providers/walk_provider.dart`: `WalkNotifier` and `walkNotifierProvider`.
- **Test**: `test/services/walk_service_test.dart`
- **Verification**: `flutter test test/services/walk_service_test.dart`

### Task 5: Live Companion Markers & Temperament Compatibility Deck on Yandex Maps
- **Files**:
  - `lib/features/map/widgets/companion_walk_marker.dart`: Pulsing green ring (`Walk Pulse`), avatar, temperament glyph.
  - `lib/features/map/widgets/marker_detail_sheet.dart`: Render Walk Radar companion deck with compatibility advice and «Позвать на выгул» action.
- **Test**: `test/widgets/companion_walk_marker_test.dart`
- **Verification**: `flutter test test/widgets/companion_walk_marker_test.dart`

### Task 6: Interactive Walk HUD Capsule (`WalkSessionHud`)
- **Files**:
  - `lib/features/map/widgets/walk_session_hud.dart`: Floating Liquid Glass top capsule with live walk duration timer and mode toggle.
  - `lib/shell/main_shell.dart`: Integrate `WalkSessionHud` when `activeWalk != null`.
- **Test**: `test/widgets/walk_session_hud_test.dart`
- **Verification**: `flutter test test/widgets/walk_session_hud_test.dart`

### Task 7: Start Walk Modal Sheet (`StartWalkModal`)
- **Files**:
  - `lib/features/map/widgets/start_walk_modal.dart`: Mode cards (Открытый / Приватный / Тренировка) and temperament selector.
  - `lib/features/map/map_screen.dart`: Wire start walk button.
- **Test**: `test/widgets/start_walk_modal_test.dart`
- **Verification**: `flutter test test/widgets/start_walk_modal_test.dart`

### Task 8: Full Quality Gate
- `flutter analyze`
- `PYTHONPATH=server ./server/.venv/bin/pytest server/tests`
- `flutter test`
