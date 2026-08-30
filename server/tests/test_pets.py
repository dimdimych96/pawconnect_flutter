import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_pets_crud_and_safe_zone(client: AsyncClient):
    # 1. Register user
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "petowner@pawconnect.app", "password": "pass", "name": "Владелец Собаки"},
    )
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Add Pet
    pet_res = await client.post(
        "/api/v1/pets",
        headers=headers,
        json={
            "name": "Макс",
            "breed": "Золотистый ретривер",
            "tracker_type": "gps_collar",
            "device_imei": "864019283746192",
            "safe_zone_radius_meters": 200,
            "safe_zone_latitude": 55.0340,
            "safe_zone_longitude": 82.9180,
        },
    )
    assert pet_res.status_code == 201
    pet_data = pet_res.json()
    assert pet_data["name"] == "Макс"
    assert pet_data["safe_zone_radius_meters"] == 200
    pet_id = pet_data["id"]

    # 3. Get my pets
    list_res = await client.get("/api/v1/pets", headers=headers)
    assert list_res.status_code == 200
    assert len(list_res.json()) == 1

    # 4. Update pet safe zone
    patch_res = await client.patch(
        f"/api/v1/pets/{pet_id}",
        headers=headers,
        json={"safe_zone_radius_meters": 350, "is_lost": False},
    )
    assert patch_res.status_code == 200
    assert patch_res.json()["safe_zone_radius_meters"] == 350
