import uuid
from datetime import datetime, timezone, timedelta
from sqlalchemy import Column, String, DateTime, ForeignKey, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..db.session import Base


class CommunityStory(Base):
    __tablename__ = "community_stories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    is_official = Column(Boolean, default=False, nullable=False)
    author_name = Column(String(100), nullable=False)
    author_avatar = Column(String(1024), nullable=True)
    pet_name = Column(String(100), nullable=True)
    district = Column(String(100), nullable=False, index=True)
    media_url = Column(String(1024), nullable=False)
    status_text = Column(String(255), nullable=False)
    visibility = Column(String(50), default="district", nullable=False)  # 'district', 'public', 'followers'
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    expires_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc) + timedelta(hours=24),
        nullable=False,
    )

    author = relationship("User")
