import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_register_and_login_flow(client: AsyncClient):
    # 1. Register new user
    register_payload = {
        "email": "owner@pawconnect.app",
        "password": "strongPassword123",
        "name": "Иван Смирнов",
    }
    reg_response = await client.post("/api/v1/auth/register", json=register_payload)
    assert reg_response.status_code == 201
    data = reg_response.json()
    assert data["token_type"] == "bearer"
    assert "access_token" in data
    assert data["user"]["email"] == "owner@pawconnect.app"
    assert data["user"]["name"] == "Иван Смирнов"

    # 2. Login with valid credentials
    login_response = await client.post(
        "/api/v1/auth/login",
        data={"username": "owner@pawconnect.app", "password": "strongPassword123"},
    )
    assert login_response.status_code == 200
    login_data = login_response.json()
    token = login_data["access_token"]
    assert token

    # 3. Access protected /me endpoint
    me_response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert me_response.status_code == 200
    assert me_response.json()["email"] == "owner@pawconnect.app"


@pytest.mark.asyncio
async def test_login_invalid_password(client: AsyncClient):
    # Register first
    await client.post(
        "/api/v1/auth/register",
        json={"email": "alice@pawconnect.app", "password": "correctPassword", "name": "Алиса"},
    )

    # Login with wrong password
    response = await client.post(
        "/api/v1/auth/login",
        data={"username": "alice@pawconnect.app", "password": "wrongPassword"},
    )
    assert response.status_code == 400
    assert "Неверный email или пароль" in response.json()["detail"]
