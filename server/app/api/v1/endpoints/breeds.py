from typing import List, Optional, Any
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_

from ....db.session import get_db
from ....models.breed import Breed, CURATED_BREEDS
from ....schemas.breed import BreedResponse

router = APIRouter()


@router.get("", response_model=List[BreedResponse])
async def get_breeds(
    query: Optional[str] = Query(None, description="Поисковый запрос по названию породы"),
    category: Optional[str] = Query(None, description="Категория (Пастушьи, Ретриверы, и т.д.)"),
    db: AsyncSession = Depends(get_db),
) -> Any:
    stmt = select(Breed)
    if query:
        q = f"%{query.lower()}%"
        stmt = stmt.where(or_(Breed.name.ilike(q), Breed.name_en.ilike(q)))
    if category:
        stmt = stmt.where(Breed.category == category)
    
    result = await db.execute(stmt)
    breeds = result.scalars().all()
    if not breeds and not query and not category:
        # Fallback to in-memory curated if table empty
        return [BreedResponse.model_validate(b) for b in CURATED_BREEDS]
    return [BreedResponse.model_validate(b) for b in breeds]


@router.get("/{breed_id}", response_model=BreedResponse)
async def get_breed_detail(
    breed_id: str,
    db: AsyncSession = Depends(get_db),
) -> Any:
    result = await db.execute(select(Breed).where(Breed.id == breed_id))
    breed = result.scalar_one_or_none()
    if not breed:
        # Check curated list
        for b in CURATED_BREEDS:
            if b["id"] == breed_id:
                return BreedResponse.model_validate(b)
        raise HTTPException(status_code=404, detail="Порода не найдена")
    return BreedResponse.model_validate(breed)


@router.get("/match/by-name", response_model=Optional[BreedResponse])
async def match_breed_by_name(
    name: str = Query(..., description="Название породы из профиля питомца"),
    db: AsyncSession = Depends(get_db),
) -> Any:
    name_clean = name.strip().lower()
    stmt = select(Breed)
    result = await db.execute(stmt)
    breeds = result.scalars().all()
    
    # Try exact or substring matches
    for b in breeds:
        b_name = b.name.lower()
        if name_clean in b_name or b_name in name_clean:
            return BreedResponse.model_validate(b)
        if b.id in name_clean:
            return BreedResponse.model_validate(b)
    
    # Try fallback in CURATED_BREEDS
    for b in CURATED_BREEDS:
        b_name = b["name"].lower()
        if name_clean in b_name or b_name in name_clean or b["id"] in name_clean:
            return BreedResponse.model_validate(b)
            
    return None
