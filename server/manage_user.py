#!/usr/bin/env python3
import asyncio
import sys
import argparse
from sqlalchemy import select, update
from app.db.session import AsyncSessionLocal
from app.models import user, pet, marker, post, reminder, story
from app.models.user import User

VALID_ROLES = ["user", "moderator", "admin"]


async def list_users():
    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User).order_by(User.created_at))
        users = result.scalars().all()
        if not users:
            print("В базе данных пока нет пользователей.")
            return

        print(f"\n{'ID':<38} | {'Имя':<22} | {'Email':<30} | {'Роль'}")
        print("-" * 105)
        for u in users:
            role_badge = f"🛡️  {u.role.upper()}" if u.role == "admin" else f"👤 {u.role}"
            print(f"{str(u.id):<38} | {u.name:<22} | {u.email:<30} | {role_badge}")
        print(f"\nВсего пользователей: {len(users)}\n")


async def set_role(email_or_id: str, new_role: str):
    new_role = new_role.lower().strip()
    if new_role not in VALID_ROLES:
        print(f"Ошибка: Недопустимая роль '{new_role}'. Допустимые роли: {', '.join(VALID_ROLES)}")
        sys.exit(1)

    async with AsyncSessionLocal() as session:
        # Find by email first, then by UUID
        result = await session.execute(select(User).where(User.email == email_or_id))
        user = result.scalar_one_or_none()

        if not user:
            try:
                import uuid
                u_id = uuid.UUID(email_or_id)
                result = await session.execute(select(User).where(User.id == u_id))
                user = result.scalar_one_or_none()
            except ValueError:
                pass

        if not user:
            print(f"Ошибка: Пользователь '{email_or_id}' не найден.")
            sys.exit(1)

        user.role = new_role
        await session.commit()
        await session.refresh(user)

        print(f"\n✅ Роль пользователя успешно обновлена!")
        print(f"Пользователь: {user.name} ({user.email})")
        print(f"Новая роль:   {user.role.upper()} {'🛡️ (Полный доступ к PawConnect Team)' if user.role == 'admin' else ''}\n")


def main():
    parser = argparse.ArgumentParser(description="PawConnect User & Role Management CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # list
    subparsers.add_parser("list", help="Вывести список всех пользователей и их ролей")

    # set-role
    set_parser = subparsers.add_parser("set-role", help="Назначить роль пользователю")
    set_parser.add_argument("email", help="Email или ID пользователя")
    set_parser.add_argument("role", choices=VALID_ROLES, help="Новая роль (user, moderator, admin)")

    # make-admin
    admin_parser = subparsers.add_parser("make-admin", help="Сделать пользователя администратором")
    admin_parser.add_argument("email", help="Email или ID пользователя")

    args = parser.parse_args()

    if args.command == "list":
        asyncio.run(list_users())
    elif args.command == "set-role":
        asyncio.run(set_role(args.email, args.role))
    elif args.command == "make-admin":
        asyncio.run(set_role(args.email, "admin"))


if __name__ == "__main__":
    main()
