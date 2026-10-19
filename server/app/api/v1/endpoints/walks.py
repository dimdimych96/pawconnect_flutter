import uuid
import math
from datetime import datetime, timezone
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from sqlalchemy.orm import selectinload

from ....db.session import get_db
from ....models.user import User
from ....models.pet import Pet
from ....models.walk import WalkSession, WalkInvitation
from ....schemas.walk import (
    WalkStartRequest,
    WalkStopRequest,
    WalkSessionResponse,
    WalkingPetNearbyResponse,
    WalkInvitationCreate,
    WalkInvitationResponse,
    PetTemperamentUpdate,
)
from ...deps import get_current_user

router = APIRouter()


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> int:
    """Calculate the great-circle distance between two points in meters."""
    R = 6371000
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)
    a = math.sin(delta_phi / 2.0) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return int(R * c)


def fuzz_coordinates(lat: float, lon: float, seed_str: str) -> tuple[float, float]:
    """Applies a deterministic ~100-150m fuzzing offset to protect user privacy in 'private' walk mode."""
    h = abs(hash(seed_str))
    offset_lat = (((h % 100) - 50) / 100.0) * 0.0012
    offset_lon = ((((h // 100) % 100) - 50) / 100.0) * 0.0018
    return round(lat + offset_lat, 5), round(lon + offset_lon, 5)


@router.post("/start", response_model=WalkSessionResponse, status_code=status.HTTP_201_CREATED)
async def start_walk(
    request: WalkStartRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    # 1. Verify pet belongs to user
    result = await db.execute(select(Pet).where(Pet.id == request.pet_id, Pet.owner_id == current_user.id))
    pet = result.scalar_one_or_none()
    if not pet:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Питомец не найден")

    # 2. Deactivate any prior active sessions for this user/pet
    prior_sessions = await db.execute(
        select(WalkSession).where(WalkSession.pet_id == pet.id, WalkSession.is_active == True)
    )
    for s in prior_sessions.scalars().all():
        s.is_active = False
        s.ended_at = datetime.now(timezone.utc)

    # 3. Create new walk session
    now = datetime.now(timezone.utc)
    new_session = WalkSession(
        pet_id=pet.id,
        user_id=current_user.id,
        walk_mode=request.walk_mode,
        latitude=request.latitude,
        longitude=request.longitude,
        started_at=now,
        is_active=True,
        note=request.note,
    )
    db.add(new_session)

    # 4. Update pet live telemetry & walk status
    pet.is_walking = True
    pet.walk_mode = request.walk_mode
    pet.walk_started_at = now
    pet.latitude = request.latitude
    pet.longitude = request.longitude
    pet.last_seen_at = now

    await db.commit()
    await db.refresh(new_session)

    return WalkSessionResponse(
        id=new_session.id,
        pet_id=pet.id,
        user_id=current_user.id,
        walk_mode=new_session.walk_mode,
        latitude=new_session.latitude,
        longitude=new_session.longitude,
        started_at=new_session.started_at,
        ended_at=new_session.ended_at,
        is_active=new_session.is_active,
        note=new_session.note,
        pet_name=pet.name,
        pet_breed=pet.breed,
        pet_avatar=pet.avatar_url,
        temperament=pet.temperament,
        is_private=(new_session.walk_mode == "private"),
    )


@router.post("/stop", response_model=dict)
async def stop_walk(
    request: WalkStopRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    # Find active walk for user
    query = select(WalkSession).where(
        WalkSession.user_id == current_user.id,
        WalkSession.is_active == True,
    )
    if request.pet_id:
        query = query.where(WalkSession.pet_id == request.pet_id)

    result = await db.execute(query)
    sessions = result.scalars().all()
    if not sessions:
        return {"status": "no_active_walk", "message": "Нет активной прогулки"}

    now = datetime.now(timezone.utc)
    for s in sessions:
        s.is_active = False
        s.ended_at = now

        # Update Pet
        pet_res = await db.execute(select(Pet).where(Pet.id == s.pet_id))
        pet = pet_res.scalar_one_or_none()
        if pet:
            pet.is_walking = False
            pet.walk_started_at = None

    await db.commit()
    return {"status": "stopped", "message": "Прогулка успешно завершена"}


@router.get("/active", response_model=Optional[WalkSessionResponse])
async def get_active_walk(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    result = await db.execute(
        select(WalkSession)
        .where(WalkSession.user_id == current_user.id, WalkSession.is_active == True)
        .options(selectinload(WalkSession.pet))
        .order_by(WalkSession.started_at.desc())
    )
    session = result.scalars().first()
    if not session:
        return None

    pet = session.pet
    return WalkSessionResponse(
        id=session.id,
        pet_id=session.pet_id,
        user_id=session.user_id,
        walk_mode=session.walk_mode,
        latitude=session.latitude,
        longitude=session.longitude,
        started_at=session.started_at,
        ended_at=session.ended_at,
        is_active=session.is_active,
        note=session.note,
        pet_name=pet.name if pet else None,
        pet_breed=pet.breed if pet else None,
        pet_avatar=pet.avatar_url if pet else None,
        temperament=pet.temperament if pet else None,
        is_private=(session.walk_mode == "private"),
    )


@router.get("/nearby", response_model=List[WalkingPetNearbyResponse])
async def get_nearby_walks(
    latitude: float = Query(..., description="Текущая широта"),
    longitude: float = Query(..., description="Текущая долгота"),
    radius_meters: int = Query(default=3000, description="Радиус поиска в метрах"),
    db: AsyncSession = Depends(get_db),
) -> Any:
    # Query all pets currently walking
    result = await db.execute(
        select(Pet)
        .where(Pet.is_walking == True)
        .options(selectinload(Pet.owner))
    )
    pets = result.scalars().all()

    now = datetime.now(timezone.utc)
    companions: List[WalkingPetNearbyResponse] = []

    for p in pets:
        if p.latitude is None or p.longitude is None:
            continue

        p_lat, p_lng = p.latitude, p.longitude
        is_private = (p.walk_mode == "private")

        # Apply privacy fuzzing if private walk mode
        if is_private:
            p_lat, p_lng = fuzz_coordinates(p_lat, p_lng, str(p.id))

        dist = haversine_distance(latitude, longitude, p_lat, p_lng)
        if dist <= radius_meters:
            walk_start = p.walk_started_at or now
            if walk_start.tzinfo is None:
                walk_start = walk_start.replace(tzinfo=timezone.utc)
            minutes_walk = max(1, int((now - walk_start).total_seconds() / 60))

            companions.append(
                WalkingPetNearbyResponse(
                    pet_id=p.id,
                    pet_name=p.name,
                    pet_breed=p.breed,
                    pet_avatar=p.avatar_url,
                    owner_name=p.owner.name if p.owner else "Владелец",
                    temperament=p.temperament,
                    walk_mode=p.walk_mode,
                    latitude=p_lat,
                    longitude=p_lng,
                    distance_meters=dist,
                    walk_started_at=walk_start,
                    minutes_walking=minutes_walk,
                    is_private=is_private,
                )
            )

    # Sort by nearest
    companions.sort(key=lambda x: x.distance_meters)
    return companions


@router.post("/invite", response_model=WalkInvitationResponse, status_code=status.HTTP_201_CREATED)
async def send_walk_invitation(
    request: WalkInvitationCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    # Verify target pet exists
    pet_res = await db.execute(select(Pet).where(Pet.id == request.to_pet_id))
    target_pet = pet_res.scalar_one_or_none()
    if not target_pet:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Питомец не найден")

    invitation = WalkInvitation(
        from_user_id=current_user.id,
        to_pet_id=request.to_pet_id,
        status="pending",
        message=request.message,
    )
    db.add(invitation)
    await db.commit()
    await db.refresh(invitation)

    return WalkInvitationResponse.model_validate(invitation)


@router.put("/pets/{pet_id}/temperament", response_model=dict)
async def update_pet_temperament(
    pet_id: uuid.UUID,
    request: PetTemperamentUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    allowed_temperaments = {"playful", "calm", "energetic", "shy", "reactive"}
    if request.temperament not in allowed_temperaments:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Недопустимый темперамент. Выберите из: {', '.join(allowed_temperaments)}",
        )

    result = await db.execute(select(Pet).where(Pet.id == pet_id, Pet.owner_id == current_user.id))
    pet = result.scalar_one_or_none()
    if not pet:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Питомец не найден")

    pet.temperament = request.temperament
    await db.commit()

    return {
        "status": "updated",
        "pet_id": str(pet.id),
        "temperament": pet.temperament,
    }
