# Phase 3 Implementation Plan: Интеллект пород & Профиль здоровья

## 🎯 Цели этапа
Реализовать глубокий породный и медицинский интеллект питомца в PawConnect, переосмыслив функционал пород и здоровья `gavs.app` под дизайн-систему **Apple Liquid Glass 2026**, Zero-Stub архитектуру и потребности собаководов Новосибирска:
1. **Интеллект породы (Breed Intelligence)**: curated база данных пород (нагрузки, риски, питание, темперамент).
2. **Кондиция и вес (Body Condition & Weight Tracker)**: шкала BCS 1-9, расчет суточного калоража, контроль соответствия нормам породы.
3. **Умные вехи здоровья (Smart Health Milestones)**: визуальный трекер сезонной защиты от клещей/блох, комплексной вакцинации и дегельминтизации.
4. **Клуб породы в Ленте**: быстрый фильтр постов и прогулок единомышленников одной породы в районе.

---

## 🛡️ Anti-Clone Маппинг (PawConnect vs Gavs.app)
| Параметр | `gavs.app` (Референс) | **PawConnect (Фаза 3)** |
|:---|:---|:---|
| Каталог пород | 289 плоских карточек со статичным текстом | **«Интеллект породы» в Паспорте**: интерактивный профиль с зонами внимания здоровья, калькулятором питания и активностей |
| Вес собаки | Простая текстовая запись веса | **Шкала кондиции BCS (1–9)**: визуальный спекулярный градиент нормы, расчет идеального веса и суточного калоража |
| Вакцины | Базовый список дат | **«Умные вехи здоровья»**: живой прогресс-бар защиты от клещей/паразитов (напр. Симпарика/Бравекто), таймер ревакцинации, автозаполнение вех в 1 тап |
| Сообщество породы | Отдельный форум | **Породный фильтр в ленте района**: органический срез постов и встреч собачников той же породы |

---

## 🧱 Задачи и порядок реализации

### Task 1: Бэкенд — Модели данных и база пород
- `server/app/models/pet.py`: расширить `Pet` полями:
  - `weight_kg`: Float (текущий вес)
  - `target_weight_kg`: Float (целевой вес)
  - `bcs_score`: Integer (шкала кондиции 1-9)
  - `activity_goal_minutes`: Integer (норма выгула в день)
- `server/app/models/breed.py`: SQLAlchemy модель `Breed` с предзаполненными данными популярных пород (Корги, Золотистый ретривер, Хаски, Французский бульдог, Джек-рассел, Немецкая овчарка, Шпиц, Лабрадор).
- `server/tests/test_breed_models.py`: тест моделей пород и весовых метрик.
- Commit: `feat(models): add breed intelligence and pet health condition models`.

### Task 2: Бэкенд — API эндпоинты пород и профиля здоровья
- `server/app/schemas/breed.py`: схемы `BreedResponse`, `HealthWatchoutSchema`, `HealthProfileResponse`, `PetHealthUpdate`.
- `server/app/api/v1/endpoints/breeds.py`:
  - `GET /api/v1/breeds` — каталог пород с поиском;
  - `GET /api/v1/breeds/{breed_id}` — детальный породный интеллект;
- `server/app/api/v1/endpoints/health.py`:
  - `GET /api/v1/pets/{pet_id}/health-profile` — сводка здоровья, калорий и вех;
  - `PUT /api/v1/pets/{pet_id}/condition` — обновление веса и BCS;
  - `POST /api/v1/pets/{pet_id}/apply-standard-milestones` — генерация ветеринарных вех.
- `server/app/api/v1/api.py`: регистрация роутеров.
- `server/tests/test_breed_endpoints.py`: интеграционные тесты.
- Commit: `feat(api): add breed intelligence and pet health endpoints`.

### Task 3: Фронтенд — Модели данных и калькуляторы
- `lib/models/breed_model.dart`:
  - `BreedModel`, `HealthWatchoutModel`, `BodyConditionScore` (BCS 1-9 с цветовой дифференциацией и интерпретацией).
  - Калькулятор метаболических калорий: `calculateDailyKcal(weightKg, ageYears, activityMinutes, bcsScore)`.
- `lib/models/pet_health_profile_model.dart`:
  - `PetHealthProfileModel`, `ParasiteProtectionModel`, `VaccinationMilestoneModel`.
- `test/models/breed_models_test.dart`: юнит-тесты сериализации и калькулятора калорий/кондиции.
- Commit: `feat(models): add breed model, health profile, and BCS calorie calculator`.

### Task 4: Фронтенд — Сервис здоровья и Riverpod Notifier
- `lib/services/health_service.dart`: Dio-клиент к эндпоинтам пород и здоровья с Zero-Stub поддержкой и оффлайн-фоллбеком для Центрального Новосибирска.
- `lib/providers/health_provider.dart`: `HealthState` и `HealthNotifier` с методами загрузки породы, обновления веса, применения вех.
- `test/services/health_service_test.dart` & `test/providers/health_provider_test.dart`.
- Commit: `feat(providers): add health service and Riverpod health profile notifier`.

### Task 5: Фронтенд — Виджеты Apple Liquid Glass
- `lib/features/profile/widgets/body_condition_weight_card.dart`:
  - Интерактивная шкала BCS 1-9 с подсвечиванием идеальной кондиции (4-5);
  - Текущий вес питомца, отклонение от нормы породы, кнопка быстрого замера.
- `lib/features/profile/widgets/smart_health_milestones_card.dart`:
  - Индикатор сезонной защиты от клещей/блох (прогресс-бар оставшихся дней);
  - Ежегодная вакцинация и дегельминтизация;
  - Кнопка автозаполнения вех в 1 тап.
- `lib/features/profile/widgets/breed_intelligence_card.dart`:
  - Карточка интеллекта породы: активность, темперамент, зоны внимания со значками рисков;
  - Суточная норма корма и калорий.
- `test/widgets/health_cards_test.dart`: виджет-тесты для трех карточек.
- Commit: `feat(profile): add Liquid Glass health, weight BCS, and breed intelligence cards`.

### Task 6: Интеграция в Pet Profile Screen & Community Feed
- Обновить `lib/features/profile/pet_profile_screen.dart`:
  - Встроить `BodyConditionWeightCard`, `SmartHealthMilestonesCard`, `BreedIntelligenceCard`.
- Обновить `lib/features/community/community_screen.dart` / чипы:
  - Добавить фильтр «Клуб породы» в ленту.
- Commit: `feat(profile): integrate breed intelligence and health milestones into pet passport`.

### Task 7: Quality Gate & Верификация
- `flutter analyze` — 0 issues.
- `PYTHONPATH=server ./server/.venv/bin/pytest server/tests` — 100% pass.
- `flutter test` — 100% pass.
