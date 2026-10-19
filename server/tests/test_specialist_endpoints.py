import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.specialist import Specialist, CURATED_SPECIALISTS

@pytest.mark.asyncio
async def test_specialists_endpoints(client: AsyncClient, db_session: AsyncSession):
    # Seed curated specialists
    for s_data in CURATED_SPECIALISTS:
        db_session.add(Specialist(**s_data))
    await db_session.commit()

    # 1. GET /api/v1/specialists (all)
    res = await client.get("/api/v1/specialists")
    assert res.status_code == 200
    items = res.json()
    assert len(items) >= 4

    # 2. Filter by profession=cynologist
    res_cyno = await client.get("/api/v1/specialists?profession=cynologist")
    assert res_cyno.status_code == 200
    cynos = res_cyno.json()
    assert all(c["profession"] == "cynologist" for c in cynos)
    assert any(c["id"] == "spec-anna-melnikova" for c in cynos)

    # 3. Filter by district=Советский
    res_sov = await client.get("/api/v1/specialists?district=Советский")
    assert res_sov.status_code == 200
    sov_items = res_sov.json()
    assert len(sov_items) >= 1
    assert sov_items[0]["name"] == "Елена Смирнова"

    # 4. Search query
    res_query = await client.get("/api/v1/specialists?query=ВетЛекарь")
    assert res_query.status_code == 200
    q_items = res_query.json()
    assert len(q_items) == 1
    assert "ВетЛекарь" in q_items[0]["name"]

    # 5. GET /api/v1/specialists/{id}
    res_detail = await client.get("/api/v1/specialists/spec-anna-melnikova")
    assert res_detail.status_code == 200
    detail = res_detail.json()
    assert detail["name"] == "Анна Мельникова"
    assert len(detail["services"]) >= 1

    # 6. GET /api/v1/specialists/unknown -> 404
    res_404 = await client.get("/api/v1/specialists/spec-nonexistent")
    assert res_404.status_code == 404

    # 7. POST /api/v1/specialists/{id}/inquiry
    res_inquiry = await client.post(
        "/api/v1/specialists/spec-anna-melnikova/inquiry",
        json={"message": "Здравствуйте! Хотим записаться на занятие по коррекции поводка.", "pet_id": "pet-1"}
    )
    assert res_inquiry.status_code == 200
    inquiry_res = res_inquiry.json()
    assert inquiry_res["status"] == "sent"
