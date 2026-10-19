import uuid
from datetime import date, datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict


class HealthWatchoutSchema(BaseModel):
    title: str
    risk_level: str  # 'high', 'moderate'
    advice: str


class BreedResponse(BaseModel):
    id: str
    name: str
    name_en: Optional[str] = None
    category: str
    origin: str
    ideal_weight_min: float
    ideal_weight_max: float
    activity_min_minutes: int
    default_temperament: str
    health_watchouts: List[HealthWatchoutSchema]
    nutrition_advice: str
    description: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class PetConditionUpdate(BaseModel):
    weight_kg: Optional[float] = None
    target_weight_kg: Optional[float] = None
    bcs_score: Optional[int] = None  # 1-9
    activity_goal_minutes: Optional[int] = None


class ParasiteProtectionStatus(BaseModel):
    product_name: str
    status: str  # 'active', 'expiring_soon', 'expired'
    days_remaining: int
    total_days: int
    last_applied_date: date
    next_due_date: date


class VaccineMilestone(BaseModel):
    id: Optional[str] = None
    title: str
    category: str  # 'vaccine', 'parasite', 'deworming', 'vet'
    status: str  # 'active', 'due_soon', 'overdue', 'completed'
    due_date: date
    is_completed: bool


class PetHealthProfileResponse(BaseModel):
    pet_id: uuid.UUID
    pet_name: str
    breed_id: Optional[str] = None
    breed_name: Optional[str] = None
    weight_kg: Optional[float] = None
    target_weight_kg: Optional[float] = None
    bcs_score: int = 5
    condition_label: str  # e.g. 'Идеальная форма', 'Легкий избыток'
    daily_kcal_target: int
    daily_food_grams_estimate: int
    activity_goal_minutes: int
    ideal_weight_range: Optional[str] = None
    parasite_protection: Optional[ParasiteProtectionStatus] = None
    milestones: List[VaccineMilestone] = []
    health_watchouts: List[HealthWatchoutSchema] = []
    nutrition_advice: Optional[str] = None
