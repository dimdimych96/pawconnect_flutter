import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_walk_endpoints_full_flow(client: AsyncClient):
    # 1. Register owner and create pet
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "walker@pawconnect.app", "password": "securepassword", "name": "Константин"},
    )
    assert reg.status_code == 201
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    pet_res = await client.post(
        "/api/v1/pets",
        headers=headers,
        json={
            "name": "Рокки",
            "breed": "Бигль",
            "safe_zone_radius_meters": 200,
            "safe_zone_latitude": 55.0302,
            "safe_zone_longitude": 82.9204,
        },
    )
    assert pet_res.status_code == 201
    pet = pet_res.json()
    pet_id = pet["id"]

    # 2. Update pet temperament
    temp_res = await client.put(
        f"/api/v1/walks/pets/{pet_id}/temperament",
        headers=headers,
        json={"temperament": "playful"},
    )
    assert temp_res.status_code == 200
    assert temp_res.json()["temperament"] == "playful"

    # 3. Start walk session
    start_res = await client.post(
        "/api/v1/walks/start",
        headers=headers,
        json={
            "pet_id": pet_id,
            "walk_mode": "open",
            "latitude": 55.0305,
            "longitude": 82.9210,
            "note": "Утренний выгул в парке",
        },
    )
    assert start_res.status_code == 201
    walk_data = start_res.json()
    assert walk_data["is_active"] is True
    assert walk_data["pet_name"] == "Рокки"
    assert walk_data["temperament"] == "playful"
    assert walk_data["walk_mode"] == "open"

    # 4. Get active walk session
    active_res = await client.get("/api/v1/walks/active", headers=headers)
    assert active_res.status_code == 200
    active = active_res.json()
    assert active is not None
    assert active["pet_id"] == pet_id
    assert active["is_active"] is True

    # 5. Query nearby walks
    nearby_res = await client.get(
        "/api/v1/walks/nearby",
        params={"latitude": 55.0300, "longitude": 82.9200, "radius_meters": 1500},
    )
    assert nearby_res.status_code == 200
    nearby = nearby_res.json()
    assert len(nearby) >= 1
    found_rocky = next((p for p in nearby if p["pet_id"] == pet_id), None)
    assert found_rocky is not None
    assert found_rocky["pet_name"] == "Рокки"
    assert found_rocky["temperament"] == "playful"
    assert found_rocky["distance_meters"] < 200

    # 6. Test Private Walk mode with privacy fuzzing
    private_start = await client.post(
        "/api/v1/walks/start",
        headers=headers,
        json={
            "pet_id": pet_id,
            "walk_mode": "private",
            "latitude": 55.0305,
            "longitude": 82.9210,
            "note": "Приватный выгул",
        },
    )
    assert private_start.status_code == 201
    assert private_start.json()["walk_mode"] == "private"

    nearby_private = await client.get(
        "/api/v1/walks/nearby",
        params={"latitude": 55.0300, "longitude": 82.9200, "radius_meters": 1500},
    )
    assert nearby_private.status_code == 200
    found_private = next((p for p in nearby_private.json() if p["pet_id"] == pet_id), None)
    assert found_private is not None
    assert found_private["is_private"] is True
    # Coordinates should be fuzzed (not exactly 55.0305, 82.9210)
    assert (found_private["latitude"] != 55.0305 or found_private["longitude"] != 82.9210)

    # 7. Send walk invitation to target pet
    invite_res = await client.post(
        "/api/v1/walks/invite",
        headers=headers,
        json={"to_pet_id": pet_id, "message": "Привет! Хотим познакомиться"},
    )
    assert invite_res.status_code == 201
    assert invite_res.json()["status"] == "pending"

    # 8. Stop walk session
    stop_res = await client.post("/api/v1/walks/stop", headers=headers, json={"pet_id": pet_id})
    assert stop_res.status_code == 200
    assert stop_res.json()["status"] == "stopped"

    # 9. Verify active walk is now None
    active_after = await client.get("/api/v1/walks/active", headers=headers)
    assert active_after.status_code == 200
    assert active_after.json() is None
