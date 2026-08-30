import uuid
from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel, ConfigDict


class PetBase(BaseModel):
    name: str
    breed: Optional[str] = None
    avatar_url: Optional[str] = None
    birth_date: Optional[date] = None
    tracker_type: str = "gps_collar"
    device_imei: Optional[str] = None
    beacon_uuid: Optional[str] = None
    safe_zone_radius_meters: int = 150
    safe_zone_latitude: Optional[float] = None
    safe_zone_longitude: Optional[float] = None


class PetCreate(PetBase):
    pass


class PetUpdate(BaseModel):
    name: Optional[str] = None
    breed: Optional[str] = None
    avatar_url: Optional[str] = None
    tracker_type: Optional[str] = None
    device_imei: Optional[str] = None
    beacon_uuid: Optional[str] = None
    battery_level: Optional[int] = None
    is_lost: Optional[bool] = None
    safe_zone_radius_meters: Optional[int] = None
    safe_zone_latitude: Optional[float] = None
    safe_zone_longitude: Optional[float] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class PetTelemetryUpdate(BaseModel):
    latitude: float
    longitude: float
    battery_level: Optional[int] = None


class PetResponse(PetBase):
    id: uuid.UUID
    owner_id: uuid.UUID
    battery_level: int
    is_lost: bool
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    last_seen_at: Optional[datetime] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
