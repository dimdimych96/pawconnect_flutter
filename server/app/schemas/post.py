import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, model_validator


class CommunityPostBase(BaseModel):
    district: str
    category: str
    text: str
    title: Optional[str] = None
    photo_url: Optional[str] = None
    pet_name: Optional[str] = None


class CommunityPostCreate(CommunityPostBase):
    pass


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

    @model_validator(mode="after")
    def sync_camel_case(self) -> "CommunityPostResponse":
        if self.authorName is None:
            self.authorName = self.author_name
        if self.authorAvatar is None:
            self.authorAvatar = self.author_avatar
        if self.petName is None:
            self.petName = self.pet_name
        if self.isOfficial is None:
            self.isOfficial = self.is_official
        if self.likesCount is None:
            self.likesCount = self.likes_count
        if self.commentsCount is None:
            self.commentsCount = self.comments_count
        if self.content is None:
            self.content = self.text
        if self.imageUrl is None:
            self.imageUrl = self.photo_url
        if self.isLiked is None:
            self.isLiked = self.is_liked
        if self.isBookmarked is None:
            self.isBookmarked = self.is_bookmarked
        if self.createdAt is None:
            self.createdAt = self.created_at
        return self


class StoryResponse(BaseModel):
    id: uuid.UUID | str
    author_name: str
    is_official: bool = False
    author_avatar: Optional[str] = None
    pet_name: Optional[str] = None
    district: str
    media_url: str
    status_text: str
    created_at: datetime
    is_viewed: bool = False

    # CamelCase aliases for Flutter compatibility
    authorName: Optional[str] = None
    isOfficial: Optional[bool] = None
    authorAvatar: Optional[str] = None
    petName: Optional[str] = None
    mediaUrl: Optional[str] = None
    statusText: Optional[str] = None
    createdAt: Optional[datetime] = None
    isViewed: Optional[bool] = None

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="after")
    def sync_camel_case(self) -> "StoryResponse":
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
        if self.isViewed is None:
            self.isViewed = self.is_viewed
        return self


class CommentCreate(BaseModel):
    text: str


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
