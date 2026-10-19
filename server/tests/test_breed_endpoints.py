import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User
from app.models.pet import Pet
from app.models.breed import Breed, CURATED_BREEDS
from app.core.security import create_access_token


@pytest.mark.asyncio
async def test_breed_and_health_endpoints(client: AsyncClient, db_session: AsyncSession):
    # Ensure breeds are seeded
    for b in CURATED_BREEDS:
        db_session.add(Breed(**b))
    
    user = User(email="alex_health@pawconnect.app", name="Алексей К.", role="user")
    db_session.add(user)
    await db_session.flush()

    pet = Pet(
        owner_id=user.id,
        name="Арчи",
        breed="Вельш-корги пемброк",
        weight_kg=11.4,
        target_weight_kg=11.0,
        bcs_score=5,
        activity_goal_minutes=60,
    )
    db_session.add(pet)
    await db_session.commit()

    token = create_access_token(str(user.id))
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Get breeds list
    res = await client.get("/api/v1/breeds")
    assert res.status_code == 200
    breeds = res.json()
    assert len(breeds) >= 6
    assert any(b["id"] == "corgi" for b in breeds)

    # 2. Get breed detail
    res = await client.get("/api/v1/breeds/corgi")
    assert res.status_code == 200
    corgi = res.json()
    assert corgi["name"] == "Вельш-корги пемброк"
    assert len(corgi["health_watchouts"]) >= 2

    # 3. Match breed by name
    res = await client.get("/api/v1/breeds/match/by-name?name=корги")
    assert res.status_code == 200
    matched = res.json()
    assert matched is not None
    assert matched["id"] == "corgi"

    # 4. Get pet health profile
    res = await client.get(f"/api/v1/health/pets/{pet.id}", headers=headers)
    assert res.status_code == 200
    profile = res.json()
    assert profile["pet_name"] == "Арчи"
    assert profile["weight_kg"] == 11.4
    assert profile["bcs_score"] == 5
    assert profile["condition_label"] == "Идеальная кондиция"
    assert profile["daily_kcal_target"] > 0
    assert len(profile["health_watchouts"]) >= 2
    assert profile["parasite_protection"] is not None

    # 5. Update pet condition (weight + BCS)
    res = await client.put(
        f"/api/v1/health/pets/{pet.id}/condition",
        headers=headers,
        json={"weight_kg": 12.8, "bcs_score": 6},
    )
    assert res.status_code == 200
    updated = res.json()
    assert updated["weight_kg"] == 12.8
    assert updated["bcs_score"] == 6
    assert updated["condition_label"] == "Легкий избыточный вес"

    # 6. Apply standard milestones
    res = await client.post(f"/api/v1/health/pets/{pet.id}/apply-milestones", headers=headers)
    assert res.status_code == 200
    profile_with_milestones = res.json()
    assert len(profile_with_milestones["milestones"]) >= 3
    titles = [m["title"] for m in profile_with_milestones["milestones"]]
    assert any("DHPPi" in t for t in titles)
    assert any("Симпарика" in t for t in titles)
