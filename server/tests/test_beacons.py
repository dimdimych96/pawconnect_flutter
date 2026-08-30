import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_anonymous_beacon_crowdsourcing_and_safe_zone_breach(client: AsyncClient):
    # 1. Register user & add lost pet with beacon_uuid
    reg = await client.post(
        "/api/v1/auth/register",
        json={"email": "beacon_owner@pawconnect.app", "password": "pass", "name": "Владелец Маячка"},
    )
    token = reg.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    pet_res = await client.post(
        "/api/v1/pets",
        headers=headers,
        json={
            "name": "Чарли",
            "breed": "Корги",
            "tracker_type": "ble_beacon",
            "beacon_uuid": "FDA50693-A4E2-4FB1-AFCF-C6EB07647825",
            "safe_zone_radius_meters": 100,
            "safe_zone_latitude": 55.0300,
            "safe_zone_longitude": 82.9200,
        },
    )
    assert pet_res.status_code == 201

    # 2. Random phone in the network detects beacon FAR from safe zone (e.g. 500m away at 55.0350, 82.9200)
    report_res = await client.post(
        "/api/v1/beacons/report",
        json={
            "beacon_uuid": "FDA50693-A4E2-4FB1-AFCF-C6EB07647825",
            "latitude": 55.0350,
            "longitude": 82.9200,
            "rssi": -65,
        },
    )
    assert report_res.status_code == 200
    report_data = report_res.json()
    assert report_data["status"] == "success"
    assert report_data["is_lost"] is True  # breached 100m safe zone
