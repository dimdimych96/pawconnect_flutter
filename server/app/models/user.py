import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, BigInteger
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..db.session import Base


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=True)
    name = Column(String(100), nullable=False)
    role = Column(String(20), default="user", nullable=False)  # 'user', 'moderator', 'admin'
    avatar_url = Column(String(1024), nullable=True)
    telegram_id = Column(BigInteger, unique=True, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    pets = relationship("Pet", back_populates="owner", cascade="all, delete-orphan")
    markers = relationship("MapMarker", back_populates="author")
    posts = relationship("CommunityPost", back_populates="author", cascade="all, delete-orphan")
