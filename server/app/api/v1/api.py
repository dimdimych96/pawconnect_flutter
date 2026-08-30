from fastapi import APIRouter
from .endpoints import auth, pets, markers, posts, reminders, beacons, telemetry_ws

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Аутентификация"])
api_router.include_router(pets.router, prefix="/pets", tags=["Питомцы и Трекеры"])
api_router.include_router(markers.router, prefix="/map/markers", tags=["Интерактивная карта"])
api_router.include_router(posts.router, prefix="/community/posts", tags=["Лента районов"])
api_router.include_router(reminders.router, prefix="/reminders", tags=["Вет-календарь"])
api_router.include_router(beacons.router, prefix="/beacons", tags=["BLE Краудсорсинг"])
api_router.include_router(telemetry_ws.router, tags=["WebSockets"])
