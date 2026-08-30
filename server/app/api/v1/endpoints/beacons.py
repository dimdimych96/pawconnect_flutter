from datetime import datetime, timezone
from typing import Any
from pydantic import BaseModel
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ....db.session import get_db
from ....models.pet import Pet
from .markers import haversine_distance

router = APIRouter()


class BeaconReport(BaseModel):
    beacon_uuid: str
    latitude: float
    longitude: float
    rssi: int
    tx_power: int = -59


@router.post("/report", status_code=status.HTTP_200_OK)
async def report_found_beacon(
    report: BeaconReport,
    db: AsyncSession = Depends(get_db),
) -> Any:
    # 1. Look up pet by beacon_uuid
    result = await db.execute(select(Pet).where(Pet.beacon_uuid == report.beacon_uuid))
    pet = result.scalar_one_or_none()
    if not pet:
        # Silently accept unknown beacons without error (Privacy preservation)
        return {"status": "received"}

    # 2. Anti-Spoofing / Velocity Check
    if pet.latitude is not None and pet.longitude is not None and pet.last_seen_at is not None:
        time_diff_sec = (datetime.now(timezone.utc) - pet.last_seen_at).total_seconds()
        if time_diff_sec > 0:
            dist_meters = haversine_distance(pet.latitude, pet.longitude, report.latitude, report.longitude)
            speed_kmh = (dist_meters / time_diff_sec) * 3.6
            if speed_kmh > 150:  # Physically impossible animal speed (> 150 km/h)
                return {"status": "ignored", "reason": "abnormal velocity"}

    # 3. Update pet location anonymously
    pet.latitude = report.latitude
    pet.longitude = report.longitude
    pet.last_seen_at = datetime.now(timezone.utc)

    # 4. Check safe-zone breach
    if pet.safe_zone_latitude is not None and pet.safe_zone_longitude is not None and pet.safe_zone_radius_meters:
        dist_from_home = haversine_distance(
            report.latitude,
            report.longitude,
            pet.safe_zone_latitude,
            pet.safe_zone_longitude,
        )
        if dist_from_home > pet.safe_zone_radius_meters:
            pet.is_lost = True

    await db.commit()
    return {"status": "success", "pet_name": pet.name, "is_lost": pet.is_lost}
