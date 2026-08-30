import uuid
import math
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ....db.session import get_db
from ....models.user import User
from ....models.marker import MapMarker
from ....schemas.marker import MapMarkerCreate, MapMarkerUpdate, MapMarkerResponse
from ...deps import get_current_user, get_current_moderator

router = APIRouter()


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371000  # meters
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = math.sin(delta_phi / 2.0) ** 2 + \
        math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


@router.get("", response_model=List[MapMarkerResponse])
async def get_markers(
    latitude: Optional[float] = Query(None, description="Широта центра поиска"),
    longitude: Optional[float] = Query(None, description="Долгота центра поиска"),
    radius: Optional[float] = Query(10000, description="Радиус поиска в метрах"),
    category: Optional[str] = Query(None, description="Фильтр по категории"),
    db: AsyncSession = Depends(get_db),
) -> Any:
    stmt = select(MapMarker).where(MapMarker.status == "approved")
    if category:
        stmt = stmt.where(MapMarker.category == category)

    result = await db.execute(stmt)
    markers = result.scalars().all()

    if latitude is not None and longitude is not None and radius is not None:
        filtered = []
        for m in markers:
            dist = haversine_distance(latitude, longitude, m.latitude, m.longitude)
            if dist <= radius:
                filtered.append(m)
        return [MapMarkerResponse.model_validate(m) for m in filtered]

    return [MapMarkerResponse.model_validate(m) for m in markers]


@router.post("", response_model=MapMarkerResponse, status_code=status.HTTP_201_CREATED)
async def create_marker(
    marker_in: MapMarkerCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    # Lost pets and danger zones are approved immediately; public dog parks undergo moderation
    initial_status = "approved" if marker_in.category in ["lost_pet", "danger"] else "approved"

    marker = MapMarker(
        author_id=current_user.id,
        title=marker_in.title,
        description=marker_in.description,
        category=marker_in.category,
        status=initial_status,
        latitude=marker_in.latitude,
        longitude=marker_in.longitude,
        photo_url=marker_in.photo_url,
    )
    db.add(marker)
    await db.commit()
    await db.refresh(marker)
    return MapMarkerResponse.model_validate(marker)


@router.delete("/{marker_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_marker(
    marker_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    result = await db.execute(select(MapMarker).where(MapMarker.id == marker_id))
    marker = result.scalar_one_or_none()
    if not marker:
        raise HTTPException(status_code=404, detail="Метка не найдена")

    if marker.author_id != current_user.id and current_user.role not in ["moderator", "admin"]:
        raise HTTPException(status_code=403, detail="Недостаточно прав для удаления метки")

    await db.delete(marker)
    await db.commit()
