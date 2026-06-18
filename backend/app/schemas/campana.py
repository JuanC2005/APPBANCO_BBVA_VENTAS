from pydantic import BaseModel
from datetime import datetime


class CampanaCreate(BaseModel):
    titulo: str
    descripcion: str | None = None
    tipo: str = "general"
    producto_objetivo: str | None = None
    monto_min: float = 0
    monto_max: float = 999999


class CampanaResponse(BaseModel):
    id: str
    titulo: str
    descripcion: str | None
    tipo: str
    activa: bool
    created_at: datetime

    class Config:
        from_attributes = True
