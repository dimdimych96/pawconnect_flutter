import uuid
from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ....db.session import get_db
from ....models.user import User
from ....models.pet import Pet
from ....schemas.pet import PetCreate, PetUpdate, PetResponse, PetTelemetryUpdate
from ...deps import get_current_user

router = APIRouter()


@router.get("", response_model=List[PetResponse])
async def get_my_pets(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    result = await db.execute(select(Pet).where(Pet.owner_id == current_user.id))
    pets = result.scalars().all()
    return [PetResponse.model_validate(p) for p in pets]


@router.post("", response_model=PetResponse, status_code=status.HTTP_201_CREATED)
async def create_pet(
    pet_in: PetCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    pet = Pet(
        owner_id=current_user.id,
        name=pet_in.name,
        breed=pet_in.breed,
        avatar_url=pet_in.avatar_url or "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=400&q=80",
        birth_date=pet_in.birth_date,
        tracker_type=pet_in.tracker_type,
        device_imei=pet_in.device_imei,
        beacon_uuid=pet_in.beacon_uuid,
        safe_zone_radius_meters=pet_in.safe_zone_radius_meters,
        safe_zone_latitude=pet_in.safe_zone_latitude,
        safe_zone_longitude=pet_in.safe_zone_longitude,
        latitude=pet_in.safe_zone_latitude,
        longitude=pet_in.safe_zone_longitude,
    )
    db.add(pet)
    await db.commit()
    await db.refresh(pet)
    return PetResponse.model_validate(pet)


@router.get("/{pet_id}", response_model=PetResponse)
async def get_pet(
    pet_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    result = await db.execute(select(Pet).where(Pet.id == pet_id))
    pet = result.scalar_one_or_none()
    if not pet:
        raise HTTPException(status_code=404, detail="Питомец не найден")
    return PetResponse.model_validate(pet)


@router.patch("/{pet_id}", response_model=PetResponse)
async def update_pet(
    pet_id: uuid.UUID,
    pet_in: PetUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    result = await db.execute(select(Pet).where(Pet.id == pet_id, Pet.owner_id == current_user.id))
    pet = result.scalar_one_or_none()
    if not pet:
        raise HTTPException(status_code=404, detail="Питомец не найден или у вас нет прав на редактирование")

    update_data = pet_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(pet, field, value)

    await db.commit()
    await db.refresh(pet)
    return PetResponse.model_validate(pet)


@router.delete("/{pet_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_pet(
    pet_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    result = await db.execute(select(Pet).where(Pet.id == pet_id, Pet.owner_id == current_user.id))
    pet = result.scalar_one_or_none()
    if not pet:
        raise HTTPException(status_code=404, detail="Питомец не найден")

    await db.delete(pet)
    await db.commit()
