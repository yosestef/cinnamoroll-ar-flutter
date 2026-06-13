from pydantic import BaseModel
from typing import Optional

class ARSessionLog(BaseModel):
    plane_type: str
    placed_successfully: int
    timestamp: str

class CharacterInfo(BaseModel):
    name: str
    description: str
    scale: float
    rotation_offset: float
    model_url: str
