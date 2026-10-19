import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, Float, DateTime, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..db.session import Base


class MapMarker(Base):
    __tablename__ = "map_markers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(50), nullable=False, index=True)  # 'dog_park', 'danger', 'lost_pet', 'vet'
    danger_type = Column(String(50), nullable=True, index=True)  # 'poison', 'aggressive_pack', 'broken_glass', 'hazard_other'
    status = Column(String(30), default="approved", nullable=False, index=True)  # 'pending', 'approved', 'rejected'
    
    latitude = Column(Float, nullable=False, index=True)
    longitude = Column(Float, nullable=False, index=True)
    photo_url = Column(String(1024), nullable=True)
    confirmations_count = Column(Integer, default=1, nullable=False)
    cleared_count = Column(Integer, default=0, nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    author = relationship("User", back_populates="markers")
