import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .core.config import settings
from .api.v1.api import api_router
from .db.session import engine, Base
# Import all models to register with Base
from .models import user, pet, marker, post, reminder


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Auto-create tables on startup (convenient for local and initial VPS boot)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Ensure media directories exist
    os.makedirs(os.path.join(settings.MEDIA_ROOT, "avatars"), exist_ok=True)
    os.makedirs(os.path.join(settings.MEDIA_ROOT, "posts"), exist_ok=True)
    os.makedirs(os.path.join(settings.MEDIA_ROOT, "markers"), exist_ok=True)
    
    yield


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
    lifespan=lifespan,
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API v1 Router
app.include_router(api_router, prefix=settings.API_V1_STR)

# Static media mount
if os.path.exists(settings.MEDIA_ROOT):
    app.mount("/media", StaticFiles(directory=settings.MEDIA_ROOT), name="media")


@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
    }
