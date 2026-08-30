import uuid
from datetime import datetime, timezone, date
from sqlalchemy import Column, String, Integer, Float, Boolean, Date, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..db.session import Base


class Pet(Base):
    __tablename__ = "pets"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(100), nullable=False)
    breed = Column(String(100), nullable=True)
    avatar_url = Column(String(1024), nullable=True)
    birth_date = Column(Date, nullable=True)
    
    tracker_type = Column(String(20), default="gps_collar", nullable=False)  # 'gps_collar', 'ble_beacon'
    device_imei = Column(String(64), unique=True, nullable=True, index=True)
    beacon_uuid = Column(String(64), unique=True, nullable=True, index=True)
    battery_level = Column(Integer, default=100)
    
    is_lost = Column(Boolean, default=False, nullable=False, index=True)
    safe_zone_radius_meters = Column(Integer, default=150)
    safe_zone_latitude = Column(Float, nullable=True)
    safe_zone_longitude = Column(Float, nullable=True)
    
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    last_seen_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    owner = relationship("User", back_populates="pets")
    reminders = relationship("PetReminder", back_populates="pet", cascade="all, delete-orphan")
