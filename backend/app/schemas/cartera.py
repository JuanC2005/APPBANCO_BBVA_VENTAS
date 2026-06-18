from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional


class CarteraVisitaResponse(BaseModel):
    id: str
    asesor_id: str
    cliente_id: str
    fecha_asignacion: date
    tipo_gestion: str
    prioridad: str
    score_prioridad: int
    monto_referencial: float
    estado_visita: str
    resultado_visita: str | None
    observacion_visita: str | None
    timestamp_visita: datetime | None
    lat_visita: float | None
    lng_visita: float | None
    orden_manual: int
    created_at: datetime

    class Config:
        from_attributes = True


class VisitaUpdateRequest(BaseModel):
    resultado_visita: str
    observacion_visita: str | None = None
    lat_visita: float | None = None
    lng_visita: float | None = None


class FichaCampoCreate(BaseModel):
    cliente_id: str
    tipo_visita: str = "prospeccion"
    latitud: float | None = None
    longitud: float | None = None
    distrito: str | None = None
    resultado: str | None = None
    observaciones: str | None = None
