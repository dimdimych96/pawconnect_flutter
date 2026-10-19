import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_sos_sighting_and_volunteer_flow(client: AsyncClient):
    # 1. Register a user
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "sos_user@pawconnect.app", "password": "securepassword", "name": "Алексей С."},
    )
    assert reg.status_code == 201
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Create an SOS post
    post_res = await client.post(
        "/api/v1/community/posts",
        headers=headers,
        json={
            "district": "Центральный",
            "category": "sos",
            "title": "SOS: Пропал хаски Арчи",
            "text": "Убежал возле Центрального парка 1 час назад",
            "pet_name": "Арчи",
        },
    )
    assert post_res.status_code == 201
    post = post_res.json()
    post_id = post["id"]
    assert post["volunteersCount"] == 0
    assert post["sightingsCount"] == 0
    assert post["isVolunteering"] is False

    # 3. Add sighting
    sighting_res = await client.post(
        f"/api/v1/community/posts/{post_id}/sightings",
        headers=headers,
        json={
            "latitude": 55.0315,
            "longitude": 82.9215,
            "note": "Замечен у входа в метро, бежал в сторону парка",
            "time_ago_str": "15 мин назад",
        },
    )
    assert sighting_res.status_code == 201
    s_data = sighting_res.json()
    assert s_data["note"] == "Замечен у входа в метро, бежал в сторону парка"
    assert s_data["time_ago_str"] == "15 мин назад"
    assert s_data["timeAgoStr"] == "15 мин назад"
    assert s_data["latitude"] == 55.0315
    assert s_data["longitude"] == 82.9215
    assert s_data["author_name"] == "Алексей С."

    # 4. List sightings
    list_res = await client.get(f"/api/v1/community/posts/{post_id}/sightings")
    assert list_res.status_code == 200
    sightings = list_res.json()
    assert len(sightings) >= 1
    assert sightings[0]["note"] == "Замечен у входа в метро, бежал в сторону парка"

    # 5. Join search party (volunteer toggle)
    vol_res = await client.post(f"/api/v1/community/posts/{post_id}/volunteer", headers=headers)
    assert vol_res.status_code == 200
    vol_data = vol_res.json()
    assert vol_data["is_volunteering"] is True
    assert vol_data["isVolunteering"] is True
    assert vol_data["volunteers_count"] == 1
    assert vol_data["volunteersCount"] == 1

    # 6. Check post reflects volunteer and sightings counts
    get_post_res = await client.get(f"/api/v1/community/posts", headers=headers)
    assert get_post_res.status_code == 200
    found_post = next(p for p in get_post_res.json() if p["id"] == post_id)
    assert found_post["volunteersCount"] == 1
    assert found_post["sightingsCount"] == 1
    assert found_post["isVolunteering"] is True

    # 7. Leave search party (toggle off)
    leave_vol_res = await client.post(f"/api/v1/community/posts/{post_id}/volunteer", headers=headers)
    assert leave_vol_res.status_code == 200
    assert leave_vol_res.json()["is_volunteering"] is False
    assert leave_vol_res.json()["volunteers_count"] == 0
