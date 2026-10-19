# Phase 4: Verified Specialists & Services Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Phase 4 of the Gavs elevated roadmap in PawConnect: verified specialists and services directory (cynologists, dog sitters, groomers, vet clinics) with ratings, trust badges, pricing, instant inquiry modal, and seamless Yandex Maps route navigation under Apple Liquid Glass 2026.

**Architecture:** 
1. Backend: SQLAlchemy 2.0 `Specialist` model seeded with curated Novosibirsk professionals + FastAPI endpoints (`/specialists`, `/specialists/{id}`, `/specialists/{id}/inquiry`).
2. Frontend Models & Services: `SpecialistModel` with profession labels and pricing helpers, `SpecialistService` with zero-stub HTTP handling and offline test fallback, and Riverpod `specialistsNotifierProvider`.
3. UI: `SpecialistCard` in Apple Liquid Glass obsidian styling (no `BackdropFilter` in scroll items), `SpecialistInquiryModal` for direct booking/contact, enhanced `SearchScreen` with specialist category filter chips, and one-tap Yandex Maps route integration.

**Tech Stack:** 
- Backend: FastAPI, SQLAlchemy 2.0, Pydantic v2, Pytest.
- Frontend: Flutter 3.x, Riverpod 2.5+, LatLong2 / FlutterMap (Yandex Tiles engine).

**Spec:** `docs/superpowers/specs/2026-10-19-gavs-reference-roadmap.md`

## Global Constraints
- Zero-Stub Policy: Real endpoints and typed models; errors explicitly propagated to Riverpod state; mock data belongs strictly in automated tests or explicit fallback mode.
- Apple Liquid Glass Performance Budget: Strictly ZERO `BackdropFilter` inside scrolling list items. Use `AppColors.obsidianCardTranslucent` base and specular border gradients.
- Zero-Clone Vocabulary: Distinctive terminology: «Верифицированные специалисты», «Знак доверия PawConnect», «Кинологи & Зоопсихологи», «Догситтеры & Передержка», «Мастера груминга».
- Yandex Maps Engine: Route navigation builds through OSRM / `mapNotifierProvider.buildRouteTo(...)`.
- Quality Gates: Zero warnings in `flutter analyze`, 100% pass in `pytest server/tests`, 100% pass in `flutter test`.

---

### Task 1: Backend Data Model & Curated Specialists Seeding

**Files:**
- Create: `server/app/models/specialist.py`
- Modify: `server/app/models/__init__.py`
- Modify: `server/app/main.py`
- Test: `server/tests/test_specialist_models.py`

**Interfaces:**
- Produces: `Specialist` SQLAlchemy model with columns: `id`, `name`, `avatar_url`, `profession`, `profession_title`, `rating`, `reviews_count`, `experience_years`, `price_from`, `price_unit`, `is_verified`, `district`, `address`, `latitude`, `longitude`, `bio`, `phone`, `telegram`, `services_json`.
- Seeds 6 curated professionals across Novosibirsk (Zayeltsovsky, Leninsky, Akademgorodok, Tsentralny).

- [ ] **Step 1: Write backend model unit tests**
- [ ] **Step 2: Implement `Specialist` model and add auto-seed data**
- [ ] **Step 3: Run pytest and verify passes**
- [ ] **Step 4: Commit `feat(models): add specialist model and curated seed data`**

---

### Task 2: Backend API Endpoints & Schemas

**Files:**
- Create: `server/app/schemas/specialist.py`
- Create: `server/app/api/v1/endpoints/specialists.py`
- Modify: `server/app/api/v1/api.py`
- Test: `server/tests/test_specialist_endpoints.py`

**Interfaces:**
- `GET /api/v1/specialists` (filters: `profession`, `district`, `query`)
- `GET /api/v1/specialists/{id}` (full detail with services)
- `POST /api/v1/specialists/{id}/inquiry` (booking / message inquiry)

- [ ] **Step 1: Write failing endpoint integration tests in `test_specialist_endpoints.py`**
- [ ] **Step 2: Implement Pydantic schemas and FastAPI endpoints**
- [ ] **Step 3: Register `/specialists` router in `server/app/api/v1/api.py`**
- [ ] **Step 4: Run pytest and verify 100% pass**
- [ ] **Step 5: Commit `feat(api): add specialists catalog and booking inquiry endpoints`**

---

### Task 3: Frontend Data Models & Serialization

**Files:**
- Create: `lib/models/specialist_model.dart`
- Test: `test/models/specialist_models_test.dart`

**Interfaces:**
- `SpecialistModel`: `id`, `name`, `avatarUrl`, `profession`, `professionTitle`, `rating`, `reviewsCount`, `experienceYears`, `priceFrom`, `priceUnit`, `isVerified`, `district`, `address`, `latitude`, `longitude`, `bio`, `telegram`, `phone`.
- Helper getters: `formattedPrice`, `verifiedBadgeText`, `professionColor`.

- [ ] **Step 1: Write model tests with JSON serialization and format helpers**
- [ ] **Step 2: Implement `SpecialistModel`**
- [ ] **Step 3: Run flutter test and verify passes**
- [ ] **Step 4: Commit `feat(models): add specialist model and pricing formatters`**

---

### Task 4: Frontend Specialist Service & Riverpod Provider

**Files:**
- Create: `lib/services/specialist_service.dart`
- Create: `lib/providers/specialist_provider.dart`
- Test: `test/services/specialist_service_test.dart`
- Test: `test/providers/specialist_provider_test.dart`

**Interfaces:**
- `SpecialistService.getSpecialists({String? profession, String? district, String? query})`
- `SpecialistService.sendInquiry(String specialistId, {required String message, String? petId})`
- `SpecialistsState`: `specialistsAsync`, `selectedProfession`, `selectedDistrict`, `searchQuery`.
- `SpecialistsNotifier`: `setProfession(String)`, `setDistrict(String)`, `setQuery(String)`, `sendInquiry(...)`.

- [ ] **Step 1: Write service and provider unit tests**
- [ ] **Step 2: Implement `SpecialistService` and `SpecialistsNotifier`**
- [ ] **Step 3: Run flutter test and verify passes**
- [ ] **Step 4: Commit `feat(providers): add specialist service and Riverpod provider`**

---

### Task 5: Specialist Liquid Glass Cards & Inquiry Modal

**Files:**
- Create: `lib/features/search/widgets/specialist_card.dart`
- Create: `lib/features/search/widgets/specialist_inquiry_modal.dart`
- Test: `test/widgets/specialist_card_test.dart`

**Interfaces:**
- `SpecialistCard`: Liquid Glass card displaying trust badge, rating star, price tag, address/district, and action buttons (`На карте & Маршрут`, `Связаться`). Strictly zero `BackdropFilter` inside card.
- `SpecialistInquiryModal`: Glass bottom sheet for writing booking/contact message and submitting.

- [ ] **Step 1: Write widget tests for SpecialistCard and InquiryModal**
- [ ] **Step 2: Implement `SpecialistCard` and `SpecialistInquiryModal`**
- [ ] **Step 3: Run flutter test and verify passes**
- [ ] **Step 4: Commit `feat(search): add Liquid Glass specialist card and booking inquiry modal`**

---

### Task 6: Enhanced SearchScreen Integration & Route Building

**Files:**
- Modify: `lib/features/search/search_screen.dart`
- Test: `test/features/search/search_screen_specialists_test.dart`

**Interfaces:**
- Adds category filter chips in `SearchScreen`:
  - `all` (Все)
  - `cynologist` (🐕 Кинологи)
  - `dogsitter` (🏡 Догситтеры)
  - `groomer` (✂️ Груминг)
  - `vet` (🏥 Ветклиники)
  - `playground` (🌳 Площадки)
- Seamless transition to Yandex Maps (`/map`) with route calculation on tapping `«На карте»`.

- [ ] **Step 1: Write integration tests for SearchScreen with specialist filters**
- [ ] **Step 2: Integrate specialists feed and category chips into `SearchScreen`**
- [ ] **Step 3: Run flutter test and verify passes**
- [ ] **Step 4: Commit `feat(search): integrate verified specialists into discovery search screen`**

---

### Task 7: Full Quality Gate Verification

- [ ] **Step 1: Run `flutter analyze` with zero issues**
- [ ] **Step 2: Run `pytest server/tests` with 100% pass**
- [ ] **Step 3: Run full `flutter test` suite with 100% pass**
- [ ] **Step 4: Generate completion report**
