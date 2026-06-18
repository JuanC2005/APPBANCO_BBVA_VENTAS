from pydantic import BaseModel
from datetime import date, datetime


class ClienteMoraResponse(BaseModel):
    cliente_id: str
    cliente_nombre: str
    numero_documento: str | None
    credito_id: str
    deuda: float
    dias_mora: int
    direccion: str | None
    lat: float | None
    lng: float | None


class AccionCobranzaCreate(BaseModel):
    cliente_id: str
    credito_id: str | None = None
    tipo_gestion: str
    resultado: str
    monto_pagado: float = 0
    monto_comprometido: float = 0
    fecha_compromiso: date | None = None
    observaciones: str | None = None
    lat: float | None = None
    lng: float | None = None


class AccionCobranzaResponse(BaseModel):
    id: str
    tipo_gestion: str
    resultado: str
    monto_pagado: float
    monto_comprometido: float
    fecha_compromiso: date | None
    observaciones: str | None
    created_at: datetime

    class Config:
        from_attributes = True
