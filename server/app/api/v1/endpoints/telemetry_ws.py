import json
import uuid
from typing import Dict, Set
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from .markers import haversine_distance

router = APIRouter()


class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, Set[WebSocket]] = {}

    async def connect(self, pet_id: str, websocket: WebSocket):
        await websocket.accept()
        if pet_id not in self.active_connections:
            self.active_connections[pet_id] = set()
        self.active_connections[pet_id].add(websocket)

    def disconnect(self, pet_id: str, websocket: WebSocket):
        if pet_id in self.active_connections:
            self.active_connections[pet_id].discard(websocket)
            if not self.active_connections[pet_id]:
                del self.active_connections[pet_id]

    async def broadcast_to_pet_listeners(self, pet_id: str, message: dict):
        if pet_id in self.active_connections:
            dead_sockets = set()
            for ws in self.active_connections[pet_id]:
                try:
                    await ws.send_json(message)
                except Exception:
                    dead_sockets.add(ws)
            for dead in dead_sockets:
                self.active_connections[pet_id].discard(dead)


manager = ConnectionManager()


@router.websocket("/ws/telemetry/{pet_id}")
async def telemetry_websocket(websocket: WebSocket, pet_id: str):
    await manager.connect(pet_id, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            try:
                payload = json.loads(data)
                # Broadcast real-time collar coordinate update to all listening clients (e.g. Owner app)
                await manager.broadcast_to_pet_listeners(pet_id, {
                    "type": "telemetry_update",
                    "pet_id": pet_id,
                    "latitude": payload.get("latitude"),
                    "longitude": payload.get("longitude"),
                    "battery_level": payload.get("battery_level", 100),
                    "is_breach": payload.get("is_breach", False),
                })
            except json.JSONDecodeError:
                pass
    except WebSocketDisconnect:
        manager.disconnect(pet_id, websocket)
