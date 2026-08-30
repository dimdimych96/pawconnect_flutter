import uuid
from typing import Any, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from ....db.session import get_db
from ....models.user import User
from ....models.post import CommunityPost
from ....schemas.post import CommunityPostCreate, CommunityPostResponse
from ...deps import get_current_user

router = APIRouter()


@router.get("", response_model=List[CommunityPostResponse])
async def get_posts(
    district: Optional[str] = Query(None, description="Фильтр по району"),
    category: Optional[str] = Query(None, description="Фильтр по категории"),
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
) -> Any:
    stmt = select(CommunityPost).order_by(desc(CommunityPost.created_at)).offset(skip).limit(limit)
    if district:
        stmt = stmt.where(CommunityPost.district == district)
    if category:
        stmt = stmt.where(CommunityPost.category == category)

    result = await db.execute(stmt)
    posts = result.scalars().all()
    
    response = []
    for p in posts:
        resp_obj = CommunityPostResponse.model_validate(p)
        if p.author:
            resp_obj.author_name = p.author.name
            resp_obj.author_avatar = p.author.avatar_url
        response.append(resp_obj)
    return response


@router.post("", response_model=CommunityPostResponse, status_code=status.HTTP_201_CREATED)
async def create_post(
    post_in: CommunityPostCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    post = CommunityPost(
        author_id=current_user.id,
        district=post_in.district,
        category=post_in.category,
        text=post_in.text,
        photo_url=post_in.photo_url,
    )
    db.add(post)
    await db.commit()
    await db.refresh(post)
    
    resp_obj = CommunityPostResponse.model_validate(post)
    resp_obj.author_name = current_user.name
    resp_obj.author_avatar = current_user.avatar_url
    return resp_obj


@router.post("/{post_id}/like", response_model=CommunityPostResponse)
async def like_post(
    post_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    result = await db.execute(select(CommunityPost).where(CommunityPost.id == post_id))
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
    return resp_obj
