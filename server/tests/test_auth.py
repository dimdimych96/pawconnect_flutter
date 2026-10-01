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


@pytest.mark.asyncio
async def test_update_user_role_admin_permissions(client: AsyncClient, db_session):
    # 1. Register normal user
    reg1 = await client.post(
        "/api/v1/auth/register",
        json={"email": "target_user@pawconnect.app", "password": "Password123!", "name": "Тестовый Юзер"},
    )
    assert reg1.status_code == 201
    user1_token = reg1.json()["access_token"]
    user1_id = reg1.json()["user"]["id"]

    # 2. Register admin user and elevate in DB directly (or seed)
    reg_admin = await client.post(
        "/api/v1/auth/register",
        json={"email": "boss@pawconnect.app", "password": "Password123!", "name": "Босс Админ"},
    )
    assert reg_admin.status_code == 201
    admin_token = reg_admin.json()["access_token"]

    # Manually elevate boss to admin in db for test
    from app.models.user import User
    from sqlalchemy import select
    res = await db_session.execute(select(User).where(User.email == "boss@pawconnect.app"))
    boss = res.scalar_one()
    boss.role = "admin"
    await db_session.commit()

    # 3. Non-admin attempts to change role -> 403 Forbidden
    forbidden_resp = await client.patch(
        f"/api/v1/auth/users/{user1_id}/role",
        headers={"Authorization": f"Bearer {user1_token}"},
        json={"role": "admin"},
    )
    assert forbidden_resp.status_code == 403

    # 4. Admin changes role to admin -> 200 OK
    elevate_resp = await client.patch(
        f"/api/v1/auth/users/{user1_id}/role",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"role": "admin"},
    )
    assert elevate_resp.status_code == 200
    assert elevate_resp.json()["role"] == "admin"

    # 5. Invalid role -> 400
    invalid_resp = await client.patch(
        f"/api/v1/auth/users/{user1_id}/role",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={"role": "superman"},
    )
    assert invalid_resp.status_code == 400

