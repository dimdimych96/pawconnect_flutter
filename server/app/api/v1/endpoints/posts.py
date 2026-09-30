import uuid
from datetime import datetime, timezone
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from sqlalchemy.orm import selectinload
from ....db.session import get_db
from ....models.user import User
from ....models.post import CommunityPost, PostComment
from ....schemas.post import (
    CommunityPostCreate,
    CommunityPostResponse,
    StoryResponse,
    CommentCreate,
    CommentResponse,
)
from ...deps import get_current_user

router = APIRouter()
stories_router = APIRouter()

OFFICIAL_USER_ID = uuid.UUID("7396fc07-1cce-5591-90b5-daf6e9d6f0c8")
OFFICIAL_POST_ID = uuid.UUID("40ca557c-f485-5bc6-8091-a12d570e3b1f")

SHOWCASE_STORIES: List[dict] = [
    {
        "id": "story-pc-official",
        "author_name": "PawConnect Team",
        "is_official": True,
        "author_avatar": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80",
        "pet_name": None,
        "district": "Центральный",
        "media_url": "https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=800&q=80",
        "status_text": "Совет кинолога: настройка безопасных геозон ошейника",
        "created_at": datetime(2026, 9, 30, 10, 0, tzinfo=timezone.utc),
        "is_viewed": False,
    },
    {
        "id": "story-pet-1",
        "author_name": "Анна С.",
        "is_official": False,
        "author_avatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80",
        "pet_name": "Рекс (Хаски)",
        "district": "Заельцовский",
        "media_url": "https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?auto=format&fit=crop&w=800&q=80",
        "status_text": "Гуляет 25 мин в Нарымском сквере",
        "created_at": datetime(2026, 9, 30, 10, 15, tzinfo=timezone.utc),
        "is_viewed": False,
    },
    {
        "id": "story-pet-2",
        "author_name": "Михаил Д.",
        "is_official": False,
        "author_avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80",
        "pet_name": "Луна (Корги)",
        "district": "Советский (Академгородок)",
        "media_url": "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=800&q=80",
        "status_text": "Тренировка на дог-площадке НГУ",
        "created_at": datetime(2026, 9, 30, 10, 30, tzinfo=timezone.utc),
        "is_viewed": False,
    },
    {
        "id": "story-pet-3",
        "author_name": "Екатерина В.",
        "is_official": False,
        "author_avatar": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80",
        "pet_name": "Майло (Джек-рассел)",
        "district": "Первомайский",
        "media_url": "https://images.unsplash.com/photo-1517849845537-4d257902454a?auto=format&fit=crop&w=800&q=80",
        "status_text": "Утренняя пробежка у набережной",
        "created_at": datetime(2026, 9, 30, 10, 45, tzinfo=timezone.utc),
        "is_viewed": False,
    },
]


_showcase_seeded: bool = False


async def ensure_showcase_data(db: AsyncSession) -> None:
    global _showcase_seeded
    if _showcase_seeded:
        try:
            post_check = await db.execute(select(CommunityPost.id).where(CommunityPost.id == OFFICIAL_POST_ID))
            if post_check.scalar_one_or_none():
                return
        except Exception:
            _showcase_seeded = False

    # 1. Ensure official PawConnect user
    user_res = await db.execute(select(User).where(User.email == "team@pawconnect.app"))
    official_user = user_res.scalar_one_or_none()
    if not official_user:
        official_user = User(
            id=OFFICIAL_USER_ID,
            email="team@pawconnect.app",
            name="PawConnect Team",
            role="admin",
            avatar_url="https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80",
        )
        db.add(official_user)
        await db.flush()

    # 2. Ensure official showcase post
    post_res = await db.execute(select(CommunityPost).where(CommunityPost.id == OFFICIAL_POST_ID))
    official_post = post_res.scalar_one_or_none()
    if not official_post:
        official_post = CommunityPost(
            id=OFFICIAL_POST_ID,
            author_id=official_user.id,
            district="Центральный",
            category="training",
            title="Умный выгул: Настройка безопасных геозон ошейника",
            text="Команда PawConnect подготовила подробный гид по настройке GPS-ошейника и безопасных зон выгула в Новосибирске. Задайте радиус безопасной зоны от 50 до 500 метров в карточке питомца. При выходе за границу вы мгновенно получите пуш-уведомление и сигнал тревоги!",
            photo_url="https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=800&q=80",
            pet_name="Барс (Самоед)",
            likes_count=42,
            is_official=True,
        )
        db.add(official_post)
        await db.flush()

        # Add initial showcase comments
        comment1 = PostComment(
            post_id=OFFICIAL_POST_ID,
            author_id=official_user.id,
            text="Если у вас возникнут вопросы по калибровке GPS в условиях плотной застройки — задавайте в комментариях, наши кинологи ответят!",
            is_official=True,
            likes_count=5,
        )
        comment2 = PostComment(
            post_id=OFFICIAL_POST_ID,
            author_id=official_user.id,
            text="Спасибо за совет! В Нарымском сквере настроила 150 метров — работает идеально.",
            is_official=False,
            likes_count=2,
        )
        db.add_all([comment1, comment2])
        await db.commit()

    _showcase_seeded = True


@stories_router.get("", response_model=List[StoryResponse])
@router.get("/stories", response_model=List[StoryResponse])
async def get_stories() -> Any:
    return [StoryResponse.model_validate(s) for s in SHOWCASE_STORIES]


@router.get("", response_model=List[CommunityPostResponse])
async def get_posts(
    district: Optional[str] = Query(None, description="Фильтр по району"),
    category: Optional[str] = Query(None, description="Фильтр по категории"),
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
) -> Any:
    await ensure_showcase_data(db)

    stmt = (
        select(CommunityPost)
        .options(selectinload(CommunityPost.author), selectinload(CommunityPost.comments))
        .order_by(desc(CommunityPost.created_at))
        .offset(skip)
        .limit(limit)
    )
    if district and district != "Все районы":
        stmt = stmt.where(CommunityPost.district == district)
    if category and category != "all":
        stmt = stmt.where(CommunityPost.category == category)

    result = await db.execute(stmt)
    posts = result.scalars().all()

    response = []
    for p in posts:
        resp_obj = CommunityPostResponse.model_validate(p)
        if p.author:
            resp_obj.author_name = p.author.name
            resp_obj.author_avatar = p.author.avatar_url
        resp_obj.comments_count = len(p.comments) if p.comments else 0
        resp_obj.is_official = bool(p.is_official)
        resp_obj.pet_name = p.pet_name
        resp_obj.title = p.title
        resp_obj.sync()
        response.append(resp_obj)
    return response


@router.post("", response_model=CommunityPostResponse, status_code=status.HTTP_201_CREATED)
async def create_post(
    post_in: CommunityPostCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    is_official = current_user.role in ("admin", "moderator")
    post = CommunityPost(
        author_id=current_user.id,
        district=post_in.district,
        category=post_in.category,
        title=post_in.title,
        text=post_in.text,
        photo_url=post_in.photo_url,
        pet_name=post_in.pet_name,
        is_official=is_official,
    )
    db.add(post)
    await db.commit()
    await db.refresh(post)

    resp_obj = CommunityPostResponse.model_validate(post)
    resp_obj.author_name = current_user.name
    resp_obj.author_avatar = current_user.avatar_url
    resp_obj.is_official = is_official
    resp_obj.comments_count = 0
    resp_obj.sync()
    return resp_obj


@router.post("/{post_id}/like", response_model=CommunityPostResponse)
async def like_post(
    post_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    result = await db.execute(
        select(CommunityPost)
        .options(selectinload(CommunityPost.author), selectinload(CommunityPost.comments))
        .where(CommunityPost.id == post_id)
    )
    post = result.scalar_one_or_none()
    if not post:
        raise HTTPException(status_code=404, detail="Пост не найден")

    post.likes_count = (post.likes_count or 0) + 1
    await db.commit()
    await db.refresh(post)

    resp_obj = CommunityPostResponse.model_validate(post)
    if post.author:
        resp_obj.author_name = post.author.name
        resp_obj.author_avatar = post.author.avatar_url
    resp_obj.comments_count = len(post.comments) if post.comments else 0
    resp_obj.is_official = bool(post.is_official)
    resp_obj.pet_name = post.pet_name
    resp_obj.title = post.title
    resp_obj.is_liked = True
    resp_obj.sync()
    return resp_obj


@router.get("/{post_id}/comments", response_model=List[CommentResponse])
async def get_comments(
    post_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
) -> Any:
    post_res = await db.execute(select(CommunityPost).where(CommunityPost.id == post_id))
    if not post_res.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Пост не найден")

    stmt = (
        select(PostComment)
        .options(selectinload(PostComment.author))
        .where(PostComment.post_id == post_id)
        .order_by(PostComment.created_at.asc())
    )
    result = await db.execute(stmt)
    comments = result.scalars().all()

    response = []
    for c in comments:
        response.append(
            CommentResponse(
                id=c.id,
                post_id=c.post_id,
                author_name=c.author.name if c.author else "Аноним",
                author_avatar=c.author.avatar_url if c.author else None,
                is_official=bool(c.is_official),
                text=c.text,
                likes_count=c.likes_count or 0,
                created_at=c.created_at,
            )
        )
    return response


@router.post("/{post_id}/comments", response_model=CommentResponse, status_code=status.HTTP_201_CREATED)
async def create_comment(
    post_id: uuid.UUID,
    comment_in: CommentCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    post_res = await db.execute(select(CommunityPost).where(CommunityPost.id == post_id))
    if not post_res.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Пост не найден")

    is_official = current_user.role in ("admin", "moderator")
    comment = PostComment(
        post_id=post_id,
        author_id=current_user.id,
        text=comment_in.text,
        is_official=is_official,
        likes_count=0,
    )
    db.add(comment)
    await db.commit()
    await db.refresh(comment)

    return CommentResponse(
        id=comment.id,
        post_id=comment.post_id,
        author_name=current_user.name,
        author_avatar=current_user.avatar_url,
        is_official=is_official,
        text=comment.text,
        likes_count=0,
        created_at=comment.created_at,
    )
