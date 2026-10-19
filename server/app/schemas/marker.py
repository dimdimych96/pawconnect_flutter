import uuid
from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, ConfigDict, model_validator


class MapMarkerBase(BaseModel):
    title: str
    description: Optional[str] = None
    category: str  # 'dog_park', 'danger', 'lost_pet', 'vet'
    danger_type: Optional[str] = None  # 'poison', 'aggressive_pack', 'broken_glass', 'hazard_other'
    dangerType: Optional[str] = None
    latitude: float
    longitude: float
    photo_url: Optional[str] = None
    photoUrl: Optional[str] = None
    image: Optional[str] = None
    type: Optional[str] = None

    @model_validator(mode="before")
    @classmethod
    def reconcile_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict):
            dt = data.get("danger_type") or data.get("dangerType")
            if dt is not None:
                data["danger_type"] = dt
                data["dangerType"] = dt
            photo = data.get("photo_url") or data.get("photoUrl") or data.get("image")
            if photo is not None:
                data["photo_url"] = photo
                data["photoUrl"] = photo
                data["image"] = photo
            cat = data.get("category") or data.get("type")
            if cat is not None:
                data["category"] = cat
                data["type"] = cat
        return data


class MapMarkerCreate(MapMarkerBase):
    pass


class MapMarkerUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    danger_type: Optional[str] = None
    status: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    photo_url: Optional[str] = None


class MapMarkerVerifyRequest(BaseModel):
    action: str  # 'confirm' or 'cleared'


class MapMarkerResponse(MapMarkerBase):
    id: uuid.UUID
    author_id: Optional[uuid.UUID] = None
    status: str
    confirmations_count: int = 1
    confirmationsCount: Optional[int] = None
    cleared_count: int = 0
    clearedCount: Optional[int] = None
    expires_at: Optional[datetime] = None
    expiresAt: Optional[datetime] = None
    created_at: datetime
    createdAt: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="after")
    def sync_camel_case(self) -> "MapMarkerResponse":
        self.dangerType = self.danger_type
        self.confirmationsCount = self.confirmations_count
        self.clearedCount = self.cleared_count
        self.expiresAt = self.expires_at
        self.createdAt = self.created_at
        self.type = self.category
        self.image = self.photo_url
        self.photoUrl = self.photo_url
        return self
