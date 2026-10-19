import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.specialist import Specialist, CURATED_SPECIALISTS

@pytest.mark.asyncio
async def test_specialist_model_and_seeding(db_session: AsyncSession):
    # Verify curated specialists list
    assert len(CURATED_SPECIALISTS) >= 4

    # Seed into database
    for spec_data in CURATED_SPECIALISTS:
        spec = Specialist(**spec_data)
        db_session.add(spec)
    await db_session.flush()

    # Query back
    anna = await db_session.get(Specialist, "spec-anna-melnikova")
    assert anna is not None
    assert anna.name == "Анна Мельникова"
    assert anna.profession == "cynologist"
    assert anna.profession_title == "Кинолог-зоопсихолог"
    assert anna.rating >= 4.9
    assert anna.reviews_count >= 10
    assert anna.is_verified is True
    assert anna.price_from == 1500
    assert anna.price_unit == "₽ / занятие"
    assert anna.district == "Заельцовский"
    assert anna.latitude > 54.0
    assert anna.longitude > 82.0
    assert len(anna.services) >= 1
