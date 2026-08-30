import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_markers_spatial_search_and_create(client: AsyncClient):
    # 1. Register user
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "geo@pawconnect.app", "password": "pass", "name": "Гео Позиция"},
    )
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Create marker at Center (55.0302, 82.9204)
    create_res = await client.post(
        "/api/v1/map/markers",
        headers=headers,
        json={
            "title": "Дог-парк Центральный",
            "description": "Огороженная площадка с снарядами",
            "category": "dog_park",
            "latitude": 55.0302,
            "longitude": 82.9204,
        },
    )
    assert create_res.status_code == 201
    marker_id = create_res.json()["id"]

    # 3. Create distant marker in another city (Moscow: 55.7558, 37.6173)
    await client.post(
        "/api/v1/map/markers",
        headers=headers,
        json={
            "title": "Парк Горького Москва",
            "category": "dog_park",
            "latitude": 55.7558,
            "longitude": 37.6173,
        },
    )

    # 4. Search markers within 5000m radius of Center (55.0300, 82.9200)
    search_res = await client.get(
        "/api/v1/map/markers",
        params={"latitude": 55.0300, "longitude": 82.9200, "radius": 5000},
    )
    assert search_res.status_code == 200
    markers = search_res.json()
    assert len(markers) == 1
    assert markers[0]["title"] == "Дог-парк Центральный"
