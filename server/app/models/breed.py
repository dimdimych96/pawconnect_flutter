import uuid
from typing import List, Dict, Any
from sqlalchemy import Column, String, Integer, Float, JSON, Text
from ..db.session import Base


class Breed(Base):
    __tablename__ = "breeds"

    id = Column(String(50), primary_key=True)  # e.g. 'corgi', 'golden_retriever'
    name = Column(String(100), nullable=False, index=True)
    name_en = Column(String(100), nullable=True)
    category = Column(String(50), nullable=False)
    origin = Column(String(100), nullable=False)
    ideal_weight_min = Column(Float, nullable=False)
    ideal_weight_max = Column(Float, nullable=False)
    activity_min_minutes = Column(Integer, nullable=False)
    default_temperament = Column(String(30), default="playful", nullable=False)
    health_watchouts = Column(JSON, nullable=False, default=list)
    nutrition_advice = Column(Text, nullable=False)
    description = Column(Text, nullable=True)


CURATED_BREEDS: List[Dict[str, Any]] = [
    {
        "id": "corgi",
        "name": "Вельш-корги пемброк",
        "name_en": "Welsh Corgi Pembroke",
        "category": "Пастушьи",
        "origin": "Великобритания",
        "ideal_weight_min": 10.0,
        "ideal_weight_max": 12.5,
        "activity_min_minutes": 60,
        "default_temperament": "playful",
        "health_watchouts": [
          {
            "title": "Позвоночник и суставы (IVDD)",
            "risk_level": "high",
            "advice": "Избегайте прыжков с диванов и крутых лестниц. Укрепляйте мышечный корсет плаванием и равномерной ходьбой."
          },
          {
            "title": "Склонность к набору веса",
            "risk_level": "high",
            "advice": "Даже +1 кг дает избыточную нагрузку на спину. Взвешивайте порции на кухонных весах."
          }
        ],
        "nutrition_advice": "Склонны к попрошайничеству и перееданию. Рекомендуется рацион с белком 24–28% и добавками Омега-3 для гибкости суставов.",
        "description": "Энергичная, жизнерадостная пастушья порода с высоким интеллектом и добрым нравом."
    },
    {
        "id": "golden_retriever",
        "name": "Золотистый ретривер",
        "name_en": "Golden Retriever",
        "category": "Ретриверы",
        "origin": "Великобритания",
        "ideal_weight_min": 27.0,
        "ideal_weight_max": 34.0,
        "activity_min_minutes": 90,
        "default_temperament": "calm",
        "health_watchouts": [
          {
            "title": "Дисплазия тазобедренных суставов",
            "risk_level": "high",
            "advice": "Рентген-скрининг суставов до 2 лет. Добавки с глюкозамином и хондроитином."
          },
          {
            "title": "Чувствительная кожа и аллергии",
            "risk_level": "moderate",
            "advice": "Регулярный уход за шерстью, избегать сырости подшерстка после купания."
          }
        ],
        "nutrition_advice": "Сбалансированное питание для крупных пород. Контроль калорийности для предотвращения раннего износа суставов.",
        "description": "Дружелюбный компаньон с мягким характером, обожающий игры с апортом и воду."
    },
    {
        "id": "husky",
        "name": "Сибирский хаски",
        "name_en": "Siberian Husky",
        "category": "Ездовые",
        "origin": "Сибирь / Россия",
        "ideal_weight_min": 20.0,
        "ideal_weight_max": 28.0,
        "activity_min_minutes": 120,
        "default_temperament": "energetic",
        "health_watchouts": [
          {
            "title": "Высокая потребность в выгуле",
            "risk_level": "high",
            "advice": "Не менее 2 часов активного бега в день. При недостатке нагрузки склонны к побегам и деструктиву."
          },
          {
            "title": "Здоровье глаз",
            "risk_level": "moderate",
            "advice": "Генетическая предрасположенность к ювенильной катаракте. Ежегодный осмотр офтальмолога."
          }
        ],
        "nutrition_advice": "Быстрый метаболизм. Рацион с повышенным содержанием правильных жиров (18–22%) и качественного протеина.",
        "description": "Неутомимая северная собака с сильным стайным инстинктом и любовью к длинным дистанциям."
    },
    {
        "id": "french_bulldog",
        "name": "Французский бульдог",
        "name_en": "French Bulldog",
        "category": "Компаньоны",
        "origin": "Франция",
        "ideal_weight_min": 9.0,
        "ideal_weight_max": 14.0,
        "activity_min_minutes": 40,
        "default_temperament": "calm",
        "health_watchouts": [
          {
            "title": "Брахицефалический синдром (БОС)",
            "risk_level": "high",
            "advice": "Строго беречь от перегрева выше +22°C. Использовать анатомическую шлейку вместо ошейника."
          },
          {
            "title": "Гигиена кожных складок",
            "risk_level": "moderate",
            "advice": "Протирать складки на мордочке хлоргексидином 0.05% во избежание опрелостей."
          }
        ],
        "nutrition_advice": "Легкоусвояемый монобелковый рацион во избежание пищевой аллергии и метеоризма.",
        "description": "Преданный городской компаньон с харизматичной внешностью и спокойным нравом."
    },
    {
        "id": "jack_russell",
        "name": "Джек-рассел терьер",
        "name_en": "Jack Russell Terrier",
        "category": "Терьеры",
        "origin": "Великобритания",
        "ideal_weight_min": 5.5,
        "ideal_weight_max": 7.5,
        "activity_min_minutes": 90,
        "default_temperament": "energetic",
        "health_watchouts": [
          {
            "title": "Вывих надколенника (пателла)",
            "risk_level": "moderate",
            "advice": "Контроль высоты прыжков, поддержание сухожилий и мускулатуры задних лап."
          },
          {
            "title": "Сверхвысокая возбудимость",
            "risk_level": "moderate",
            "advice": "Нуждается в интеллектуальных задачах (поисковые игры, аджилити)."
          }
        ],
        "nutrition_advice": "Энергонасыщенный рацион с высокой усвояемостью для поддержания активного метаболизма.",
        "description": "Вулкан энергии в компактном теле, охотник и азартный исследователь."
    },
    {
        "id": "german_shepherd",
        "name": "Немецкая овчарка",
        "name_en": "German Shepherd",
        "category": "Служебные",
        "origin": "Германия",
        "ideal_weight_min": 28.0,
        "ideal_weight_max": 40.0,
        "activity_min_minutes": 90,
        "default_temperament": "calm",
        "health_watchouts": [
          {
            "title": "Дисплазия суставов",
            "risk_level": "high",
            "advice": "Беречь щенка от скользких полов, контроль веса в период интенсивного роста."
          },
          {
            "title": "Риск заворота желудка",
            "risk_level": "high",
            "advice": "Никаких активных пробежек за 1 час до и 1.5 часа после кормления. Кормить 2 раза в день."
          }
        ],
        "nutrition_advice": "Корм премиум-класса для крупных рабочих собак с добавками для суставов и связок.",
        "description": "Универсальная служебная порода с выдающимся интеллектом, преданностью и рабочей выдержкой."
    }
]
