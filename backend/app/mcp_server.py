from mcp.server.fastmcp import FastMCP
from app.database import log_session

mcp_server = FastMCP("CinnamorolAR")

@mcp_server.tool()
def get_character_info(plane_type: str) -> str:
    """Get the character info and recommended scale based on the plane type."""
    scales = {
        "horizontal_up": 0.10,
        "horizontal_down": 0.08,
        "vertical": 0.09
    }
    scale = scales.get(plane_type, 0.10)
    
    import json
    info = {
        "name": "Cinnamoroll",
        "description": "A cute white puppy with long ears.",
        "scale": scale,
        "rotation_offset": 0.0,
        "model_url": "/assets/cinnamoroll.glb"
    }
    return json.dumps(info)

@mcp_server.tool()
async def log_ar_session(plane_type: str, placed_successfully: int, timestamp: str) -> str:
    """Log the AR session result."""
    session_id = await log_session(plane_type, placed_successfully, timestamp)
    
    import json
    result = {
        "logged": True,
        "session_id": session_id
    }
    return json.dumps(result)
