# PawConnect — System Instructions & Architecture for AI Agents

Welcome AI Agent (Antigravity, Cursor, Windsurf, Claude Code, ChatGPT)!

## 📌 Project Overview
PawConnect is a production-grade, cross-platform pet companion ecosystem (Flutter Mobile & Web + FastAPI Python backend) with an **Apple Liquid Glass** design system (Obsidian `#0A0A0C`, slate `#1C1C1E`, controlled `BackdropFilter` overlays).

- Production ADR: [`docs/adr/0001-transition-to-production-architecture.md`](./docs/adr/0001-transition-to-production-architecture.md)
- Production System Spec: [`docs/superpowers/specs/2026-08-22-pawconnect-production-design.md`](./docs/superpowers/specs/2026-08-22-pawconnect-production-design.md)
- UI/UX Spec: [`pawconnect_flutter_spec.md`](./pawconnect_flutter_spec.md)

---

## ⚡ Production Architecture & Engineering Rules

1. **NO Silent Stubs or Fake Fallbacks (Zero-Stub Policy)**:
   - **DO NOT** swallow network exceptions with `catch (_) { return mockData; }`.
   - Real network errors, validation failures, and HTTP status codes (400, 401, 403, 404, 500) must be explicitly propagated to Riverpod state (`AsyncValue.error` or typed `Result`).
   - The UI must display genuine error states, retry triggers, and empty states.
   - Mock data belongs exclusively to automated tests or an explicit mock flavor enabled via `--dart-define=USE_MOCKS=true`.

2. **Yandex Maps as Primary Map Engine**:
   - Engine: `flutter_map` + `latlong2`.
   - Tiles: **Yandex Maps Tiles** (`https://core-renderer-tiles.maps.yandex.net/tiles?l=map&x={x}&y={y}&z={z}&scale=1&lang=ru_RU`).
   - Dynamic GPU Themes: Powered by `ColorFilter.matrix` in `MapThemeProvider` (Emerald Dark, Cyberpunk, Obsidian, Classic).
   - Markers: Standard Flutter widgets (`Marker(child: Widget)`) for pulse collars, avatars, and custom beacons.

3. **Real Authentication & Security**:
   - Real authentication endpoints on FastAPI (`/api/v1/auth/login` and `/api/v1/auth/register`).
   - Secure token storage via `FlutterSecureStorage` (with SharedPreferences fallback).
   - `AuthInterceptor` on `Dio` automatically attaches `Authorization: Bearer <token>` and handles 401 token refresh.
   - **NO** pre-filled hardcoded test credentials or fake success states in production UI.

4. **Instagram 2026 Shell & Navigation Hierarchy**:
   - Managed via `GoRouter` with `StatefulShellRoute.indexedStack`.
   - **Tab 0 (Home / Главная):** `/feed` — Instagram 2026 Community Feed with Stories rail, media posts, Heart Pop likes.
   - **Tab 1:** `/map` — Interactive Yandex Map with live GPS collar radar, geofences, and markers.
   - **Tab 2:** `/search` — Fullscreen Discovery & Category Search.
   - **Tab 3:** `/profile` — Pet Passport, Collar controls, Safe Zone slider, Vet Calendar.
   - **Tab 4:** `/settings` — Owner profile, push toggles, diagnostics, emergency breach simulator.
   - **Protected Route:** `/auth` — Real authentication screen with route guards in `routerProvider`.

5. **Apple Liquid Glass Performance Budget**:
   - `BackdropFilter` (Gaussian blur) is expensive on GPU. Use it **strictly** for persistent shell chrome:
     - Floating bottom tabbar (`main_shell.dart`)
     - Top search capsule & emergency breach banner
     - Modal sheets
   - **FORBIDDEN**: Do NOT place `BackdropFilter` inside scrolling list items (feed posts, search results, list markers). Use translucent base colors (`AppColors.obsidianCardTranslucent`) and specular border gradients instead.

6. **Icons & Assets**:
   - Use Flutter standard `Icons` or `cupertino_icons`.
   - **DO NOT** import `lucide_icons` or deprecated font icon packages (breaks Web CanvasKit compilation).

---

## 🚫 Delete-Zone (DO NOT RE-ADD)
- ❌ `catch (_) => mock...` in network services (masks broken backends and loses user data).
- ❌ Pre-filled demo credentials (`alex@pawconnect.app` / `password123`) in auth fields.
- ❌ `lucide_icons` package (incompatible with Flutter Web).
- ❌ Hardcoded CartoDB or Mapbox raster URLs (use Yandex Maps tiles).
- ❌ `google_maps_flutter` (rejected in favor of cross-platform `flutter_map`).
- ❌ Legacy HTML renderer lock in web (use standard CanvasKit/auto).

---

## 📁 Key File Structure

### Frontend (`lib/`)
- `lib/core/config/app_config.dart`: Environment configuration (`API_BASE_URL`, `WS_BASE_URL`).
- `lib/core/theme/colors.dart`: Liquid Glass obsidian palette & border styles.
- `lib/core/widgets/glass_widgets.dart`: `GlassContainer`, `GlassCard`, `GlassCapsule`.
- `lib/models/`: Plain Dart models with explicit `fromJson` / `toJson` / `copyWith` (`MapMarkerModel`, `GpsDeviceModel`, `PetReminderModel`, `CommunityPostModel`, `AuthModel`, `RouteModel`).
- `lib/services/`: Production HTTP clients (`auth_service.dart`, `map_service.dart`, `community_service.dart`, `location_service.dart`, `reminder_service.dart`).
- `lib/providers/`: Riverpod providers (`auth_provider.dart`, `map_provider.dart`, `map_theme_provider.dart`, `community_provider.dart`, `reminders_provider.dart`, `user_provider.dart`).
- `lib/routes/app_router.dart`: 5-tab shell routing + auth guards.
- `lib/shell/main_shell.dart`: Floating Liquid Glass bottom bar & top `BreachAlertBanner`.
- `lib/features/community/`: Tab 0 — Instagram 2026 Feed, Stories rail, Novosibirsk districts.
- `lib/features/map/`: Tab 1 — Yandex Maps, collar pulse, geofence tuner, OSRM routing.
- `lib/features/search/`: Tab 2 — Discovery search, category chips, radius filter.
- `lib/features/profile/`: Tab 3 — Pet passport, GPS collar telemetry, vet calendar.
- `lib/features/settings/`: Tab 4 — Owner profile, push toggles, diagnostics.
- `lib/features/auth/`: Login, registration, token verification.

### Backend (`server/`)
- `server/app/main.py`: FastAPI entrypoint with CORS, static media, auto-table sync.
- `server/app/api/v1/`: Endpoints (`auth`, `pets`, `markers`, `posts`, `reminders`, `beacons`, `ws`).
- `server/app/models/`: Async SQLAlchemy 2.0 models (`user`, `pet`, `marker`, `post`, `reminder`).
- `server/tests/`: Pytest suite for API verification.
- `docker-compose.yml`: Multi-container production stack (PostgreSQL 16 + PostGIS, Redis 7, FastAPI, Nginx).

---

## 🧪 Quality Gates & Commit Discipline
Before declaring any task done or committing code:
1. `flutter analyze` — must pass with zero issues.
2. `flutter test` — all unit, widget, and navigation tests must pass.
3. `pytest server/tests` — all backend tests must pass if `server/` was modified.
4. **Git Commits**: Use Conventional Commits (`feat:`, `fix:`, `refactor:`, `chore:`, `test:`).
