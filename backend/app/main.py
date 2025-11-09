from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import health, send

app = FastAPI(title="SaveThis API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router, prefix="")
app.include_router(send.router, prefix="/api")

@app.on_event("startup")
async def startup_event():
    # placeholder for startup tasks (DB connect, cache, etc.)
    print("Starting SaveThis API...")
