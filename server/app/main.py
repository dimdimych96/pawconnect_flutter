import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .core.config import settings
from .api.v1.api import api_router
from .db.session import engine, Base
# Import all models to register with Base
from .models import user, pet, marker, post, reminder, story, sos, walk, breed, specialist
from .models.breed import Breed, CURATED_BREEDS
from .models.specialist import Specialist, CURATED_SPECIALISTS
from .db.session import engine, Base, AsyncSessionLocal
from sqlalchemy import select


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Auto-create tables on startup (convenient for local and initial VPS boot)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Ensure media directories exist
    os.makedirs(os.path.join(settings.MEDIA_ROOT, "avatars"), exist_ok=True)
    os.makedirs(os.path.join(settings.MEDIA_ROOT, "posts"), exist_ok=True)
    os.makedirs(os.path.join(settings.MEDIA_ROOT, "markers"), exist_ok=True)

    # Seed curated breeds if empty
    async with AsyncSessionLocal() as session:
        try:
            result = await session.execute(select(Breed).limit(1))
            if not result.scalar_one_or_none():
                for b_data in CURATED_BREEDS:
                    session.add(Breed(**b_data))
                await session.commit()
        except Exception:
            await session.rollback()

    # Seed curated specialists if empty
    async with AsyncSessionLocal() as session:
        try:
            result = await session.execute(select(Specialist).limit(1))
            if not result.scalar_one_or_none():
                for s_data in CURATED_SPECIALISTS:
                    session.add(Specialist(**s_data))
                await session.commit()
        except Exception:
            await session.rollback()
    
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
