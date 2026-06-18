from pydantic import BaseModel
from datetime import datetime


class AsesorNegocioResponse(BaseModel):
    id: str
    codigo_empleado: str
    email: str
    nombres: str
    apellidos: str
    telefono: str | None
    agencia_id: str | None
    perfil: str
    activo: bool
    ultimo_acceso: datetime | None
    created_at: datetime

    class Config:
        from_attributes = True
