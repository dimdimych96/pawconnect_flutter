import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Float, Boolean, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..db.session import Base


class WalkSession(Base):
    """Represents an active or historical pet walk session («Радар прогулок»)."""
    __tablename__ = "walk_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    pet_id = Column(UUID(as_uuid=True), ForeignKey("pets.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    walk_mode = Column(String(30), default="open", nullable=False)  # 'open', 'private', 'training'
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    started_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    ended_at = Column(DateTime(timezone=True), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False, index=True)
    note = Column(String(255), nullable=True)

    pet = relationship("Pet", back_populates="walk_sessions")
    user = relationship("User")


class WalkInvitation(Base):
    """Direct one-tap invitation from one owner to another walking companion."""
    __tablename__ = "walk_invitations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    from_user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    to_pet_id = Column(UUID(as_uuid=True), ForeignKey("pets.id", ondelete="CASCADE"), nullable=False, index=True)
    status = Column(String(20), default="pending", nullable=False)  # 'pending', 'accepted', 'declined'
    message = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    from_user = relationship("User")
    to_pet = relationship("Pet")
