import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User
from app.models.pet import Pet
from app.models.breed import Breed, CURATED_BREEDS

@pytest.mark.asyncio
async def test_breed_model_and_pet_health_fields(db_session: AsyncSession):
    # Test breed seeding and attributes
    for b_data in CURATED_BREEDS:
        db_session.add(Breed(**b_data))
    await db_session.flush()

    user = User(email="health_owner@pawconnect.app", name="Ольга В.", role="user")
    db_session.add(user)
    await db_session.flush()

    pet = Pet(
        owner_id=user.id,
        name="Арчи",
        breed="Вельш-корги пемброк",
        weight_kg=11.4,
        target_weight_kg=11.0,
        bcs_score=5,
        activity_goal_minutes=75,
    )
    db_session.add(pet)
    await db_session.commit()

    assert pet.weight_kg == 11.4
    assert pet.target_weight_kg == 11.0
    assert pet.bcs_score == 5
    assert pet.activity_goal_minutes == 75

    # Verify corgi breed intelligence
    breed_res = await db_session.get(Breed, "corgi")
    assert breed_res is not None
    assert breed_res.name == "Вельш-корги пемброк"
    assert breed_res.ideal_weight_min == 10.0
    assert breed_res.ideal_weight_max == 12.5
    assert len(breed_res.health_watchouts) >= 2
    assert "IVDD" in breed_res.health_watchouts[0]["title"]
