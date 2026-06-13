from fastapi import APIRouter
from fastapi.responses import FileResponse
import os

router = APIRouter()

@router.get("/assets/cinnamoroll.glb")
async def get_cinnamoroll_model():
    file_path = "assets/cinnamoroll.glb"
    if not os.path.exists(file_path):
        return {"error": "Model not found"}, 404
    return FileResponse(file_path, media_type="model/gltf-binary")
