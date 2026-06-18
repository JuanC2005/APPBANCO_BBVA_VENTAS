from pydantic import BaseModel
from datetime import datetime


class BuroConsultaRequest(BaseModel):
    cliente_id: str
    dni: str
    firma_consentimiento_base64: str


class BuroConsultaResponse(BaseModel):
    calificacion_sbs: str
    entidades_con_deuda: int
    deuda_total_pen: float
    mayor_deuda: float
    dias_mayor_mora: int
    en_lista_negra: bool
    resultado_json: dict


class BuroHistorialResponse(BaseModel):
    id: str
    dni_consultado: str
    calificacion_sbs: str | None
    entidades_con_deuda: int
    deuda_total_pen: float
    created_at: datetime

    class Config:
        from_attributes = True
