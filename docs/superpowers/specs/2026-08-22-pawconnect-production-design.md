# Спецификация и Архитектура Системы: PawConnect Production (Ревизия 2.0)

**Дата**: 22 августа 2026 г.  
**Статус**: Утверждено и верифицировано архитектурным аудитом  
**Стек**: Flutter (Клиент) + FastAPI / Python 3.12 (Бэкенд) + PostgreSQL 16 (PostGIS) + Redis 7 + Docker Compose + Nginx  

---

## 1. Концепция и Бизнес-Цели

**PawConnect** — это комплексная кроссплатформенная экосистема для владельцев домашних животных:
1. **Безопасность и Трекинг (Гибридный TrackerDevice)**:
   - Поддержка как **GPS/GSM ошейников** (прямая передача координат через GSM/LTE-M), так и **Bluetooth Low Energy маячков** (BLE iBeacon/Eddystone радар + анонимная краудсорсинговая сеть «Find My Pets»).
   - Настройка безопасной геозоны (Safe Zone Radius) с мгновенным аварийным алертом (Breach Alert) при побеге.
2. **Интерактивная карта и комьюнити**:
   - Дог-парки, площадки для выгула, ветклиники.
   - Зоны опасности (догхантеры/яды/реагенты) с Push-оповещением соседей в радиусе 3 км.
   - SOS-объявления о пропаже с мгновенной публикацией без задержек.
3. **Цифровой вет-паспорт и здоровье**:
   - Календарь прививок, обработка от клещей и глистов, график процедур.

---

## 2. Архитектура Системы

```
┌────────────────────────────────────────────────────────────────────────┐
│                      PawConnect Client (Flutter)                       │
│  - BLE Scanner (flutter_blue_plus) + GPS Tracking (geolocator)         │
│  - Map Engine (flutter_map + CartoDB Dark Matter)                      │
│  - State Management (Riverpod + StateNotifier)                         │
│  - Apple Liquid Glass UI (Obsidian #0A0A0C, Glass Overlays)            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTPS / WSS
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   Nginx Reverse Proxy & SSL Gateway                    │
│  - Let's Encrypt SSL (HTTPS / WSS)                                     │
│  - Раздача и кэширование WebP медиа (/media/avatars, /media/posts)     │
│  - Rate Limiting и защита от DDoS                                      │
└───────────────────┬────────────────────────────────┬───────────────────┘
                    │ REST API                       │ WebSockets (Foreground Only)
                    ▼                                ▼
┌───────────────────────────────────┐ ┌──────────────────────────────────┐
│      FastAPI App (Python 3.12)    │ │   Live Telemetry & Radar WSS     │
│  - Pydantic v2 schemas            │ │  - Crowdsourced Beacon Tracking  │
│  - Async SQLAlchemy 2.0           │ │  - Real-time Safe Zone Breaches  │
│  - Alembic Migrations             │ │  - Pub/Sub message broadcast     │
│  - JWT Auth (Access + Refresh)    │ │  - Privacy-preserving reporter   │
└─────────────────┬─────────────────┘ └──────────────────┬───────────────┘
                  │                                      │
                  ▼                                      ▼
┌───────────────────────────────────┐ ┌──────────────────────────────────┐
│      PostgreSQL 16 + PostGIS      │ │          Redis Cache             │
│  - Spatial indexes (ST_DWithin)   │ │  - Active Live Telemetry Cache   │
│  - GIST on markers & pets location│ │  - User Sessions & Rate Limits   │
│  - Foreign Key B-Tree indexes     │ │  - Pub/Sub Channel Broker        │
└───────────────────────────────────┘ └──────────────────────────────────┘
```

---

## 3. Схема Базы Данных (PostgreSQL 16 + PostGIS)

```sql
-- Расширение PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Таблица пользователей
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255),
    name VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'user', -- 'user', 'moderator', 'admin'
    avatar_url TEXT,
    telegram_id BIGINT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Таблица питомцев и трекеров (Гибрид: GPS + BLE)
CREATE TABLE pets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    breed VARCHAR(100),
    avatar_url TEXT,
    birth_date DATE,
    tracker_type VARCHAR(20) DEFAULT 'gps_collar', -- 'gps_collar', 'ble_beacon'
    device_imei VARCHAR(64) UNIQUE,
    beacon_uuid VARCHAR(64) UNIQUE,
    battery_level INT DEFAULT 100,
    is_lost BOOLEAN DEFAULT FALSE,
    safe_zone_radius_meters INT DEFAULT 150,
    safe_zone_center GEOGRAPHY(Point, 4326),
    location GEOGRAPHY(Point, 4326),
    last_seen_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_pets_owner_id ON pets(owner_id);
CREATE INDEX idx_pets_location ON pets USING GIST(location);

-- Таблица меток на карте с PostGIS геометрией
CREATE TABLE map_markers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES users(id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL, -- 'dog_park', 'danger', 'lost_pet', 'vet'
    status VARCHAR(30) DEFAULT 'approved', -- 'pending', 'approved', 'rejected'
    location GEOGRAPHY(Point, 4326) NOT NULL,
    photo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_markers_author_id ON map_markers(author_id);
CREATE INDEX idx_map_markers_location ON map_markers USING GIST(location);

-- Таблица постов комьюнити
CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    district VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    text TEXT NOT NULL,
    photo_url TEXT,
    likes_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_posts_author_id ON community_posts(author_id);

-- Таблица вет-напоминаний
CREATE TABLE pet_reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    due_date DATE NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_reminders_pet_id ON pet_reminders(pet_id);
```

---

## 4. Конфигурация Развертывания (Docker Compose)

```yaml
version: '3.8'

services:
  db:
    image: postgis/postgis:16-3.4-alpine
    restart: always
    environment:
      POSTGRES_DB: pawconnect_db
      POSTGRES_USER: paw_admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"

  redis:
    image: redis:7.2-alpine
    restart: always
    command: redis-server --save 60 1 --loglevel warning
    volumes:
      - redisdata:/data
    ports:
      - "127.0.0.1:6379:6379"

  api:
    build: ./server
    restart: always
    environment:
      DATABASE_URL: postgresql+asyncpg://paw_admin:${DB_PASSWORD}@db:5432/pawconnect_db
      REDIS_URL: redis://redis:6379/0
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - db
      - redis
    ports:
      - "127.0.0.1:8000:8000"

  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./server/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./server/media:/var/www/media:ro
      - certbot-etc:/etc/letsencrypt
    depends_on:
      - api

volumes:
  pgdata:
  redisdata:
  certbot-etc:
```
