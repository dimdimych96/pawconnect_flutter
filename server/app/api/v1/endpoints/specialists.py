from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_

from ....db.session import get_db
from ....models.specialist import Specialist
from ....schemas.specialist import SpecialistResponse, SpecialistInquiryRequest, SpecialistInquiryResponse

router = APIRouter()

@router.get("", response_model=List[SpecialistResponse])
async def get_specialists(
    profession: Optional[str] = Query(None, description="Filter by profession: cynologist, dogsitter, groomer, vet_specialist"),
    district: Optional[str] = Query(None, description="Filter by district"),
    query: Optional[str] = Query(None, description="Search query by name, bio or address"),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Specialist)

    if profession and profession != "all":
        stmt = stmt.where(Specialist.profession == profession)

    if district and district != "Все районы":
        stmt = stmt.where(Specialist.district == district)

    if query:
        q_raw = f"%{query.strip()}%"
        q_lower = f"%{query.strip().lower()}%"
        stmt = stmt.where(
            or_(
                Specialist.name.ilike(q_raw),
                Specialist.name.ilike(q_lower),
                Specialist.bio.ilike(q_raw),
                Specialist.bio.ilike(q_lower),
                Specialist.address.ilike(q_raw),
                Specialist.address.ilike(q_lower),
                Specialist.profession_title.ilike(q_raw),
                Specialist.profession_title.ilike(q_lower),
            )
        )

    stmt = stmt.order_by(Specialist.rating.desc(), Specialist.reviews_count.desc())
    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/{specialist_id}", response_model=SpecialistResponse)
async def get_specialist(
    specialist_id: str,
    db: AsyncSession = Depends(get_db),
):
    specialist = await db.get(Specialist, specialist_id)
    if not specialist:
        raise HTTPException(status_code=404, detail="Специалист не найден")
    return specialist


@router.post("/{specialist_id}/inquiry", response_model=SpecialistInquiryResponse)
async def send_specialist_inquiry(
    specialist_id: str,
    inquiry: SpecialistInquiryRequest,
    db: AsyncSession = Depends(get_db),
):
    specialist = await db.get(Specialist, specialist_id)
    if not specialist:
        raise HTTPException(status_code=404, detail="Специалист не найден")

    # In a full production system, this creates a notification/chat message.
    # For now, we record/confirm the dispatch.
    return SpecialistInquiryResponse(
        status="sent",
        specialist_id=specialist_id,
        message=f"Заявка успешно отправлена специалисту {specialist.name}",
    )
