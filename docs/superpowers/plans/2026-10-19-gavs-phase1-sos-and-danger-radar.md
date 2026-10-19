# PawConnect — Фаза 1: SOS-Маяк и Радар безопасности (План реализации)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Реализовать Фазу 1 экосистемы PawConnect — интерактивный «SOS-Маяк» с фиксацией следов питомца («Замечен здесь»), поисковыми отрядами («Помочь в поиске») и «Радаром безопасности» на Яндекс.Картах (зоны риска с подтверждением жителями и предупреждением об угрозах при выгуле).

**Architecture:**
- Backend: FastAPI async эндпоинты с SQLAlchemy для фиксации наблюдений (`SOSSighting`), участников поиска (`SOSVolunteer`) и зон риска (`MapMarker` с `danger_type`, `confirmations_count`, `cleared_count`).
- Frontend: Riverpod 2.x, чистые HTTP-сервисы без заглушек, стеклянные карточки со спекулярной неоновой рамкой для SOS-Маяка, интерактивный модал отметки следа, трейл перемещений питомца на Яндекс.Картах и HUD-капсула приближения к угрозам.
- Дизайн-манифест: Никакого прямого копирования `gavs.app`. Уникальный Apple Liquid Glass (Обсидиан `#0A0A0C`, спекулярные контуры, пружинная анимация Cupertino, нативный стиль iOS 2026).

**Tech Stack:** Flutter 3.x, Dart 3.x, Riverpod, Dio, flutter_map + latlong2, FastAPI, SQLAlchemy 2.0 (async), Pydantic v2, pytest.

**Spec:** [`docs/superpowers/specs/2026-10-19-gavs-reference-roadmap.md`](file:///Users/dmitryborona/.gemini/antigravity/worktrees/pawconnect_flutter/polish_main_feed/docs/superpowers/specs/2026-10-19-gavs-reference-roadmap.md)

## Global Constraints
- **Анти-Клон политика:** Использовать только фирменную терминологию PawConnect («SOS-Маяк», «Замечен здесь», «Помочь в поиске», «Радар безопасности»).
- **Apple Liquid Glass Performance:** Строго ZERO JANK. `BackdropFilter` разрешен только в фиксированном хроме (нижняя панель, верхняя капсула, модальные окна), запрещен внутри скроллящихся списков.
- **Zero-Stub Policy:** Реальные сетевые ошибки явно пробрасываются в стейт; моки только в тестах или по флагу `--dart-define=USE_MOCKS=true`.
- **Гостевой режим:** Просмотр доступен без авторизации; при попытке фиксации следа или вступления в отряд вызывается `AuthPromptModal`.
- **Quality Gate:** `flutter analyze` — 0 проблем; все тесты (`flutter test` и `./server/.venv/bin/pytest`) должны проходить.

---

### Task 1: Бэкенд модели для следов питомца, поисковых отрядов и зон риска

**Files:**
- Create: `server/app/models/sos.py`
- Modify: `server/app/models/marker.py:9-25`
- Test: `server/tests/test_sos_models.py`

**Interfaces:**
- Produces: `SOSSighting` model (id, post_id, author_id, latitude, longitude, note, time_ago_str, photo_url, created_at), `SOSVolunteer` model (id, post_id, user_id, created_at), обновленный `MapMarker` с `danger_type`, `confirmations_count`, `cleared_count`, `expires_at`.

- [ ] **Step 1: Write the failing model test**

Create `server/tests/test_sos_models.py`:
```python
import pytest
from datetime import datetime, timezone, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from server.app.models.sos import SOSSighting, SOSVolunteer
from server.app.models.marker import MapMarker
from server.app.models.user import User

@pytest.mark.asyncio
async def test_create_sos_sighting_and_volunteer(db_session: AsyncSession):
    user = User(email="volunteer@pawconnect.app", name="Иван Поисковик", role="user")
    db_session.add(user)
    await db_session.flush()

    sighting = SOSSighting(
        post_id=user.id,
        author_id=user.id,
        latitude=55.0300,
        longitude=82.9200,
        note="Замечен пес у сквера, бежал на восток",
        time_ago_str="30 мин назад",
    )
    volunteer = SOSVolunteer(post_id=user.id, user_id=user.id)
    hazard = MapMarker(
        title="Зона риска: Отрава/Догхантеры",
        category="danger",
        danger_type="poison",
        latitude=55.0310,
        longitude=82.9210,
        confirmations_count=2,
        cleared_count=0,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=48),
    )
    db_session.add_all([sighting, volunteer, hazard])
    await db_session.commit()

    assert sighting.id is not None
    assert volunteer.id is not None
    assert hazard.danger_type == "poison"
    assert hazard.confirmations_count == 2
```

- [ ] **Step 2: Run test to verify it fails**

Run: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests/test_sos_models.py`
Expected: FAIL (ImportError / table missing)

- [ ] **Step 3: Implement `server/app/models/sos.py` and modify `server/app/models/marker.py`**

In `server/app/models/sos.py`:
```python
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, Float, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..db.session import Base

class SOSSighting(Base):
    __tablename__ = "sos_sightings"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey("community_posts.id", ondelete="CASCADE"), nullable=False, index=True)
    author_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    note = Column(Text, nullable=True)
    time_ago_str = Column(String(50), nullable=True)  # e.g. "15-30 мин назад"
    photo_url = Column(String(1024), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    author = relationship("User")
    post = relationship("CommunityPost")

class SOSVolunteer(Base):
    __tablename__ = "sos_volunteers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id = Column(UUID(as_uuid=True), ForeignKey("community_posts.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship("User")
    post = relationship("CommunityPost")
```

In `server/app/models/marker.py`, add:
```python
    danger_type = Column(String(50), nullable=True, index=True)  # 'poison', 'aggressive_pack', 'broken_glass', 'hazard_other'
    confirmations_count = Column(Integer, default=1, nullable=False)
    cleared_count = Column(Integer, default=0, nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=True)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests/test_sos_models.py`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add server/app/models/sos.py server/app/models/marker.py server/tests/test_sos_models.py
git commit -m "feat(backend): add models for SOS sightings, search party, and danger hazards"
```

---

### Task 2: Бэкенд API для фиксации следов («Замечен здесь») и отрядов («Помочь в поиске»)

**Files:**
- Create: `server/app/schemas/sos.py`
- Modify: `server/app/api/v1/endpoints/posts.py`
- Test: `server/tests/test_sos_endpoints.py`

**Interfaces:**
- Produces:
  - `GET /api/v1/posts/{post_id}/sightings` -> `List[SOSSightingResponse]`
  - `POST /api/v1/posts/{post_id}/sightings` -> `SOSSightingResponse`
  - `POST /api/v1/posts/{post_id}/volunteer` -> `SOSVolunteerStatusResponse` (toggle участия)

- [ ] **Step 1: Write the failing API test**

Create `server/tests/test_sos_endpoints.py`:
```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_sos_sighting_and_volunteer_flow(client: AsyncClient, normal_user_token: str):
    headers = {"Authorization": f"Bearer {normal_user_token}"}
    
    post_res = await client.post(
        "/api/v1/posts",
        headers=headers,
        json={
            "district": "Центральный",
            "category": "sos",
            "title": "SOS: Пропал хаски Арчи",
            "text": "Убежал во время прогулки возле сквера",
            "pet_name": "Арчи",
        },
    )
    assert post_res.status_code == 201
    post_id = post_res.json()["id"]

    sighting_res = await client.post(
        f"/api/v1/posts/{post_id}/sightings",
        headers=headers,
        json={
            "latitude": 55.0315,
            "longitude": 82.9215,
            "note": "Замечен возле метро, бежал в сторону парка",
            "time_ago_str": "15 мин назад",
        },
    )
    assert sighting_res.status_code == 201
    assert sighting_res.json()["note"] == "Замечен возле метро, бежал в сторону парка"

    list_res = await client.get(f"/api/v1/posts/{post_id}/sightings")
    assert list_res.status_code == 200
    assert len(list_res.json()) >= 1

    vol_res = await client.post(f"/api/v1/posts/{post_id}/volunteer", headers=headers)
    assert vol_res.status_code == 200
    assert vol_res.json()["is_volunteering"] is True
    assert vol_res.json()["volunteers_count"] >= 1
```

- [ ] **Step 2: Run test to verify it fails**

Run: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests/test_sos_endpoints.py`
Expected: FAIL (404 / missing endpoints)

- [ ] **Step 3: Implement `server/app/schemas/sos.py` and endpoints in `posts.py`**

- `get_post_sightings(post_id, db)`
- `create_post_sighting(post_id, sighting_in, db, current_user)`
- `toggle_post_volunteer(post_id, db, current_user)`
- Расширить `CommunityPostResponse`: поля `volunteers_count: int = 0`, `sightings_count: int = 0`, `is_volunteering: bool = False`.

- [ ] **Step 4: Run test to verify it passes**

Run: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests/test_sos_endpoints.py`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add server/app/schemas/sos.py server/app/api/v1/endpoints/posts.py server/tests/test_sos_endpoints.py
git commit -m "feat(backend): add endpoints for sightings trail and search crew"
```

---

### Task 3: Бэкенд API для Радара безопасности и консенсуса жителей

**Files:**
- Modify: `server/app/schemas/marker.py`
- Modify: `server/app/api/v1/endpoints/markers.py`
- Test: `server/tests/test_hazard_endpoints.py`

**Interfaces:**
- Produces:
  - `POST /api/v1/markers/{marker_id}/verify` с JSON `{"action": "confirm" | "cleared"}` -> `MapMarkerResponse`

- [ ] **Step 1: Write the failing hazard test**

Create `server/tests/test_hazard_endpoints.py`:
```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_hazard_marker_creation_and_community_verification(client: AsyncClient, normal_user_token: str):
    headers = {"Authorization": f"Bearer {normal_user_token}"}

    res = await client.post(
        "/api/v1/markers",
        headers=headers,
        json={
            "title": "Зона риска: Отрава у тропинки",
            "description": "Рассыпан подозрительный порошок",
            "category": "danger",
            "danger_type": "poison",
            "latitude": 55.0340,
            "longitude": 82.9180,
        },
    )
    assert res.status_code == 201
    marker_id = res.json()["id"]

    conf_res = await client.post(
        f"/api/v1/markers/{marker_id}/verify",
        headers=headers,
        json={"action": "confirm"},
    )
    assert conf_res.status_code == 200
    assert conf_res.json()["confirmations_count"] == 2

    clear_res = await client.post(
        f"/api/v1/markers/{marker_id}/verify",
        headers=headers,
        json={"action": "cleared"},
    )
    assert clear_res.status_code == 200
    assert clear_res.json()["cleared_count"] == 1
```

- [ ] **Step 2: Run test to verify it fails**

Run: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests/test_hazard_endpoints.py`
Expected: FAIL

- [ ] **Step 3: Implement hazard fields and `/verify` endpoint**

В `server/app/schemas/marker.py` добавить поля опасности. В `server/app/api/v1/endpoints/markers.py` добавить роут подтверждения/очистки с авто-архивацией при `cleared_count >= 3`.

- [ ] **Step 4: Run test to verify it passes**

Run: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests/test_hazard_endpoints.py`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add server/app/schemas/marker.py server/app/api/v1/endpoints/markers.py server/tests/test_hazard_endpoints.py
git commit -m "feat(backend): add safety radar verification endpoint"
```

---

### Task 4: Dart-модели для следов питомца, отрядов поиска и зон риска

**Files:**
- Create: `lib/models/sos_sighting_model.dart`
- Modify: `lib/models/map_marker_model.dart`
- Modify: `lib/models/community_post_model.dart`
- Test: `test/models/sos_model_test.dart`

**Interfaces:**
- Produces: `SosSightingModel`, обновленные `MapMarkerModel` и `CommunityPostModel`.

- [ ] **Step 1: Write the failing Flutter model test**

Create `test/models/sos_model_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect_flutter/models/sos_sighting_model.dart';
import 'package:pawconnect_flutter/models/map_marker_model.dart';
import 'package:pawconnect_flutter/models/community_post_model.dart';

void main() {
  test('SosSightingModel parses json correctly', () {
    final json = {
      'id': 'sighting-1',
      'postId': 'post-100',
      'authorName': 'Алексей',
      'latitude': 55.0315,
      'longitude': 82.9215,
      'note': 'Замечен у сквера, бежал на восток',
      'timeAgoStr': '15 мин назад',
      'createdAt': '2026-10-19T10:00:00Z',
    };
    final sighting = SosSightingModel.fromJson(json);
    expect(sighting.id, 'sighting-1');
    expect(sighting.timeAgoStr, '15 мин назад');
  });

  test('MapMarkerModel parses hazard attributes correctly', () {
    final json = {
      'id': 'danger-1',
      'type': 'danger',
      'title': 'Зона риска: Отрава',
      'latitude': 55.0340,
      'longitude': 82.9180,
      'dangerType': 'poison',
      'confirmationsCount': 3,
      'clearedCount': 0,
    };
    final marker = MapMarkerModel.fromJson(json);
    expect(marker.dangerType, 'poison');
    expect(marker.confirmationsCount, 3);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/models/sos_model_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement models**

Создать `SosSightingModel`, обновить `MapMarkerModel` и `CommunityPostModel`.

- [ ] **Step 4: Run test to verify it passes**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/models/sos_model_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/models/ test/models/
git commit -m "feat(frontend): add Dart models for sightings and risk zones"
```

---

### Task 5: Сервисы и Riverpod-провайдеры

**Files:**
- Modify: `lib/services/community_service.dart`
- Modify: `lib/services/map_service.dart`
- Modify: `lib/providers/community_provider.dart`
- Modify: `lib/providers/map_provider.dart`
- Test: `test/services/sos_service_test.dart`

**Interfaces:**
- Produces: `getSightings`, `reportSighting`, `toggleVolunteer`, `verifyHazardMarker`.

- [ ] **Step 1: Write the failing service test**

Create `test/services/sos_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pawconnect_flutter/services/community_service.dart';

void main() {
  test('CommunityService handles toggleVolunteer and reportSighting', () async {
    final dio = Dio();
    final service = CommunityService(dio: dio, allowMockFallback: true);
    final isVolunteering = await service.toggleVolunteer('mock-post-id');
    expect(isVolunteering, isA<bool>());
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/services/sos_service_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement services and providers**

- [ ] **Step 4: Run test to verify it passes**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/services/sos_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/services/ lib/providers/ test/services/
git commit -m "feat(frontend): add Riverpod integration for sightings and safety radar"
```

---

### Task 6: Фирменная карточка «SOS-Маяк» в Ленте (`SosBeaconCard`)

**Files:**
- Create: `lib/features/community/widgets/sos_beacon_card.dart`
- Modify: `lib/features/community/widgets/community_post_card.dart`
- Test: `test/widgets/sos_beacon_card_test.dart`

**Interfaces:**
- Produces: `SosBeaconCard` widget с неоновой спекулярной рамкой тревоги, таймером пропажи, кнопками «Замечен здесь», «Помочь в поиске» и «Радар поиска».

- [ ] **Step 1: Write the failing widget test**

Create `test/widgets/sos_beacon_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect_flutter/models/community_post_model.dart';
import 'package:pawconnect_flutter/features/community/widgets/sos_beacon_card.dart';

void main() {
  testWidgets('SosBeaconCard renders urgent badge, volunteer counter, and action buttons', (tester) async {
    final post = CommunityPostModel(
      id: 'sos-1',
      authorName: 'Дмитрий',
      district: 'Центральный',
      category: 'sos',
      title: 'SOS: Пропал хаски Арчи',
      content: 'Убежал 2 часа назад в Нарымском сквере',
      likesCount: 15,
      isLiked: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SosBeaconCard(
            post: post,
            onSightingTap: () {},
            onVolunteerTap: () {},
            onOpenMapTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('🚨 СРОЧНЫЙ ПОИСК'), findsOneWidget);
    expect(find.text('Замечен здесь'), findsOneWidget);
    expect(find.text('Помочь в поиске'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/widgets/sos_beacon_card_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `SosBeaconCard` and integrate in `CommunityPostCard`**

- [ ] **Step 4: Run test to verify it passes**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/widgets/sos_beacon_card_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/community/widgets/ test/widgets/sos_beacon_card_test.dart
git commit -m "feat(frontend): create specialized Liquid Glass SOS beacon card"
```

---

### Task 7: Интерактивный модал отметки следа «Замечен здесь» (`SosSightingModal`)

**Files:**
- Create: `lib/features/community/widgets/sos_sighting_modal.dart`
- Modify: `lib/features/community/widgets/community_post_card.dart`
- Test: `test/widgets/sos_sighting_modal_test.dart`

**Interfaces:**
- Produces: `SosSightingModal` с выбором времени («Только что», «15–30 мин назад», «1–2 ч назад»), заметкой о направлении и фиксацией геопозиции.

- [ ] **Step 1: Write the failing modal test**

Create `test/widgets/sos_sighting_modal_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect_flutter/features/community/widgets/sos_sighting_modal.dart';

void main() {
  testWidgets('SosSightingModal renders time chips and text field', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SosSightingModal(
            postId: 'post-1',
            petName: 'Арчи',
            onSubmit: (lat, lng, note, timeStr) {},
          ),
        ),
      ),
    );

    expect(find.text('Зафиксировать след питомца'), findsOneWidget);
    expect(find.text('Только что'), findsOneWidget);
    expect(find.text('15–30 мин назад'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/widgets/sos_sighting_modal_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `SosSightingModal`**

- [ ] **Step 4: Run test to verify it passes**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/widgets/sos_sighting_modal_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/community/widgets/sos_sighting_modal.dart test/widgets/sos_sighting_modal_test.dart
git commit -m "feat(frontend): implement 'Замечен здесь' sighting report modal"
```

---

### Task 8: Пины зон риска, HUD-капсула предупреждения и верификация на Яндекс.Картах

**Files:**
- Modify: `lib/features/map/widgets/category_marker_widget.dart`
- Modify: `lib/features/map/widgets/marker_detail_sheet.dart`
- Modify: `lib/features/map/widgets/new_marker_modal.dart`
- Modify: `lib/features/map/widgets/breach_alert_banner.dart`
- Test: `test/widgets/hazard_marker_test.dart`

**Interfaces:**
- Produces: Метки зон риска (☠️ Яд, 🐕‍🦺 Стаи, ⚠️ Осколки), кнопки «Подтверждаю» и «Очищено» в `MarkerDetailSheet`, добавление зон риска в `NewMarkerModal`, предупреждение в `BreachAlertBanner` при приближении к угрозе ближе 300 м.

- [ ] **Step 1: Write the failing hazard widget test**

Create `test/widgets/hazard_marker_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawconnect_flutter/models/map_marker_model.dart';
import 'package:pawconnect_flutter/features/map/widgets/category_marker_widget.dart';

void main() {
  testWidgets('CategoryMarkerWidget renders danger icon for poison', (tester) async {
    final marker = MapMarkerModel(
      id: 'danger-1',
      type: 'danger',
      title: 'Зона риска: Отрава',
      latitude: 55.0340,
      longitude: 82.9180,
      dangerType: 'poison',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryMarkerWidget(marker: marker, onTap: () {}),
        ),
      ),
    );

    expect(find.byType(CategoryMarkerWidget), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/widgets/hazard_marker_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement hazard UI in map widgets**

- [ ] **Step 4: Run test to verify it passes**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test test/widgets/hazard_marker_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/map/widgets/ test/widgets/hazard_marker_test.dart
git commit -m "feat(frontend): integrate safety radar markers, HUD alert, and verification"
```

---

### Task 9: Финальный прогон Quality Gates

- [ ] **Step 1: Run Flutter static analysis**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter analyze`
Expected: 0 issues.

- [ ] **Step 2: Run all Flutter unit and widget tests**

Run: `env -u PUB_HOSTED_URL -u PUB_HOSTED_TOKEN /Users/dmitryborona/flutter_standalone/flutter/bin/flutter test`
Expected: All tests pass.

- [ ] **Step 3: Run all backend pytest tests**

Run: `PYTHONPATH=server ./server/.venv/bin/pytest server/tests`
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: complete phase 1 SOS beacon and safety radar verification"
```
