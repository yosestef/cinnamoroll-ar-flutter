from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health, assets
from app.database import init_db
from app.mcp_server import mcp_server

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield

app = FastAPI(title="CinnamorolAR Backend", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(assets.router)

# Mount FastMCP SSE Server
mcp_server.add_to_fastapi(app, sse_path="/mcp/sse", messages_path="/mcp/messages")
