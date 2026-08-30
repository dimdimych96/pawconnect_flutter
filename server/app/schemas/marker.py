import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class MapMarkerBase(BaseModel):
    title: str
    description: Optional[str] = None
    category: str  # 'dog_park', 'danger', 'lost_pet', 'vet'
    latitude: float
    longitude: float
    photo_url: Optional[str] = None


class MapMarkerCreate(MapMarkerBase):
    pass


class MapMarkerUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    status: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    photo_url: Optional[str] = None


class MapMarkerResponse(MapMarkerBase):
    id: uuid.UUID
    author_id: Optional[uuid.UUID] = None
    status: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
