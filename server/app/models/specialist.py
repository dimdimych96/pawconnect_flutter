from datetime import datetime, timezone
from typing import List, Dict, Any
from sqlalchemy import Column, String, Text, Float, Integer, Boolean, DateTime, JSON
from ..db.session import Base

class Specialist(Base):
    __tablename__ = "specialists"

    id = Column(String(100), primary_key=True)
    name = Column(String(200), nullable=False, index=True)
    avatar_url = Column(String(1024), nullable=True)
    profession = Column(String(50), nullable=False, index=True)  # 'cynologist', 'dogsitter', 'groomer', 'vet_specialist'
    profession_title = Column(String(150), nullable=False)
    rating = Column(Float, default=5.0, nullable=False, index=True)
    reviews_count = Column(Integer, default=0, nullable=False)
    experience_years = Column(Integer, default=1, nullable=False)
    price_from = Column(Integer, nullable=False)
    price_unit = Column(String(50), default="₽ / занятие", nullable=False)
    is_verified = Column(Boolean, default=True, nullable=False, index=True)
    district = Column(String(100), nullable=False, index=True)
    address = Column(String(250), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    bio = Column(Text, nullable=True)
    phone = Column(String(50), nullable=True)
    telegram = Column(String(100), nullable=True)
    services = Column(JSON, default=list, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

CURATED_SPECIALISTS: List[Dict[str, Any]] = [
    {
        "id": "spec-anna-melnikova",
        "name": "Анна Мельникова",
        "avatar_url": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80",
        "profession": "cynologist",
        "profession_title": "Кинолог-зоопсихолог",
        "rating": 4.95,
        "reviews_count": 48,
        "experience_years": 7,
        "price_from": 1500,
        "price_unit": "₽ / занятие",
        "is_verified": True,
        "district": "Заельцовский",
        "address": "Красный проспект, 182",
        "latitude": 55.0620,
        "longitude": 82.9150,
        "bio": "Гуманная дрессировка щенков и взрослых собак без аверсивных методов. Коррекция страхов, тревоги разлуки и натяжения поводка.",
        "phone": "+7 (913) 450-12-88",
        "telegram": "@anna_dogpsychology",
        "services": [
            {"title": "Индивидуальная тренировка", "price": 1500},
            {"title": "Консультация зоопсихолога", "price": 2000},
        ],
    },
    {
        "id": "spec-dmitry-vet",
        "name": "Клиника «ВетЛекарь»",
        "avatar_url": "https://images.unsplash.com/photo-1628009368231-7bb7cfcb0def?auto=format&fit=crop&w=256&q=80",
        "profession": "vet_specialist",
        "profession_title": "Ветеринарный центр 24/7",
        "rating": 4.90,
        "reviews_count": 112,
        "experience_years": 12,
        "price_from": 900,
        "price_unit": "₽ / прием",
        "is_verified": True,
        "district": "Центральный",
        "address": "ул. Фрунзе, 57",
        "latitude": 55.0380,
        "longitude": 82.9280,
        "bio": "Круглосуточный стационар, цифровая рентгенография, УЗИ экспертного класса и экстренная хирургия.",
        "phone": "+7 (383) 220-44-11",
        "telegram": "@vetlekar_nsk",
        "services": [
            {"title": "Первичный осмотр терапевта", "price": 900},
            {"title": "Вакцинация комплексная", "price": 1800},
        ],
    },
    {
        "id": "spec-elena-dogsitter",
        "name": "Елена Смирнова",
        "avatar_url": "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=256&q=80",
        "profession": "dogsitter",
        "profession_title": "Догситтер & Передержка",
        "rating": 4.98,
        "reviews_count": 34,
        "experience_years": 4,
        "price_from": 850,
        "price_unit": "₽ / сутки",
        "is_verified": True,
        "district": "Советский",
        "address": "Морской проспект, 22",
        "latitude": 54.8480,
        "longitude": 83.0980,
        "bio": "Уютная домашняя передержка в Академгородке рядом с лесом. Никаких клеток. Фото- и видеоотчеты 3 раза в день.",
        "phone": "+7 (923) 115-77-90",
        "telegram": "@elena_petsitting",
        "services": [
            {"title": "Суточная домашняя передержка", "price": 850},
            {"title": "Дневной выгул и присмотр (1 час)", "price": 450},
        ],
    },
    {
        "id": "spec-dog-grooming",
        "name": "Студия груминга «PawChic»",
        "avatar_url": "https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=256&q=80",
        "profession": "groomer",
        "profession_title": "Мастера бережного груминга",
        "rating": 4.92,
        "reviews_count": 67,
        "experience_years": 5,
        "price_from": 1800,
        "price_unit": "₽ / комплекс",
        "is_verified": True,
        "district": "Ленинский",
        "address": "проспект Карла Маркса, 30",
        "latitude": 54.9880,
        "longitude": 82.8950,
        "bio": "Бережный груминг без наркоза и фиксаторов. Экспресс-линька, гигиеническая стрижка, spa-уход с озоном.",
        "phone": "+7 (952) 880-33-22",
        "telegram": "@pawchic_grooming",
        "services": [
            {"title": "Полный гигиенический комплекс", "price": 1800},
            {"title": "Экспресс-линька для хаски и корги", "price": 2500},
        ],
    },
    {
        "id": "spec-maksim-cynologist",
        "name": "Максим Громов",
        "avatar_url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=256&q=80",
        "profession": "cynologist",
        "profession_title": "Инструктор ОКД и УГС",
        "rating": 4.88,
        "reviews_count": 29,
        "experience_years": 9,
        "price_from": 1300,
        "price_unit": "₽ / занятие",
        "is_verified": True,
        "district": "Октябрьский",
        "address": "ул. Кирова, 113",
        "latitude": 55.0120,
        "longitude": 82.9550,
        "bio": "Нормативная дрессировка (ОКД, УГС), подготовка к выставкам, адаптация собак из приюта.",
        "phone": "+7 (913) 770-90-55",
        "telegram": "@gromov_dogs",
        "services": [
            {"title": "Курс послушания УГС", "price": 1300},
            {"title": "Тестирование поведения", "price": 1500},
        ],
    },
]
