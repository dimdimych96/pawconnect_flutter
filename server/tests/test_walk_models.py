import pytest
from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import User
from app.models.pet import Pet
from app.models.walk import WalkSession, WalkInvitation

@pytest.mark.asyncio
async def test_create_walk_session_and_invitation(db_session: AsyncSession):
    user1 = User(email="owner1@pawconnect.app", name="Алексей К.", role="user")
    user2 = User(email="owner2@pawconnect.app", name="Марина С.", role="user")
    db_session.add_all([user1, user2])
    await db_session.flush()

    pet1 = Pet(
        owner_id=user1.id,
        name="Макс",
        breed="Корги",
        temperament="playful",
        is_walking=True,
        walk_mode="open",
        walk_started_at=datetime.now(timezone.utc),
        latitude=55.0302,
        longitude=82.9204,
    )
    pet2 = Pet(
        owner_id=user2.id,
        name="Луна",
        breed="Шелти",
        temperament="calm",
        is_walking=True,
        walk_mode="private",
        walk_started_at=datetime.now(timezone.utc),
        latitude=55.0320,
        longitude=82.9220,
    )
    db_session.add_all([pet1, pet2])
    await db_session.flush()

    walk_session = WalkSession(
        pet_id=pet1.id,
        user_id=user1.id,
        walk_mode="open",
        latitude=55.0302,
        longitude=82.9204,
        is_active=True,
        note="Гуляем на собачьей площадке в Нарымском сквере",
    )
    invitation = WalkInvitation(
        from_user_id=user1.id,
        to_pet_id=pet2.id,
        status="pending",
        message="Привет! Давайте побегаем вместе?",
    )
    db_session.add_all([walk_session, invitation])
    await db_session.commit()

    assert pet1.temperament == "playful"
    assert pet1.is_walking is True
    assert walk_session.id is not None
    assert walk_session.is_active is True
    assert invitation.id is not None
    assert invitation.status == "pending"
