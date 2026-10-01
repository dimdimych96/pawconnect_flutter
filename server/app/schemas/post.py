import uuid
from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


class CommunityPostBase(BaseModel):
    district: str
    category: str
    text: Optional[str] = None
    content: Optional[str] = None
    title: Optional[str] = None
    photo_url: Optional[str] = None
    imageUrl: Optional[str] = None
    pet_name: Optional[str] = None
    petName: Optional[str] = None
    is_official: bool = False
    isOfficial: Optional[bool] = None

    @model_validator(mode="before")
    @classmethod
    def reconcile_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict):
            text = data.get("text") or data.get("content")
            if text is not None:
                data["text"] = text
                data["content"] = text
            photo = data.get("photo_url") or data.get("imageUrl")
            if photo is not None:
                data["photo_url"] = photo
                data["imageUrl"] = photo
            pet = data.get("pet_name") or data.get("petName")
            if pet is not None:
                data["pet_name"] = pet
                data["petName"] = pet
            official = data.get("is_official") if data.get("is_official") is not None else data.get("isOfficial")
            if official is not None:
                data["is_official"] = bool(official)
                data["isOfficial"] = bool(official)
        return data


class CommunityPostCreate(CommunityPostBase):
    @field_validator("text", mode="after")
    @classmethod
    def ensure_text(cls, v: Optional[str]) -> str:
        if not v or not str(v).strip():
            raise ValueError("Текст публикации не может быть пустым")
        return str(v).strip()


class CommunityPostUpdate(BaseModel):
    district: Optional[str] = None
    category: Optional[str] = None
    text: Optional[str] = None
    content: Optional[str] = None
    title: Optional[str] = None
    photo_url: Optional[str] = None
    imageUrl: Optional[str] = None
    pet_name: Optional[str] = None
    petName: Optional[str] = None

    @model_validator(mode="before")
    @classmethod
    def reconcile_update_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict):
            text = data.get("text") or data.get("content")
            if text is not None:
                data["text"] = text
                data["content"] = text
            photo = data.get("photo_url") or data.get("imageUrl")
            if photo is not None:
                data["photo_url"] = photo
                data["imageUrl"] = photo
            pet = data.get("pet_name") or data.get("petName")
            if pet is not None:
                data["pet_name"] = pet
                data["petName"] = pet
        return data


class CommunityPostResponse(CommunityPostBase):
    id: uuid.UUID
    author_id: uuid.UUID
    author_name: Optional[str] = None
    author_avatar: Optional[str] = None
    likes_count: int = 0
    comments_count: int = 0
    is_official: bool = False
    is_liked: bool = False
    is_bookmarked: bool = False
    created_at: datetime

    # CamelCase aliases for Flutter compatibility
    authorId: Optional[str] = None
    authorName: Optional[str] = None
    authorAvatar: Optional[str] = None
    petName: Optional[str] = None
    isOfficial: Optional[bool] = None
    likesCount: Optional[int] = None
    commentsCount: Optional[int] = None
    isLiked: Optional[bool] = None
    isBookmarked: Optional[bool] = None
    content: Optional[str] = None
    imageUrl: Optional[str] = None
    createdAt: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

    def sync(self) -> "CommunityPostResponse":
        self.authorId = str(self.author_id)
        self.authorName = self.author_name
        self.authorAvatar = self.author_avatar
        self.petName = self.pet_name
        self.isOfficial = self.is_official
        self.likesCount = self.likes_count
        self.commentsCount = self.comments_count
        self.content = self.text
        self.imageUrl = self.photo_url
        self.isLiked = self.is_liked
        self.isBookmarked = self.is_bookmarked
        self.createdAt = self.created_at
        return self

    @model_validator(mode="after")
    def sync_camel_case(self) -> "CommunityPostResponse":
        self.authorId = str(self.author_id) if self.authorId is None else self.authorId
        self.authorName = self.author_name if self.authorName is None else self.authorName
        self.authorAvatar = self.author_avatar if self.authorAvatar is None else self.authorAvatar
        self.petName = self.pet_name if self.petName is None else self.petName
        self.isOfficial = self.is_official
        self.likesCount = self.likes_count
        self.commentsCount = self.comments_count
        self.content = self.text if self.content is None else self.content
        self.imageUrl = self.photo_url if self.imageUrl is None else self.imageUrl
        self.isLiked = self.is_liked
        self.isBookmarked = self.is_bookmarked
        self.createdAt = self.created_at if self.createdAt is None else self.createdAt
        return self


class StoryCreate(BaseModel):
    district: str
    media_url: Optional[str] = None
    mediaUrl: Optional[str] = None
    status_text: Optional[str] = None
    statusText: Optional[str] = None
    pet_name: Optional[str] = None
    petName: Optional[str] = None
    is_official: bool = False
    isOfficial: Optional[bool] = None
    visibility: str = "district"

    @model_validator(mode="before")
    @classmethod
    def reconcile_story_aliases(cls, data: Any) -> Any:
        if isinstance(data, dict):
            media = data.get("media_url") or data.get("mediaUrl")
            if media is not None:
                data["media_url"] = media
                data["mediaUrl"] = media
            status = data.get("status_text") or data.get("statusText")
            if status is not None:
                data["status_text"] = status
                data["statusText"] = status
            pet = data.get("pet_name") or data.get("petName")
            if pet is not None:
                data["pet_name"] = pet
                data["petName"] = pet
            official = data.get("is_official") if data.get("is_official") is not None else data.get("isOfficial")
            if official is not None:
                data["is_official"] = bool(official)
                data["isOfficial"] = bool(official)
        return data


class StoryResponse(BaseModel):
    id: uuid.UUID | str
    author_id: Optional[uuid.UUID | str] = None
    author_name: str
    is_official: bool = False
    author_avatar: Optional[str] = None
    pet_name: Optional[str] = None
    district: str
    media_url: str
    status_text: str
    visibility: str = "district"
    created_at: datetime
    expires_at: Optional[datetime] = None
    is_viewed: bool = False

    # CamelCase aliases for Flutter compatibility
    authorId: Optional[str] = None
    authorName: Optional[str] = None
    isOfficial: Optional[bool] = None
    authorAvatar: Optional[str] = None
    petName: Optional[str] = None
    mediaUrl: Optional[str] = None
    statusText: Optional[str] = None
    createdAt: Optional[datetime] = None
    expiresAt: Optional[datetime] = None
    isViewed: Optional[bool] = None

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="after")
    def sync_camel_case(self) -> "StoryResponse":
        if self.authorId is None and self.author_id is not None:
            self.authorId = str(self.author_id)
        if self.authorName is None:
            self.authorName = self.author_name
        if self.isOfficial is None:
            self.isOfficial = self.is_official
        if self.authorAvatar is None:
            self.authorAvatar = self.author_avatar
        if self.petName is None:
            self.petName = self.pet_name
        if self.mediaUrl is None:
            self.mediaUrl = self.media_url
        if self.statusText is None:
            self.statusText = self.status_text
        if self.createdAt is None:
            self.createdAt = self.created_at
        if self.expiresAt is None and self.expires_at is not None:
            self.expiresAt = self.expires_at
        if self.isViewed is None:
            self.isViewed = self.is_viewed
        return self


class CommentCreate(BaseModel):
    text: str = Field(..., min_length=1)

    @field_validator("text")
    @classmethod
    def validate_text(cls, v: str) -> str:
        stripped = v.strip()
        if not stripped:
            raise ValueError("Comment text cannot be empty or whitespace only")
        return stripped


class CommentResponse(BaseModel):
    id: uuid.UUID | str
    post_id: uuid.UUID | str
    author_name: Optional[str] = None
    author_avatar: Optional[str] = None
    is_official: bool = False
    text: str
    likes_count: int = 0
    is_liked: bool = False
    created_at: datetime

    # CamelCase aliases for Flutter compatibility
    postId: Optional[str] = None
    authorName: Optional[str] = None
    authorAvatar: Optional[str] = None
    isOfficial: Optional[bool] = None
    likesCount: Optional[int] = None
    isLiked: Optional[bool] = None
    createdAt: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="after")
    def sync_camel_case(self) -> "CommentResponse":
        if self.postId is None:
            self.postId = str(self.post_id)
        if self.authorName is None:
            self.authorName = self.author_name
        if self.authorAvatar is None:
            self.authorAvatar = self.author_avatar
        if self.isOfficial is None:
            self.isOfficial = self.is_official
        if self.likesCount is None:
            self.likesCount = self.likes_count
        if self.isLiked is None:
            self.isLiked = self.is_liked
        if self.createdAt is None:
            self.createdAt = self.created_at
        return self
