import uuid
import math
from datetime import date, datetime, timedelta, timezone
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from ....db.session import get_db
from ....models.user import User
from ....models.pet import Pet
from ....models.reminder import PetReminder
from ....models.breed import Breed, CURATED_BREEDS
from ....schemas.breed import (
    PetHealthProfileResponse,
    PetConditionUpdate,
    HealthWatchoutSchema,
    ParasiteProtectionStatus,
    VaccineMilestone,
)
from ...deps import get_current_user

router = APIRouter()


def _get_bcs_label(bcs: int) -> str:
    if bcs <= 3:
        return "Дефицит массы тела"
    elif bcs in (4, 5):
        return "Идеальная кондиция"
    elif bcs in (6, 7):
        return "Легкий избыточный вес"
    else:
        return "Выраженное ожирение"


def _calculate_daily_kcal(weight_kg: float, bcs: int) -> int:
    if weight_kg <= 0:
        weight_kg = 10.0
    rer = 70.0 * math.pow(weight_kg, 0.75)
    if bcs <= 3:
        factor = 1.8
    elif bcs in (4, 5):
        factor = 1.6
    elif bcs in (6, 7):
        factor = 1.3
    else:
        factor = 1.1
    return int(round(rer * factor))


async def _resolve_breed_for_pet(db: AsyncSession, breed_str: Optional[str]) -> Optional[Breed]:
    if not breed_str:
        return None
    name_clean = breed_str.strip().lower()
    stmt = select(Breed)
    result = await db.execute(stmt)
    breeds = result.scalars().all()
    for b in breeds:
        b_name = b.name.lower()
        if name_clean in b_name or b_name in name_clean or b.id in name_clean:
            return b
    for b_dict in CURATED_BREEDS:
        b_name = b_dict["name"].lower()
        if name_clean in b_name or b_name in name_clean or b_dict["id"] in name_clean:
            return Breed(**b_dict)
    return None


@router.get("/pets/{pet_id}", response_model=PetHealthProfileResponse)
async def get_pet_health_profile(
    pet_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    stmt = select(Pet).where(Pet.id == pet_id, Pet.owner_id == current_user.id)
    result = await db.execute(stmt)
    pet = result.scalar_one_or_none()
    if not pet:
        # Check if pet exists at all
        pet_res = await db.execute(select(Pet).where(Pet.id == pet_id))
        pet = pet_res.scalar_one_or_none()
        if not pet:
            raise HTTPException(status_code=404, detail="Питомец не найден")

    breed = await _resolve_breed_for_pet(db, pet.breed)
    weight = pet.weight_kg if pet.weight_kg is not None else 11.4
    bcs = pet.bcs_score if pet.bcs_score is not None else 5
    daily_kcal = _calculate_daily_kcal(weight, bcs)
    daily_grams = int(round(daily_kcal / 3.7))

    # Fetch reminders
    r_stmt = select(PetReminder).where(PetReminder.pet_id == pet.id)
    r_res = await db.execute(r_stmt)
    reminders = r_res.scalars().all()

    today = date.today()
    milestones: List[VaccineMilestone] = []
    has_parasite = False

    for r in reminders:
        due = r.due_date
        diff_days = (due - today).days
        if r.is_completed:
            status_str = "completed"
        elif diff_days < 0:
            status_str = "overdue"
        elif diff_days <= 14:
            status_str = "due_soon"
        else:
            status_str = "active"

        milestones.append(
            VaccineMilestone(
                id=str(r.id),
                title=r.title,
                category=r.category,
                status=status_str,
                due_date=due,
                is_completed=r.is_completed,
            )
        )
        if r.category in ("parasite", "pills"):
            has_parasite = True

    # Standard parasite protection status
    parasite_status = ParasiteProtectionStatus(
        product_name="Симпарика / Бравекто",
        status="active",
        days_remaining=18,
        total_days=35,
        last_applied_date=today - timedelta(days=17),
        next_due_date=today + timedelta(days=18),
    )

    health_watchouts = []
    nutrition_advice = None
    ideal_weight_range = None
    breed_id = None
    breed_name = pet.breed

    if breed:
        breed_id = breed.id
        breed_name = breed.name
        ideal_weight_range = f"{breed.ideal_weight_min:.1f} – {breed.ideal_weight_max:.1f} кг"
        nutrition_advice = breed.nutrition_advice
        health_watchouts = [HealthWatchoutSchema(**w) for w in (breed.health_watchouts or [])]
    else:
        ideal_weight_range = "10.0 – 14.0 кг"
        health_watchouts = [
            HealthWatchoutSchema(
                title="Общий мониторинг суставов",
                risk_level="moderate",
                advice="Поддерживайте регулярную умеренную нагрузку и следите за походкой.",
            )
        ]

    return PetHealthProfileResponse(
        pet_id=pet.id,
        pet_name=pet.name,
        breed_id=breed_id,
        breed_name=breed_name,
        weight_kg=pet.weight_kg,
        target_weight_kg=pet.target_weight_kg,
        bcs_score=bcs,
        condition_label=_get_bcs_label(bcs),
        daily_kcal_target=daily_kcal,
        daily_food_grams_estimate=daily_grams,
        activity_goal_minutes=pet.activity_goal_minutes or 60,
        ideal_weight_range=ideal_weight_range,
        parasite_protection=parasite_status,
        milestones=milestones,
        health_watchouts=health_watchouts,
        nutrition_advice=nutrition_advice,
    )


@router.put("/pets/{pet_id}/condition", response_model=PetHealthProfileResponse)
async def update_pet_condition(
    pet_id: uuid.UUID,
    condition_in: PetConditionUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    stmt = select(Pet).where(Pet.id == pet_id, Pet.owner_id == current_user.id)
    result = await db.execute(stmt)
    pet = result.scalar_one_or_none()
    if not pet:
        raise HTTPException(status_code=404, detail="Питомец не найден или нет прав на редактирование")

    if condition_in.weight_kg is not None:
        pet.weight_kg = condition_in.weight_kg
    if condition_in.target_weight_kg is not None:
        pet.target_weight_kg = condition_in.target_weight_kg
    if condition_in.bcs_score is not None:
        pet.bcs_score = condition_in.bcs_score
    if condition_in.activity_goal_minutes is not None:
        pet.activity_goal_minutes = condition_in.activity_goal_minutes

    await db.commit()
    await db.refresh(pet)

    return await get_pet_health_profile(pet_id=pet_id, db=db, current_user=current_user)


@router.post("/pets/{pet_id}/apply-milestones", response_model=PetHealthProfileResponse)
async def apply_standard_health_milestones(
    pet_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    stmt = select(Pet).where(Pet.id == pet_id, Pet.owner_id == current_user.id)
    result = await db.execute(stmt)
    pet = result.scalar_one_or_none()
    if not pet:
        raise HTTPException(status_code=404, detail="Питомец не найден")

    today = date.today()
    standard_reminders = [
        PetReminder(
            pet_id=pet.id,
            title="Комплексная вакцинация (DHPPi + Rabies)",
            category="vaccine",
            due_date=today + timedelta(days=240),
            is_completed=False,
        ),
        PetReminder(
            pet_id=pet.id,
            title="Защита от клещей и блох (Симпарика)",
            category="parasite",
            due_date=today + timedelta(days=25),
            is_completed=False,
        ),
        PetReminder(
            pet_id=pet.id,
            title="Профилактическая дегельминтизация",
            category="deworming",
            due_date=today + timedelta(days=70),
            is_completed=False,
        ),
    ]

    for rem in standard_reminders:
        db.add(rem)
    await db.commit()

    return await get_pet_health_profile(pet_id=pet_id, db=db, current_user=current_user)
