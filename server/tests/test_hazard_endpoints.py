import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_hazard_marker_creation_and_community_verification(client: AsyncClient):
    # 1. Register a user
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "hazard_reporter@pawconnect.app", "password": "securepassword", "name": "Михаил К."},
    )
    assert reg.status_code == 201
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Create a danger hazard marker (Радар безопасности)
    res = await client.post(
        "/api/v1/map/markers",
        headers=headers,
        json={
            "title": "Зона риска: Отрава у тропинки",
            "description": "Рассыпан подозрительный порошок",
            "category": "danger",
            "danger_type": "poison",
            "latitude": 55.0340,
            "longitude": 82.9180,
        },
    )
    assert res.status_code == 201
    marker = res.json()
    marker_id = marker["id"]
    assert marker["category"] == "danger"
    assert marker["danger_type"] == "poison"
    assert marker["dangerType"] == "poison"
    assert marker["confirmations_count"] == 1
    assert marker["confirmationsCount"] == 1
    assert marker["cleared_count"] == 0
    assert marker["clearedCount"] == 0

    # 3. Another user confirms the hazard («Подтверждаю»)
    reg2 = await client.post(
        "/api/v1/auth/register",
        json={"email": "confirmer@pawconnect.app", "password": "securepassword", "name": "Елена В."},
    )
    assert reg2.status_code == 201
    headers2 = {"Authorization": f"Bearer {reg2.json()['access_token']}"}

    conf_res = await client.post(
        f"/api/v1/map/markers/{marker_id}/verify",
        headers=headers2,
        json={"action": "confirm"},
    )
    assert conf_res.status_code == 200
    assert conf_res.json()["confirmations_count"] == 2
    assert conf_res.json()["confirmationsCount"] == 2

    # 4. User reports cleared («Очищено»)
    clear_res = await client.post(
        f"/api/v1/map/markers/{marker_id}/verify",
        headers=headers2,
        json={"action": "cleared"},
    )
    assert clear_res.status_code == 200
    assert clear_res.json()["cleared_count"] == 1
    assert clear_res.json()["clearedCount"] == 1
