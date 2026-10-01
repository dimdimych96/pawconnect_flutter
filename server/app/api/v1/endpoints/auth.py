import uuid
from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ....db.session import get_db
from ....core.security import get_password_hash, verify_password, create_access_token, create_refresh_token, decode_token
from ....models.user import User
from ....schemas.user import UserCreate, UserResponse, Token, UserRoleUpdate
from ...deps import get_current_user

router = APIRouter()


@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> Any:
    # Check if user already exists
    result = await db.execute(select(User).where(User.email == user_in.email))
    existing_user = result.scalar_one_or_none()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Пользователь с таким email уже зарегистрирован",
        )

    user = User(
        email=user_in.email,
        hashed_password=get_password_hash(user_in.password),
        name=user_in.name,
        avatar_url=user_in.avatar_url or "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80",
        role="user",
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    access_token = create_access_token(user.id)
    refresh_token = create_refresh_token(user.id)

    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.post("/login", response_model=Token)
async def login(
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> Any:
    content_type = request.headers.get("content-type", "")
    username = ""
    password = ""
    if "application/json" in content_type:
        try:
            body = await request.json()
            username = body.get("email") or body.get("username", "")
            password = body.get("password", "")
        except Exception:
            pass
    else:
        try:
            form = await request.form()
            username = form.get("username") or form.get("email", "")
            password = form.get("password", "")
        except Exception:
            pass

    if not username or not password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Неверный email или пароль",
        )

    result = await db.execute(select(User).where(User.email == username))
    user = result.scalar_one_or_none()
    if not user or not user.hashed_password or not verify_password(password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Неверный email или пароль",
        )

    access_token = create_access_token(user.id)
    refresh_token = create_refresh_token(user.id)

    return Token(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.post("/refresh", response_model=Token)
async def refresh_token(
    refresh_token_str: str,
    db: AsyncSession = Depends(get_db),
) -> Any:
    payload = decode_token(refresh_token_str)
    if payload is None or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Невалидный refresh токен",
        )
    
    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Пользователь не найден",
        )

    new_access_token = create_access_token(user.id)
    new_refresh_token = create_refresh_token(user.id)

    return Token(
        access_token=new_access_token,
        refresh_token=new_refresh_token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(
    current_user: User = Depends(get_current_user),
) -> Any:
    return UserResponse.model_validate(current_user)


@router.post("/logout", status_code=status.HTTP_200_OK)
async def logout(
    current_user: User = Depends(get_current_user),
) -> Any:
    return {"message": "Успешный выход из системы"}


@router.get("/users", response_model=List[UserResponse])
async def get_users(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Any:
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Недостаточно прав. Только администраторы могут просматривать список пользователей.",
        )
    result = await db.execute(select(User).order_by(User.created_at))
    users = result.scalars().all()
    return [UserResponse.model_validate(u) for u in users]


@router.patch("/users/{user_identifier}/role", response_model=UserResponse)
async def update_user_role(
    user_identifier: str,
    role_in: UserRoleUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Any:
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Недостаточно прав. Только администраторы могут изменять роли пользователей.",
        )

    target_role = role_in.role.lower().strip()
    if target_role not in ["user", "moderator", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Недопустимая роль. Допустимые значения: user, moderator, admin",
        )

    # Search by email first
    result = await db.execute(select(User).where(User.email == user_identifier))
    user = result.scalar_one_or_none()

    if not user:
        try:
            u_id = uuid.UUID(user_identifier)
            result = await db.execute(select(User).where(User.id == u_id))
            user = result.scalar_one_or_none()
        except ValueError:
            pass

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь не найден",
        )

    user.role = target_role
    await db.commit()
    await db.refresh(user)
    return UserResponse.model_validate(user)

