import uuid
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ....db.session import get_db
from ....models.user import User
from ....models.pet import Pet
from ....models.reminder import PetReminder
from ....schemas.reminder import PetReminderCreate, PetReminderUpdate, PetReminderResponse
from ...deps import get_current_user

router = APIRouter()


@router.get("", response_model=List[PetReminderResponse])
async def get_reminders(
    pet_id: Optional[uuid.UUID] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    # Join with pet to ensure only reminders for the current user's pets are returned
    stmt = select(PetReminder).join(Pet, PetReminder.pet_id == Pet.id).where(Pet.owner_id == current_user.id)
    if pet_id:
        stmt = stmt.where(PetReminder.pet_id == pet_id)

    result = await db.execute(stmt)
    reminders = result.scalars().all()
    return [PetReminderResponse.model_validate(r) for r in reminders]


@router.post("", response_model=PetReminderResponse, status_code=status.HTTP_201_CREATED)
async def create_reminder(
    reminder_in: PetReminderCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    # Verify pet ownership
    pet_res = await db.execute(select(Pet).where(Pet.id == reminder_in.pet_id, Pet.owner_id == current_user.id))
    pet = pet_res.scalar_one_or_none()
    if not pet:
        raise HTTPException(status_code=404, detail="Питомец не найден")

    reminder = PetReminder(
        pet_id=reminder_in.pet_id,
        title=reminder_in.title,
        category=reminder_in.category,
        due_date=reminder_in.due_date,
        is_completed=False,
    )
    db.add(reminder)
    await db.commit()
    await db.refresh(reminder)
    return PetReminderResponse.model_validate(reminder)


@router.patch("/{reminder_id}", response_model=PetReminderResponse)
async def update_reminder(
    reminder_id: uuid.UUID,
    reminder_in: PetReminderUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    stmt = select(PetReminder).join(Pet, PetReminder.pet_id == Pet.id).where(
        PetReminder.id == reminder_id,
        Pet.owner_id == current_user.id,
    )
    result = await db.execute(stmt)
    reminder = result.scalar_one_or_none()
    if not reminder:
        raise HTTPException(status_code=404, detail="Напоминание не найдено")

    update_data = reminder_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(reminder, field, value)

    await db.commit()
    await db.refresh(reminder)
    return PetReminderResponse.model_validate(reminder)


@router.delete("/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_reminder(
    reminder_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    stmt = select(PetReminder).join(Pet, PetReminder.pet_id == Pet.id).where(
        PetReminder.id == reminder_id,
        Pet.owner_id == current_user.id,
    )
    result = await db.execute(stmt)
    reminder = result.scalar_one_or_none()
    if not reminder:
        raise HTTPException(status_code=404, detail="Напоминание не найдено")

    await db.delete(reminder)
    await db.commit()
