from typing import Optional, List
from pydantic import BaseModel, ConfigDict

class SpecialistServiceItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    title: str
    price: int

class SpecialistResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    name: str
    avatar_url: Optional[str] = None
    profession: str
    profession_title: str
    rating: float
    reviews_count: int
    experience_years: int
    price_from: int
    price_unit: str
    is_verified: bool
    district: str
    address: str
    latitude: float
    longitude: float
    bio: Optional[str] = None
    phone: Optional[str] = None
    telegram: Optional[str] = None
    services: List[SpecialistServiceItem] = []

class SpecialistInquiryRequest(BaseModel):
    message: str
    pet_id: Optional[str] = None
    preferred_date: Optional[str] = None

class SpecialistInquiryResponse(BaseModel):
    status: str = "sent"
    specialist_id: str
    message: str
