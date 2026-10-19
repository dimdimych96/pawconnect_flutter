import pytest
from datetime import datetime, timezone, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.sos import SOSSighting, SOSVolunteer
from app.models.marker import MapMarker
from app.models.user import User
from app.models.post import CommunityPost

@pytest.mark.asyncio
async def test_create_sos_sighting_and_volunteer(db_session: AsyncSession):
    user = User(email="volunteer@pawconnect.app", name="Иван Поисковик", role="user")
    db_session.add(user)
    await db_session.flush()

    post = CommunityPost(
        author_id=user.id,
        district="Центральный",
        category="sos",
        title="SOS: Пропал хаски Арчи",
        text="Убежал возле сквера 1 час назад",
    )
    db_session.add(post)
    await db_session.flush()

    sighting = SOSSighting(
        post_id=post.id,
        author_id=user.id,
        latitude=55.0300,
        longitude=82.9200,
        note="Замечен пес у сквера, бежал на восток",
        time_ago_str="30 мин назад",
    )
    volunteer = SOSVolunteer(post_id=post.id, user_id=user.id)
    hazard = MapMarker(
        title="Зона риска: Отрава/Догхантеры",
        category="danger",
        danger_type="poison",
        latitude=55.0310,
        longitude=82.9210,
        confirmations_count=2,
        cleared_count=0,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=48),
    )
    db_session.add_all([sighting, volunteer, hazard])
    await db_session.commit()

    assert sighting.id is not None
    assert volunteer.id is not None
    assert hazard.danger_type == "poison"
    assert hazard.confirmations_count == 2
