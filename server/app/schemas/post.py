import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class CommunityPostBase(BaseModel):
    district: str
    category: str
    text: str
    photo_url: Optional[str] = None


class CommunityPostCreate(CommunityPostBase):
    pass


class CommunityPostResponse(CommunityPostBase):
    id: uuid.UUID
    author_id: uuid.UUID
    author_name: Optional[str] = None
    author_avatar: Optional[str] = None
    likes_count: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
