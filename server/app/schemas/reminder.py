import uuid
from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel, ConfigDict


class PetReminderBase(BaseModel):
    title: str
    category: str  # 'vaccine', 'pills', 'vet', 'hygiene'
    due_date: date


class PetReminderCreate(PetReminderBase):
    pet_id: uuid.UUID


class PetReminderUpdate(BaseModel):
    title: Optional[str] = None
    category: Optional[str] = None
    due_date: Optional[date] = None
    is_completed: Optional[bool] = None


class PetReminderResponse(PetReminderBase):
    id: uuid.UUID
    pet_id: uuid.UUID
    is_completed: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
