import uuid
from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, ConfigDict, model_validator


class SOSSightingCreate(BaseModel):
    latitude: float
    longitude: float
    note: Optional[str] = None
    time_ago_str: Optional[str] = None
    timeAgoStr: Optional[str] = None
    photo_url: Optional[str] = None
    photoUrl: Optional[str] = None

    @model_validator(mode="before")
    @classmethod
    def reconcile_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict):
            t = data.get("time_ago_str") or data.get("timeAgoStr")
            if t is not None:
                data["time_ago_str"] = t
                data["timeAgoStr"] = t
            p = data.get("photo_url") or data.get("photoUrl")
            if p is not None:
                data["photo_url"] = p
                data["photoUrl"] = p
        return data


class SOSSightingResponse(BaseModel):
    id: uuid.UUID
    post_id: uuid.UUID
    postId: Optional[str] = None
    author_id: Optional[uuid.UUID] = None
    authorId: Optional[str] = None
    author_name: Optional[str] = None
    authorName: Optional[str] = None
    author_avatar: Optional[str] = None
    authorAvatar: Optional[str] = None
    latitude: float
    longitude: float
    note: Optional[str] = None
    time_ago_str: Optional[str] = None
    timeAgoStr: Optional[str] = None
    photo_url: Optional[str] = None
    photoUrl: Optional[str] = None
    created_at: datetime
    createdAt: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="after")
    def sync_camel_case(self) -> "SOSSightingResponse":
        self.postId = str(self.post_id) if self.postId is None else self.postId
        self.authorId = str(self.author_id) if self.author_id and self.authorId is None else self.authorId
        self.authorName = self.author_name if self.authorName is None else self.authorName
        self.authorAvatar = self.author_avatar if self.authorAvatar is None else self.authorAvatar
        self.timeAgoStr = self.time_ago_str if self.timeAgoStr is None else self.timeAgoStr
        self.photoUrl = self.photo_url if self.photoUrl is None else self.photoUrl
        self.createdAt = self.created_at if self.createdAt is None else self.createdAt
        return self


class SOSVolunteerStatusResponse(BaseModel):
    is_volunteering: bool
    isVolunteering: Optional[bool] = None
    volunteers_count: int
    volunteersCount: Optional[int] = None

    @model_validator(mode="after")
    def sync_camel_case(self) -> "SOSVolunteerStatusResponse":
        self.isVolunteering = self.is_volunteering
        self.volunteersCount = self.volunteers_count
        return self
