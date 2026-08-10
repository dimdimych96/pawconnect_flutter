# PawConnect — Полная ТЗ-спецификация для Вайбкодинга на Flutter (Solo AI-Dev)

> **Цель промпта**: Этот документ предназначен в качестве системного контекста для ИИ-агентов (**Cursor, Windsurf, Antigravity, Claude Code, ChatGPT**) для молниеносной разработки мобильного приложения **PawConnect** на **Flutter** силами одного разработчика (вайбкодинг).

---

## ⚡ 1. Идеология Вайбкодинга (Принципы разработки)

1. **NO `build_runner` (Ноль кодогенерации)**:
   * ❌ **ЗАПРЕЩЕНО использовать**: `freezed`, `json_serializable`, `hive_generator`, `@riverpod` генераторы аннотаций.
   * ✅ **ПРИЧИНА**: Генерация кода ломает контекст ИИ, создает конфликты кэша и замедляет Hot Reload в 5 раз. Все модели пишутся с простыми ручными методами `fromJson` и `toJson`.
2. **Карты на `flutter_map` (OpenStreetMap / CartoDB)**:
   * ❌ **НЕ использовать `google_maps_flutter`**: Требует платных ключей Google Cloud, настройки AndroidManifest/AppDelegate и сложной конвертации виджетов в растровые картинки.
   * ✅ **ИСПОЛЬЗОВАТЬ `flutter_map`**: Позволяет вставлять ЛЮБОЙ Flutter-виджет (анимированную собачку с размытием и неоновым пульсом) прямо в маркер за 1 строчку кода: `Marker(child: MyPulseDogAvatarWidget())`.
3. **Минималистичное хранилище**:
   * Использовать `shared_preferences` для пользовательских настроек и `flutter_secure_storage` для Bearer-токена авторизации.

---

## 🛠 2. Оптимизированный Вайб-Стек

```
 📱 UI Framework     : Flutter 3.x (Dart 3.x)
 🧠 State            : flutter_riverpod (без кодогенераторов, через StateNotifier / Notifier)
 🗺 Maps             : flutter_map + latlong2 (CartoDB Dark Matter Tiles)
 🌐 Network          : dio (Интерцепторы токенов + Retry)
 🧭 Routing          : go_router (StatefulShellRoute для сохранения вкладок)
 💾 Storage          : shared_preferences + flutter_secure_storage
 🎨 UI & Icons       : lucide_icons / feather_icons + BackdropFilter (Glassmorphism)
```

---

## 🎨 3. Дизайн-система (Apple Liquid Glass)

Приложение выполнено в темной глассморфик-эстетике в стиле iOS:

* **Цветовая палитра**:
  * `Основной фон`: Глубокий обсидиан `#0A0A0C`
  * `Плашки / Карточки`: Темный сланец `#1C1C1E` / Полупрозрачный `#121216`
  * `Стеклянный бордюр`: Тонкий `#FFFFFF` с `opacity: 0.08` – `0.12`
  * `Основной акцент (Безопасность / Успех)`: Весенний зеленый `#30D158`
  * `Тревога (Нарушение геозоны / SOS)`: Системный красный `#FF453A`
  * `Информация / Действие (Компаньоны)`: Системный синий `#0A84FF`
  * `Предупреждение / Оффлайн`: Системный желтый `#FFD60A`

* **Шрифтовая сетка (iOS Dynamic Type)**:
  * `Large Title`: 34pt, Bold
  * `Title 1`: 28pt, Bold
  * `Headline`: 17pt, Semi-Bold
  * `Body`: 17pt, Regular
  * `Subhead`: 15pt, Regular
  * `Footnote`: 13pt, Semi-Bold
  * `Caption 1`: 12pt, Regular

---

## 📲 4. Структура 4-х главных вкладок

```
Root Shell (go_router StatefulShellRoute)
 ├── Вкладка 1: Карта (`/map`)
 ├── Вкладка 2: Паспорт питомца и Ошейник (`/profile`)
 ├── Вкладка 3: Сообщество / Лента постов (`/community`)
 └── Вкладка 4: Настройки (`/settings`)
```

### Вкладка 1: Интерактивная Карта (`MapScreen`)
* **Сворачиваемый поиск Apple Maps**:
  * Свернут: Кнопка 56x56px (`borderRadius: 12`) с лупой вверху слева.
  * Развернут: Высота 56px, `borderRadius: 12`, на весь экран (`left: 16, right: 16`), текст Body 17pt, серый крестик.
* **Капсулы фильтров**:
  * Фильтры (`Все`, `Потеряшки [Красный]`, `Площадки [Зеленый]`, `Компаньоны [Синий]`).
  * Неактивные: Стекло с `BackdropFilter`.
  * Активные: Цвет категории (`#30D158`, `#FF453A`, `#0A84FF`) с контрастным текстом.
* **Маркеры на `flutter_map`**:
  * Метки `lost_pet`, `playground`, `companion`.
  * Ошейник питомца: Аватар с пульсирующим неоновым кольцом (`#30D158` – норма, `#FF453A` – тревога).
* **Геозона**:
  * Полупрозрачный круг `CircleMarker`.
  * Режим редактирования: Клик по карте переносит центр, кнопки `-` / `+` меняют радиус.
* **Трек прогулок**:
  * Полилиния `PolylineMarker` за 24 часа.
* **Управление**:
  * FAB `+`: Публикация нового объявления.
  * Кнопка «Где Макс?»: Центрирование на ошейнике.
  * Капсула зума (`+` / `-`).

### Вкладка 2: Паспорт питомца и Ошейник (`PetProfileScreen`)
* **Паспорт**: Аватар собаки с индикатором безопасности, кличка, порода, возраст, чип.
* **Ошейник**: Батарея (`batteryLevel%`), статус сети, изменение радиуса геозоны, кнопка настройки на карте.
* **Вет-календарь**: Подгрузка из `/api/v1/reminders`, переключатели тумблеров, добавление процедур.

### Вкладка 3: Лента Сообщества (`CommunityScreen`)
* **Фильтры**: 10 районов Новосибирска + категории (`Общее`, `🏥 Здоровье`, `🦮 Дрессировка`, `🚨 SOS`).
* **Посты**: Левый цветной бордюр, аватар автора, текст, анимированный лайк.
* **Новый пост**: Модалка создания поста.

### Вкладка 4: Настройки (`SettingsScreen`)
* Профиль владельца (имя, аватар), разрешение пушей, диагностика, выход.

---

## 📦 5. Простые Dart-модели (БЕЗ CodeGen)

```dart
// Маркер карты
class MapMarkerModel {
  final String id;
  final String type; // 'lost_pet', 'playground', 'companion'
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final String? breed;
  final String? age;
  final String? image;
  final DateTime createdAt;

  MapMarkerModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.latitude,
    required this.longitude,
    this.breed,
    this.age,
    this.image,
    required this.createdAt,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapMarkerModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'lost_pet',
      title: json['title'] ?? '',
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      breed: json['breed'],
      age: json['age'],
      image: json['image'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'breed': breed,
    'age': age,
    'image': image,
  };
}

// GPS Ошейник
class GpsDeviceModel {
  final String imei;
  final String petName;
  final double latitude;
  final double longitude;
  final bool isBreached;
  final double? safeZoneLatitude;
  final double? safeZoneLongitude;
  final double? safeZoneRadius;
  final int batteryLevel;
  final bool isConnected;
  final String? photoUrl;

  GpsDeviceModel({
    required this.imei,
    required this.petName,
    required this.latitude,
    required this.longitude,
    required this.isBreached,
    this.safeZoneLatitude,
    this.safeZoneLongitude,
    this.safeZoneRadius,
    required this.batteryLevel,
    required this.isConnected,
    this.photoUrl,
  });

  factory GpsDeviceModel.fromJson(Map<String, dynamic> json) {
    return GpsDeviceModel(
      imei: json['imei'] ?? '',
      petName: json['petName'] ?? 'Пёс',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isBreached: json['isBreached'] ?? false,
      safeZoneLatitude: json['safeZoneLatitude'] != null ? (json['safeZoneLatitude'] as num).toDouble() : null,
      safeZoneLongitude: json['safeZoneLongitude'] != null ? (json['safeZoneLongitude'] as num).toDouble() : null,
      safeZoneRadius: json['safeZoneRadius'] != null ? (json['safeZoneRadius'] as num).toDouble() : null,
      batteryLevel: json['batteryLevel'] ?? 80,
      isConnected: json['isConnected'] ?? true,
      photoUrl: json['photoUrl'],
    );
  }
}
```

---

## 🌐 6. Контракт REST API

| Метод | Эндпоинт | Описание |
| :--- | :--- | :--- |
| `POST` | `/api/v1/auth/request-code` | Запрос SMS-кода верификации |
| `POST` | `/api/v1/auth/verify-code` | Проверка кода и получение Bearer токена |
| `GET` | `/api/v1/auth/profile` | Загрузка профиля владельца |
| `PATCH` | `/api/v1/auth/profile` | Обновление имени и аватара владельца |
| `GET` | `/api/v1/map/markers?lat=..&lng=..&radius=..` | Список меток карты |
| `POST` | `/api/v1/map/markers` | Создание новой метки |
| `GET` | `/api/v1/gps/active` | Трекеры и статус геозоны |
| `PATCH` | `/api/v1/gps/safe-zone` | Изменение центра (`lat`,`lng`) и радиуса (`radius`) |
| `GET` | `/api/v1/gps/history?imei=..` | История точек трекера за 24 часа |
| `GET` | `/api/v1/reminders` | Напоминания вет-календаря |
| `POST` | `/api/v1/reminders` | Новое напоминание |
| `PATCH` | `/api/v1/reminders/:id` | Изменение статуса процедуры |
| `GET` | `/api/v1/posts?district=..&category=..` | Лента постов с фильтрами |
| `POST` | `/api/v1/posts` | Публикация нового поста |

---

## 🚀 7. Прямые указания для ИИ-Агента (Vibe-Rules)

1. **Пиши код без генераторов**: Никаких `.g.dart` или `.freezed.dart` файлов.
2. **Используй `flutter_map`**: Все маркеры на карте возвращай как чистые виджеты Flutter (`Marker(child: ...)`).
3. **Не используй прозрачные/белые фоны**: Используй `#0A0A0C` для `Scaffold` и `#1C1C1E` для карточек.
4. **Стеклянные оверлеи**: Применяй `BackdropFilter` с `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` только для верхних панелей поиска и плашек меню.
5. **Оффлайн демо-режим**: При ошибке от `dio` всегда отлавливай исключение и возвращай локальный `MockData` список, чтобы интерфейс всегда можно было протестировать на лету.
6. **Гибкость API Контракта**: Указанный REST API контракт является базовым ориентиром под существующий Next.js бэкенд. При необходимости реализации дополнительных элементов интерфейса ты имеешь право добавлять новые поля в JSON-ответы (например, `batteryLevel`, `isConnected`, `photoUrl`), сохраняя базовые наименования ключевых сущностей и полей (`latitude`, `longitude`, `isBreached`, `imei`).
