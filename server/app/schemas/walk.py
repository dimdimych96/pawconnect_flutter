import uuid
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict, Field


class WalkStartRequest(BaseModel):
    pet_id: uuid.UUID
    walk_mode: str = Field(default="open", description="'open', 'private', or 'training'")
    latitude: float
    longitude: float
    note: Optional[str] = None


class WalkStopRequest(BaseModel):
    pet_id: Optional[uuid.UUID] = None


class WalkSessionResponse(BaseModel):
    id: uuid.UUID
    pet_id: uuid.UUID
    user_id: uuid.UUID
    walk_mode: str
    latitude: float
    longitude: float
    started_at: datetime
    ended_at: Optional[datetime] = None
    is_active: bool
    note: Optional[str] = None
    pet_name: Optional[str] = None
    pet_breed: Optional[str] = None
    pet_avatar: Optional[str] = None
    temperament: Optional[str] = None
    is_private: bool = False

    model_config = ConfigDict(from_attributes=True)


class WalkingPetNearbyResponse(BaseModel):
    pet_id: uuid.UUID
    pet_name: str
    pet_breed: Optional[str] = None
    pet_avatar: Optional[str] = None
    owner_name: str
    temperament: str
    walk_mode: str
    latitude: float
    longitude: float
    distance_meters: int
    walk_started_at: datetime
    minutes_walking: int
    is_private: bool = False

    model_config = ConfigDict(from_attributes=True)


class WalkInvitationCreate(BaseModel):
    to_pet_id: uuid.UUID
    message: Optional[str] = None


class WalkInvitationResponse(BaseModel):
    id: uuid.UUID
    from_user_id: uuid.UUID
    to_pet_id: uuid.UUID
    status: str
    message: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class PetTemperamentUpdate(BaseModel):
    temperament: str
